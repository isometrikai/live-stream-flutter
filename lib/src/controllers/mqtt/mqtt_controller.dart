import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/live_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:mqtt_helper/mqtt_helper.dart';

class IsmLiveMqttController extends GetxController {
  final _mqttHelper = MqttHelper();

  bool _isInitialized = false;
  bool _isReconnecting = false;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts =
      0; // (3)  auto connect already manage in MQTT helper
  static const Duration _initialReconnectDelay = Duration(seconds: 2);
  static const Duration _maxReconnectDelay = Duration(seconds: 30);

  late String userTopic;
  late String userId;
  late String deviceId;

  final List<String> _topics = [];
  final actionStreamController = StreamController<EventModel>.broadcast();
  var actionListeners = <EventFunction>[];

  String _topicPrefix = '';
  IsmLiveConfigData? _config;

  // Reconnection configuration
  bool _autoReconnect = true;
  Duration _reconnectDelay = _initialReconnectDelay;

  // Getters for external access
  bool get isReconnecting => _isReconnecting;
  bool get autoReconnect => _autoReconnect;
  int get reconnectAttempts => _reconnectAttempts;
  int get maxReconnectAttempts => _maxReconnectAttempts;

  IsmLiveStreamController get _streamController {
    if (!Get.isRegistered<IsmLiveStreamController>()) {
      IsmLiveStreamBinding().dependencies();
    }
    return Get.find<IsmLiveStreamController>();
  }

  IsmLivePkController get _pkController {
    if (!Get.isRegistered<IsmLivePkController>()) {
      IsmLivePkBinding().dependencies();
    }
    return Get.find<IsmLivePkController>();
  }

  void _updateStreamListing() {
    IsmLiveUtility.updateLater(() {
      Future.delayed(const Duration(milliseconds: 100), () {
        _streamController.update([IsmLiveStreamListing.updateId]);
      });
    });
  }

  void _updateStream([List<String>? updateIds]) {
    IsmLiveUtility.updateLater(() {
      Future.delayed(const Duration(milliseconds: 100), () {
        _streamController.update([IsmLiveStreamView.updateId, ...?updateIds]);
      });
    });
  }

  void _disconnectRoom() {
    _streamController.disconnectRoom();
  }

  String? get _hostImageUrl =>
      _streamController.hostDetails?.userProfileImageUrl;

  String? _viewerImageUrl(String viewerId) =>
      _streamController.streamViewersList
          .cast<IsmLiveViewerModel?>()
          .firstWhere((e) => e!.userId == viewerId, orElse: () => null)
          ?.imageUrl;

  String? _moderatorImageUrl(String moderatorId) =>
      _streamController.moderatorsList
          .cast<UserDetails?>()
          .firstWhere((e) => e!.userId == moderatorId, orElse: () => null)
          ?.profileUrl;

  String? _memberImageUrl(String moderatorId) =>
      _streamController.streamMembersList
          .cast<IsmLiveMemberDetailsModel?>()
          .firstWhere((e) => e!.userId == moderatorId, orElse: () => null)
          ?.userProfileImageUrl;

  // ----------------- Functions -----------------------

  Future<void> setup({
    List<String>? topics,
    List<String>? topicChannels,
    required bool shouldInitializeMqtt,
  }) async {
    IsmLiveLog.info('mqtt setup 1');
    if (_isInitialized) {
      return;
    }

    IsmLiveLog.info('mqtt setup 2');
    _isInitialized = true;
    _config = IsmLiveUtility.config;
    _topicPrefix =
        '/${_config!.projectConfig.accountId}/${_config!.projectConfig.projectId}';

    deviceId = _config!.projectConfig.deviceId;

    userId = _config!.userConfig.userId;

    userTopic = '$_topicPrefix/User/$userId';

    var channelTopics =
        topicChannels?.map((e) => '$_topicPrefix/$e/$userId').toList();

    _topics.addAll([
      ...?topics,
      ...?channelTopics,
      userTopic,
    ]);

    if (shouldInitializeMqtt) {
      try {
        debugPrint(
            'IsmLiveApp: ServerConfig: ${ServerConfig.fromMap(_config!.mqttConfig.toMap())}');
        debugPrint(
            'IsmLiveApp: userId: $userId username: ${_config?.username} password: ${_config?.password} deviceId: $deviceId');
        await _mqttHelper.initialize(
          MqttConfig(
            serverConfig: ServerConfig.fromMap(_config!.mqttConfig.toMap()),
            projectConfig: ProjectConfig(
              deviceId: deviceId,
              username: _config?.username ?? '',
              password: _config?.password ?? '',
              userIdentifier: userId,
            ),
            enableLogging: true,
            webSocketConfig: _config!.socketConfig != null
                ? WebSocketConfig.fromMap(
                    _config!.socketConfig!.toMap(),
                  )
                : null,
            secure: _config!.secure,
          ),
          callbacks: MqttCallbacks(
            onConnected: _onConnected,
            onDisconnected: _onDisconnected,
            onSubscribeFail: _onSubscribeFailed,
            onSubscribed: _onSubscribed,
            onUnsubscribed: _onUnSubscribed,
            pongCallback: _pong,
          ),
          autoSubscribe: true,
          topics: _topics,
        );

        _mqttHelper
            .onConnectionChange((value) => IsmLiveApp.isMqttConnected = value);
        _mqttHelper.onEvent(_onEvent);
      } catch (e) {
        IsmLiveLog.error('mqtt issue mqttcontroller 145 line');
      }
    }
  }

  Future<void> subscribeStream(String streamId) async {
    try {
      if (!IsmLiveApp.isMqttConnected) {
        IsmLiveLog.info('MQTT is not connected, attempting to reconnect');
        await reconnect();
      }
      var topic = '$_topicPrefix/$streamId';
      // Ensure this topic is tracked for auto-resubscribe on reconnects
      if (!_topics.contains(topic)) {
        _topics.add(topic);
      }
      _mqttHelper.subscribeTopic(topic);
    } catch (e) {
      IsmLiveLog.error('Subscribe Error - $e');
    }
  }

  Future<void> unsubscribeTopics() async {
    try {
      IsmLiveLog('Unsubscribing Topics $_topics');
      _mqttHelper.unsubscribeTopics(_topics);
    } catch (e) {
      IsmLiveLog.error('Unsubscribe Error - $e');
    }
  }

  Future<void> unsubscribeStream(String streamId) async {
    try {
      var topic = '$_topicPrefix/$streamId';
      _mqttHelper.unsubscribeTopic(topic);
      // Remove from tracked topics so it is not auto-resubscribed
      _topics.remove(topic);
    } catch (e) {
      IsmLiveLog.error('Subscribe Error - $e');
    }
  }

  Future<void> disconnect() async {
    // Cancel any pending reconnection attempts
    _reconnectTimer?.cancel();
    _isReconnecting = false;
    _reconnectAttempts = 0;

    _mqttHelper.disconnect();
    await actionStreamController.stream.drain();
  }

  void _pong() {
    IsmLiveLog.info('MQTT pong');
  }

  /// onDisconnected callback, it will be called when connection is breaked
  void _onDisconnected() {
    IsmLiveApp.isMqttConnected = false;
    IsmLiveLog.success('MQTT Disconnected');

    // Trigger automatic reconnection if enabled
    if (_autoReconnect && !_isReconnecting) {
      _scheduleReconnection();
    }
  }

  /// onSubscribed callback, it will be called when connection successfully subscribes to certain topic
  void _onSubscribed(String topic) {
    IsmLiveLog.success('MQTT Subscribed - $topic');
  }

  /// onUnsubscribed callback, it will be called when connection successfully unsubscribes to certain topic
  void _onUnSubscribed(String? topic) {
    IsmLiveLog.success('MQTT Unsubscribed - $topic');
  }

  /// onSubscribeFailed callback, it will be called when connection fails to subscribe to certain topic
  void _onSubscribeFailed(String topic) {
    IsmLiveLog.error('MQTT Subscription failed - $topic');
  }

  /// onConnected callback, it will be called when connection is established
  void _onConnected() {
    IsmLiveApp.isMqttConnected = true;
    IsmLiveLog.success('MQTT Connected');

    // Reset reconnection state on successful connection
    _resetReconnectionState();
  }

  // ----------------- Reconnection Methods -----------------------

  /// Schedules automatic reconnection with exponential backoff
  void _scheduleReconnection() {
    if (_isReconnecting || _reconnectAttempts >= _maxReconnectAttempts) {
      IsmLiveLog.error(
          'MQTT: Max reconnection attempts reached or already reconnecting');
      return;
    }

    _isReconnecting = true;
    _reconnectAttempts++;

    IsmLiveLog.info(
        'MQTT: Scheduling reconnection attempt $_reconnectAttempts/$_maxReconnectAttempts in ${_reconnectDelay.inSeconds} seconds');

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, _attemptReconnection);

    // Exponential backoff for next attempt
    _reconnectDelay = Duration(
      seconds: (_reconnectDelay.inSeconds * 2).clamp(
        _initialReconnectDelay.inSeconds,
        _maxReconnectDelay.inSeconds,
      ),
    );
  }

  /// Attempts to reconnect to MQTT
  Future<void> _attemptReconnection() async {
    if (!_isReconnecting) return;

    IsmLiveLog.info('MQTT: Attempting reconnection...');

    try {
      await _mqttHelper.initialize(
        MqttConfig(
          serverConfig: ServerConfig.fromMap(_config!.mqttConfig.toMap()),
          projectConfig: ProjectConfig(
            deviceId: deviceId,
            username: _config?.username ?? '',
            password: _config?.password ?? '',
            userIdentifier: userId,
          ),
          enableLogging: true,
          webSocketConfig: _config!.socketConfig != null
              ? WebSocketConfig.fromMap(
                  _config!.socketConfig!.toMap(),
                )
              : null,
          secure: _config!.secure,
        ),
        callbacks: MqttCallbacks(
          onConnected: _onConnected,
          onDisconnected: _onDisconnected,
          onSubscribeFail: _onSubscribeFailed,
          onSubscribed: _onSubscribed,
          onUnsubscribed: _onUnSubscribed,
          pongCallback: _pong,
        ),
        autoSubscribe: true,
        topics: _topics,
      );

      _mqttHelper
          .onConnectionChange((value) => IsmLiveApp.isMqttConnected = value);
      _mqttHelper.onEvent(_onEvent);

      IsmLiveLog.success('MQTT: Reconnection successful');
    } catch (e) {
      IsmLiveLog.error('MQTT: Reconnection failed - $e');

      // Schedule next reconnection attempt if we haven't reached max attempts
      if (_reconnectAttempts < _maxReconnectAttempts) {
        _scheduleReconnection();
      } else {
        _isReconnecting = false;
        IsmLiveLog.error(
            'MQTT: Max reconnection attempts reached. Manual reconnection required.');
      }
    }
  }

  /// Resets reconnection state after successful connection
  void _resetReconnectionState() {
    _isReconnecting = false;
    _reconnectAttempts = 0;
    _reconnectDelay = _initialReconnectDelay;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  /// Manual reconnection method for host app
  Future<bool> reconnect() async {
    if (_isReconnecting) {
      IsmLiveLog.error('MQTT: Already attempting to reconnect');
      return false;
    }

    IsmLiveLog.info('MQTT: Manual reconnection requested');
    _resetReconnectionState();
    _isReconnecting = true;

    await _attemptReconnection();
    return IsmLiveApp.isMqttConnected;
  }

  /// Enables or disables automatic reconnection
  void setAutoReconnect(bool enabled) {
    _autoReconnect = enabled;
    IsmLiveLog.info('MQTT: Auto-reconnect ${enabled ? 'enabled' : 'disabled'}');
  }

  /// Sets custom reconnection configuration
  void setReconnectionConfig({
    int? maxAttempts,
    Duration? initialDelay,
    Duration? maxDelay,
  }) {
    if (maxAttempts != null && maxAttempts > 0) {
      // Note: _maxReconnectAttempts is const, so we'll use a different approach
      IsmLiveLog.info(
          'MQTT: Max reconnection attempts cannot be changed at runtime');
    }
    if (initialDelay != null) {
      _reconnectDelay = initialDelay;
    }
    IsmLiveLog.info('MQTT: Reconnection configuration updated');
  }

  /// Gets current reconnection status
  Map<String, dynamic> getReconnectionStatus() => {
        'isReconnecting': _isReconnecting,
        'reconnectAttempts': _reconnectAttempts,
        'maxReconnectAttempts': _maxReconnectAttempts,
        'autoReconnect': _autoReconnect,
        'isConnected': IsmLiveApp.isMqttConnected,
      };

  void handleEventsExternally(EventModel payload) => _onEvent(payload);

  void _onEvent(EventModel event) async {
    final payload = event.payload;
    if (IsmLiveHandler.isLogsEnabled) {
      IsmLiveLog(IsmLiveUtility.jsonEncodePretty(payload));
      IsmLiveLog.success(payload['action']);
    }

    actionStreamController.add(event);
    if (payload['action'] != null) {
      final action = IsmLiveActions.fromString(payload['action']);
      final streamId = payload['streamId'] as String?;

      if (streamId == null &&
          action != IsmLiveActions.pubsubMessagePublished &&
          action != IsmLiveActions.pubsubDirectMessagePublished &&
          action != IsmLiveActions.pubsubMessageOnTopicPublished) {
        return;
      }

      switch (action) {
        case IsmLiveActions.copublishRequestAccepted:
          final memberId = payload['userId'] as String? ?? '';
          final hostId = payload['initiatorId'] as String? ?? '';
          if (memberId == userId || hostId == userId) {
            _streamController.memberStatus =
                IsmLiveMemberStatus.requestApproved;
            final hostName = payload['initiatorName'] as String? ?? 'Host';
            final userName = payload['userName'] as String? ?? 'User';
            final message = IsmLiveMessageModel(
              streamId: streamId!,
              senderName: hostName,
              senderIdentifier: '',
              senderProfileImageUrl: _hostImageUrl,
              senderId: hostId,
              messageType: IsmLiveMessageType.normal,
              messageId: '',
              body: memberId == userId
                  ? '$hostName has accepted your Co-publisher Request'
                  : 'You\'ve accepted $userName\'s Co-publisher Request',
              isEvent: true,
            );
            LocalNotificationService.showBasicNotification(
                body: message.body,
                title: 'Co-publishing request',
                payload: '');

            unawaited(_streamController.handleMessage(message: message));
            _updateStream([IsmLiveControlsWidget.updateId]);
          }
          break;
        case IsmLiveActions.copublishRequestAdded:
          final user = UserDetails.fromMap(payload);
          if (_streamController.isHost) {
            final message = IsmLiveMessageModel(
              streamId: streamId!,
              senderName: user.userName,
              senderIdentifier: user.userIdentifier,
              senderProfileImageUrl: user.profileUrl,
              senderId: user.userId,
              messageType: IsmLiveMessageType.normal,
              messageId: '',
              body: '${user.userName} has requested for Co-publishing',
              isEvent: true,
              isCopublisherRequest: true,
            );

            LocalNotificationService.showBasicNotification(
                body: message.body,
                title: 'Co-publishing requested',
                payload: '');
            unawaited(_streamController.handleMessage(message: message));
            _updateStream([IsmLiveControlsWidget.updateId]);
          }
          break;
        case IsmLiveActions.copublishRequestDenied:
          final memberId = payload['userId'] as String? ?? '';
          final hostId = payload['initiatorId'] as String? ?? '';
          if (memberId == userId || hostId == userId) {
            _streamController.memberStatus = IsmLiveMemberStatus.requestDenied;
            final hostName = payload['initiatorName'] as String? ?? 'Host';
            final userName = payload['userName'] as String? ?? 'User';
            final message = IsmLiveMessageModel(
              streamId: streamId!,
              senderName: hostName,
              senderProfileImageUrl: _hostImageUrl,
              senderIdentifier: '',
              senderId: hostId,
              messageType: IsmLiveMessageType.normal,
              messageId: '',
              body: memberId == userId
                  ? '$hostName has rejected your Co-publisher Request'
                  : 'You\'ve rejected $userName\'s Co-publisher Request',
              isEvent: true,
            );
            LocalNotificationService.showBasicNotification(
                body: message.body,
                title: 'Co-publishing request',
                payload: '');
            unawaited(_streamController.handleMessage(message: message));
            _updateStream([IsmLiveControlsWidget.updateId]);
          }
          break;
        case IsmLiveActions.copublishRequestRemoved:
          break;
        case IsmLiveActions.memberAdded:
          final memberId = payload['memberId'] as String? ?? '';
          final memberName = payload['memberName'] as String? ?? '';
          final memberIdentifier = payload['memberIdentifier'] as String? ?? '';
          final memberProfilePic = payload['memberProfilePic'] as String? ?? '';
          final hostName = payload['initiatorName'] as String? ?? 'Host';
          final hostId = payload['initiatorId'] as String? ?? '';
          var body = '';
          if (memberId == userId) {
            _streamController.memberStatus = IsmLiveMemberStatus.gotRequest;
            body = '$hostName has added you as a Co-publisher';
          } else if (hostId == userId) {
            body = 'You\'ve added $memberName as a Co-publisher';
          } else {
            body = '$hostName has added $memberName as a Co-publisher';
          }
          final message = IsmLiveMessageModel(
            streamId: streamId!,
            senderName: hostName,
            senderProfileImageUrl: memberProfilePic,
            senderIdentifier: memberIdentifier,
            senderId: hostId,
            messageType: IsmLiveMessageType.normal,
            messageId: '',
            body: body,
            isEvent: true,
          );
          LocalNotificationService.showBasicNotification(
              body: message.body, title: 'Co-publishing added', payload: '');

          unawaited(_streamController.handleMessage(message: message));
          _updateStream([IsmLiveControlsWidget.updateId]);
          break;
        case IsmLiveActions.memberLeft:
          var member = IsmLiveViewerModel.fromMap(payload);
          final message = IsmLiveMessageModel(
            streamId: streamId!,
            senderName: member.userName,
            senderProfileImageUrl: _memberImageUrl(member.userId),
            senderIdentifier: member.identifier,
            senderId: member.userId,
            messageType: IsmLiveMessageType.normal,
            messageId: '',
            body: '${member.userName} has stopped publishing and left',
            isEvent: true,
          );
          _streamController.pkStages = null;
          unawaited(_streamController.handleMessage(message: message));
          _streamController.streamMembersList
              .removeWhere((e) => e.userId == member.userId);
          _updateStream();

          break;
        case IsmLiveActions.memberRemoved:
          final memberName = payload['memberName'] as String? ?? '';
          final memberId = payload['memberId'] as String? ?? '';
          final initiatorName = payload['initiatorName'] as String? ?? '';
          final initiatorId = payload['initiatorId'] as String? ?? '';
          if (streamId == _streamController.streamId) {
            final message = IsmLiveMessageModel(
              streamId: streamId!,
              senderName: initiatorName,
              senderIdentifier: '',
              senderProfileImageUrl: _hostImageUrl,
              senderId: initiatorId,
              messageType: IsmLiveMessageType.normal,
              messageId: '',
              body: userId == initiatorId
                  ? 'You\'ve remove $memberName as a member'
                  : '$initiatorName has remove $memberName as a member',
              isEvent: true,
            );
            unawaited(_streamController.handleMessage(message: message));
            _updateStream([IsmLiveMembersSheet.updateId]);
            _streamController.streamMembersList
                .removeWhere((e) => e.userId == memberId);
            if (userId != initiatorId && userId == memberId) {
              _disconnectRoom();
              IsmLiveRoute.pop();
            }
            // if (memberId == userId) {
            //   unawaited(_streamController.unpublishTracks());
            // }
          }
          break;
        case IsmLiveActions.profileSwitched:
          final memberId = payload['userId'] as String? ?? '';
          final memberName = payload['userName'] as String? ?? '';
          var body = '';
          if (memberId == userId) {
            body = 'You\'ve enabled your video';
          } else {
            body = '$memberName has enabled his video';
          }
          final message = IsmLiveMessageModel(
            streamId: streamId!,
            senderName: memberName,
            senderIdentifier: '',
            senderId: memberId,
            messageType: IsmLiveMessageType.normal,
            messageId: '',
            body: body,
            isEvent: true,
          );
          _streamController.streamViewersList
              .removeWhere((element) => element.userId == memberId);

          await _streamController.getStreamMembers(
            streamId: streamId,
          );

          if (_streamController.isHost && !_streamController.isPk) {
            _streamController.userRole?.makeCopublisher();
          }
          unawaited(_streamController.handleMessage(message: message));
          _updateStream();

          break;

        case IsmLiveActions.pubsubMessagePublished:
          _pkController.pkInviteEvent(payload);

          break;
        case IsmLiveActions.pubsubDirectMessagePublished:
          _pkController.pkStopEvent(payload, false);
          break;

        case IsmLiveActions.pubsubMessageOnTopicPublished:
          _pkController.pkStopEvent(payload, false);
          break;

        case IsmLiveActions.messageRemoved:
          if (_streamController.streamId == streamId) {
            final messageId = payload['messageId'] as String?;
            final userName = payload['initiatorName'] as String? ?? '';
            if (messageId == null) {
              break;
            }
            await _streamController.messageRemoved(messageId, userName);
            _updateStream();
          }
          break;
        case IsmLiveActions.messageReplyRemoved:
          break;
        case IsmLiveActions.messageReplySent:
        case IsmLiveActions.messageSent:
          if (_streamController.streamId == streamId) {
            final message = IsmLiveMessageModel.fromMap(payload);

            await _streamController.handleMessage(
                message: message, payload: payload);

            _updateStream();
          }
          break;
        case IsmLiveActions.moderatorAdded:
          final moderatorId = payload['moderatorId'] as String? ?? '';
          final moderatorName = payload['moderatorName'] as String? ?? '';
          final moderatorIdentifier =
              payload['moderatorIdentifier'] as String? ?? '';
          final moderatorProfilePic =
              payload['moderatorProfilePic'] as String? ?? '';
          final message = IsmLiveMessageModel(
            streamId: streamId!,
            senderName: moderatorName,
            senderIdentifier: moderatorIdentifier,
            senderProfileImageUrl: moderatorProfilePic,
            senderId: moderatorId,
            messageType: IsmLiveMessageType.normal,
            messageId: '',
            body: '$moderatorName is a moderator now',
            isEvent: true,
          );

          unawaited(_streamController.handleMessage(message: message));
          if (userId == moderatorId) {
            final hostName = payload['initiatorName'];
            IsmLiveUtility.showCustomDialog(
              IsmLiveModeratorDialog(
                hostName: hostName,
                streamId: streamId,
              ),
              isDismissible: false,
            );
          }
          break;
        case IsmLiveActions.moderatorLeft:
          final moderatorId = payload['moderatorId'] as String? ?? '';
          final moderatorName = payload['moderatorName'] as String? ?? '';
          if (streamId == _streamController.streamId) {
            final message = IsmLiveMessageModel(
              streamId: streamId!,
              senderName: moderatorName,
              senderProfileImageUrl: _moderatorImageUrl(moderatorId),
              senderIdentifier: '',
              senderId: moderatorId,
              messageType: IsmLiveMessageType.normal,
              messageId: '',
              body: '$moderatorName has left from moderator ',
              isEvent: true,
            );
            unawaited(_streamController.handleMessage(message: message));
            _streamController.moderatorsList
                .removeWhere((e) => e.userId == moderatorId);
            // _streamController.streamViewersList
            //     .removeWhere((e) => e.userId == moderatorId);

            _updateStream();
          }
          break;
        case IsmLiveActions.moderatorRemoved:
          final moderatorId = payload['moderatorId'] as String? ?? '';
          final moderatorName = payload['moderatorName'] as String? ?? '';
          final initiatorName = payload['initiatorName'] as String? ?? '';
          final initiatorId = payload['initiatorId'] as String? ?? '';
          if (streamId == _streamController.streamId) {
            final message = IsmLiveMessageModel(
              streamId: streamId!,
              senderName: initiatorName,
              senderProfileImageUrl: _hostImageUrl,
              senderIdentifier: '',
              senderId: initiatorId,
              messageType: IsmLiveMessageType.normal,
              messageId: '',
              body: userId == initiatorId
                  ? 'You\'ve remove  $moderatorName from moderator'
                  : '$initiatorName has remove $moderatorName from moderator',
              isEvent: true,
            );
            unawaited(_streamController.handleMessage(message: message));
            _streamController.moderatorsList
                .removeWhere((e) => e.userId == moderatorId);
            // _streamController.streamViewersList
            //     .removeWhere((e) => e.userId == moderatorId);
            if (moderatorId == userId) {
              _streamController.userRole?.leaveModeration();
            }
            _updateStream();

            // if (moderatorId == userId) {
            //    _disconnectRoom();
            //   Get.back();
            //   IsmLiveUtility.showDialog(const IsmLiveKickoutDialog());
            // }
          }
          break;

        case IsmLiveActions.publisherTimeout:
          break;
        case IsmLiveActions.publishStarted:
          break;
        case IsmLiveActions.publishStopped:
          _pkController.pkTimer?.cancel();
          _pkController.pkTimer = null;
          break;
        case IsmLiveActions.streamStartPresence:
          unawaited(_streamController.getStreams());

          break;
        case IsmLiveActions.streamStarted:
          break;
        case IsmLiveActions.streamStopped:
          final initiatorId = payload['initiatorId'] as String?;
          if (Get.isDialogOpen ?? false) {
            await Future.delayed(const Duration(milliseconds: 300));
          }
          _streamController.streams.removeWhere((e) => e.streamId == streamId);
          if (initiatorId != userId) {
            _disconnectRoom();
            _streamController.closeStreamView(false, fromMqtt: true);
          }
          _updateStreamListing();

          break;
        case IsmLiveActions.viewerJoined:
          if (streamId == _streamController.streamId) {
            var viewer = IsmLiveViewerModel.fromMap(payload);
            final message = IsmLiveMessageModel(
              streamId: streamId!,
              senderProfileImageUrl: viewer.imageUrl,
              senderName: viewer.userName,
              senderIdentifier: viewer.identifier,
              senderId: viewer.userId,
              messageType: IsmLiveMessageType.normal,
              messageId: DateTime.now().toString(),
              body: '${viewer.userName} has joined',
              isEvent: true,
            );

            if (viewer.userId != _streamController.user?.userId) {
              unawaited(_streamController.handleMessage(message: message));
              await _streamController.addViewers([viewer], false);
              _updateStream();
            }
          }
          break;
        case IsmLiveActions.viewerLeft:
          if (streamId == _streamController.streamId) {
            var viewer = IsmLiveViewerModel.fromMap(payload);
            final message = IsmLiveMessageModel(
              streamId: streamId!,
              senderName: viewer.userName,
              senderProfileImageUrl: _viewerImageUrl(viewer.userId),
              senderIdentifier: viewer.identifier,
              senderId: viewer.userId,
              messageType: IsmLiveMessageType.normal,
              messageId: DateTime.now().toString(),
              body: '${viewer.userName} has left',
              isEvent: true,
            );

            if (viewer.userId != userId) {
              unawaited(_streamController.handleMessage(message: message));
              _streamController.streamViewersList
                  .removeWhere((e) => e.userId == viewer.userId);
              _updateStream();
            }
          }
          break;
        case IsmLiveActions.viewerRemoved:
          final viewerId = payload['viewerId'] as String? ?? '';
          final viewerName = payload['viewerName'] as String? ?? '';
          final initiatorName = payload['initiatorName'] as String? ?? '';
          final initiatorId = payload['initiatorId'] as String? ?? '';
          if (streamId == _streamController.streamId) {
            final message = IsmLiveMessageModel(
              streamId: streamId!,
              senderName: initiatorName,
              senderProfileImageUrl: _hostImageUrl,
              senderIdentifier: '',
              senderId: initiatorId,
              messageType: IsmLiveMessageType.normal,
              messageId: DateTime.now().toString(),
              body: userId == initiatorId
                  ? 'You\'ve remove $viewerName'
                  : '$initiatorName has remove $viewerName',
              isEvent: true,
            );

            unawaited(_streamController.handleMessage(message: message));
            _streamController.streamViewersList
                .removeWhere((e) => e.userId == viewerId);
            if (userId == viewerId) {
              _disconnectRoom();
            }
            _updateStream();
            if (viewerId == userId) {
              IsmLiveRoute.pop();
              IsmLiveUtility.showCustomDialog(const IsmLiveKickoutDialog());
            }
          }
          break;
        case IsmLiveActions.viewerTimeout:
          break;
      }
    } else {}
  }
}
