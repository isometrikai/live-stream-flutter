import 'dart:async';
import 'dart:convert';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/controllers/mqtt/mqtt_helper.dart';
import 'package:appscrip_live_stream_component/src/live_handler.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class IsmLiveMqttController extends GetxController {
  final _mqttHelper = MqttHelper();

  /// Prefix, user ids, and [_topics] are prepared once.
  bool _layoutReady = false;

  /// True after a successful [MqttHelper.initialize] for this session.
  bool _mqttInitialized = false;

  /// Full manual re-init (second [initialize]) in progress.
  bool _manualReconnectInFlight = false;

  late String userTopic;
  late String userId;
  late String deviceId;

  final List<String> _topics = [];
  final actionStreamController = StreamController<EventModel>.broadcast();
  var actionListeners = <EventFunction>[];

  String _topicPrefix = '';
  IsmLiveConfigData? _config;

  StreamSubscription<bool>? _mqttConnectionSub;
  StreamSubscription<EventModel>? _mqttEventSub;

  /// Broker handshake retries per connect (maps to mqtt_client maxConnectionAttempts).
  static const int _maxHandshakeAttempts = 100;

  /// Grace period before surfacing a disconnected state, preventing UI flicker
  /// from brief network hiccups where auto-reconnect recovers quickly.
  static const Duration _disconnectDebounce = Duration(seconds: 3);

  Timer? _disconnectDebounceTimer;

  /// Keeps [IsmLiveApp.isMqttConnected] aligned with the broker. Pass [connected]
  /// when known from callbacks/stream; otherwise reads [MqttHelper.isConnected].
  ///
  /// Disconnected (`false`) transitions are debounced by [_disconnectDebounce] so
  /// that transient auto-reconnect cycles do not flicker the UI indicator.
  /// Connected (`true`) transitions are applied immediately.
  void _publishMqttConnectivityToApp([bool? connected]) {
    final isConnected = connected ?? _mqttHelper.isConnected;
    _disconnectDebounceTimer?.cancel();
    _disconnectDebounceTimer = null;
    if (isConnected) {
      IsmLiveApp.isMqttConnected = true;
    } else {
      _disconnectDebounceTimer = Timer(
        _disconnectDebounce,
        () => IsmLiveApp.isMqttConnected = false,
      );
    }
  }

  /// Sets disconnected state immediately, bypassing the debounce. Use for
  /// intentional disconnects or unrecoverable failures.
  void _setDisconnectedImmediate() {
    _disconnectDebounceTimer?.cancel();
    _disconnectDebounceTimer = null;
    IsmLiveApp.isMqttConnected = false;
  }

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

  int? _viewersCountFromPayload(Map<String, dynamic> payload) {
    final v = payload['viewersCount'];
    if (v == null) {
      return null;
    }
    if (v is int) {
      return v;
    }
    if (v is num) {
      return v.toInt();
    }
    return null;
  }

  void _syncLiveViewersCountFromPayload(Map<String, dynamic> payload) {
    final c = _viewersCountFromPayload(payload);
    if (c != null) {
      _streamController.liveStreamViewersCount.value = c;
    }
  }

  // --- MQTT -----------------------------------------------------------------

  MqttConfig _buildMqttConfig() {
    final c = _config!;
    return MqttConfig(
      serverConfig: ServerConfig.fromMap(c.mqttConfig.toMap()),
      projectConfig: ProjectConfig(
        deviceId: deviceId,
        username: c.username ?? '',
        password: c.password ?? '',
        userIdentifier: userId,
      ),
      enableLogging: true,
      autoReconnect: true,
      maxAutoReconnectRetry: _maxHandshakeAttempts,
      webSocketConfig: c.socketConfig != null
          ? WebSocketConfig.fromMap(c.socketConfig!.toMap())
          : null,
      secure: c.secure,
    );
  }

  /// Cancels previous listeners; required after each [MqttHelper.initialize]
  /// because the helper replaces its internal stream controllers.
  void _attachMqttStreamListeners() {
    _mqttConnectionSub?.cancel();
    _mqttEventSub?.cancel();
    _mqttConnectionSub =
        _mqttHelper.onConnectionChange(_publishMqttConnectivityToApp);
    _mqttEventSub = _mqttHelper.onEvent(_onEvent);
    // Broadcast stream does not replay; first connect may have emitted before subscribe.
    _publishMqttConnectivityToApp();
  }

  Future<void> _runMqttInitialize() async {
    await _mqttHelper.initialize(
      _buildMqttConfig(),
      callbacks: MqttCallbacks(
        onConnected: _onConnected,
        onDisconnected: _onDisconnected,
        onSubscribeFail: _onSubscribeFailed,
        onSubscribed: _onSubscribed,
        onUnsubscribed: _onUnSubscribed,
        pongCallback: _pong,
      ),
      autoSubscribe: true,
      topics: List<String>.from(_topics),
    );
    _attachMqttStreamListeners();
    _mqttInitialized = true;
  }

  Future<void> setup({
    List<String>? topics,
    List<String>? topicChannels,
    required bool shouldInitializeMqtt,
  }) async {
    if (_layoutReady) {
      if (shouldInitializeMqtt && !_mqttInitialized) {
        try {
          await _runMqttInitialize();
        } catch (e, st) {
          IsmLiveLog.error('MQTT initialize failed: $e', st);
          _setDisconnectedImmediate();
        }
      }
      return;
    }

    _config = IsmLiveUtility.config;
    _topicPrefix =
        '/${_config!.projectConfig.accountId}/${_config!.projectConfig.projectId}';

    deviceId = _config!.projectConfig.deviceId;
    userId = _config!.userConfig.userId;
    userTopic = '$_topicPrefix/User/$userId';

    final channelTopics =
        topicChannels?.map((e) => '$_topicPrefix/$e/$userId').toList();

    _topics
      ..clear()
      ..addAll([
        ...?topics,
        ...?channelTopics,
        userTopic,
      ]);

    _layoutReady = true;

    if (!shouldInitializeMqtt) {
      return;
    }

    try {
      debugPrint(
        'IsmLiveApp: ServerConfig: ${ServerConfig.fromMap(_config!.mqttConfig.toMap())}',
      );
      debugPrint(
        'IsmLiveApp: userId: $userId username: ${_config?.username} password: ${_config?.password} deviceId: $deviceId',
      );
      await _runMqttInitialize();
    } catch (e, st) {
      IsmLiveLog.error('MQTT initialize failed: $e', st);
      _mqttInitialized = false;
      _setDisconnectedImmediate();
    }
  }

  Future<void> subscribeStream(String streamId) async {
    try {
      if (!_layoutReady) {
        IsmLiveLog.error('subscribeStream called before setup()');
        return;
      }
      if (!IsmLiveApp.isMqttConnected && !_manualReconnectInFlight) {
        IsmLiveLog.info(
          'MQTT not connected; starting full re-init in background',
        );
        unawaited(reconnect());
      }
      final topic = '$_topicPrefix/$streamId';
      if (!_topics.contains(topic)) {
        _topics.add(topic);
      }
      if (_mqttInitialized) {
        _mqttHelper.subscribeTopic(topic);
      }
    } catch (e) {
      IsmLiveLog.error('Subscribe Error - $e');
    }
  }

  Future<void> unsubscribeTopics() async {
    try {
      IsmLiveLog.info('Unsubscribing topics: $_topics');
      if (_mqttInitialized) {
        _mqttHelper.unsubscribeTopics(List<String>.from(_topics));
      }
    } catch (e) {
      IsmLiveLog.error('Unsubscribe Error - $e');
    }
  }

  Future<void> unsubscribeStream(String streamId) async {
    try {
      final topic = '$_topicPrefix/$streamId';
      if (_mqttInitialized) {
        _mqttHelper.unsubscribeTopic(topic);
      }
      _topics.remove(topic);
    } catch (e) {
      IsmLiveLog.error('Unsubscribe stream error - $e');
    }
  }

  Future<void> disconnect() async {
    _mqttConnectionSub?.cancel();
    _mqttEventSub?.cancel();
    _mqttConnectionSub = null;
    _mqttEventSub = null;
    _mqttHelper.disconnect();
    _mqttInitialized = false;
    _setDisconnectedImmediate();
  }

  void _pong() {
    IsmLiveLog.info('MQTT pong');
  }

  void _onDisconnected() {
    _publishMqttConnectivityToApp(false);
    IsmLiveLog.info('MQTT disconnected (helper handles auto-reconnect)');
  }

  void _onSubscribed(String topic) {
    IsmLiveLog.success('MQTT Subscribed - $topic');
  }

  void _onUnSubscribed(String? topic) {
    IsmLiveLog.success('MQTT Unsubscribed - $topic');
  }

  void _onSubscribeFailed(String topic) {
    IsmLiveLog.error('MQTT Subscription failed - $topic');
  }

  void _onConnected() {
    _publishMqttConnectivityToApp(true);
    IsmLiveLog.success('MQTT connected');
  }

  /// After app resume, nudge broker auto-reconnect when the client is already
  /// disconnected or faulted. Does not replace full `reconnect()` re-init.
  void nudgeReconnectAfterAppResume() {
    if (!_layoutReady || !_mqttInitialized || _manualReconnectInFlight) {
      return;
    }
    _mqttHelper.requestAutoReconnectIfDisconnected();
  }

  /// Full client re-init. Use after [disconnect], or when the socket is dead
  /// and you need a fresh [initialize] (helper replaces stream controllers).
  Future<bool> reconnect() async {
    if (!_layoutReady || _config == null) {
      IsmLiveLog.error('MQTT reconnect: setup() not completed');
      return false;
    }
    if (_manualReconnectInFlight) {
      IsmLiveLog.info('MQTT reconnect already in progress');
      return false;
    }

    _manualReconnectInFlight = true;
    try {
      IsmLiveLog.info('MQTT manual re-init requested');
      await _runMqttInitialize();
      return IsmLiveApp.isMqttConnected;
    } catch (e, st) {
      IsmLiveLog.error('MQTT re-init failed: $e', st);
      _mqttInitialized = false;
      _setDisconnectedImmediate();
      return false;
    } finally {
      _manualReconnectInFlight = false;
    }
  }

  /// Kept for API compatibility. Handshake retries use [_maxHandshakeAttempts]
  /// on [MqttConfig]; there is no app-level reconnect timer.
  void setAutoReconnect(bool enabled) {
    IsmLiveLog.info(
      'MQTT: setAutoReconnect($enabled) — broker reconnect is controlled by '
      'MqttConfig.autoReconnect (currently always true in _buildMqttConfig).',
    );
  }

  void setReconnectionConfig({
    int? maxAttempts,
    Duration? initialDelay,
    Duration? maxDelay,
  }) {
    if (maxAttempts != null) {
      IsmLiveLog.info(
        'MQTT: use MqttConfig.maxAutoReconnectRetry / code constant '
        '_maxHandshakeAttempts instead of app-level timers',
      );
    }
    if (initialDelay != null || maxDelay != null) {
      IsmLiveLog.info(
        'MQTT: reconnect spacing is handled by mqtt_client connectTimeoutPeriod',
      );
    }
  }

  bool get isReconnecting => _manualReconnectInFlight;

  int get reconnectAttempts => 0;

  int get maxReconnectAttempts => 0;

  Map<String, dynamic> getReconnectionStatus() => {
        'isReconnecting': _manualReconnectInFlight,
        'reconnectAttempts': reconnectAttempts,
        'maxReconnectAttempts': maxReconnectAttempts,
        'mqttInitialized': _mqttInitialized,
        'isConnected': IsmLiveApp.isMqttConnected,
      };

  void publishHeartMessage({
    required String streamId,
    required int likeCount,
  }) {
    try {
      if (!_mqttInitialized || !IsmLiveApp.isMqttConnected) {
        IsmLiveLog.error(
            'publishHeartMessage: MQTT not connected, skipping publish');
        return;
      }

      final user = _streamController.user;
      final config = _streamController.configuration;
      if (user == null || config == null) {
        IsmLiveLog.error('publishHeartMessage: user or config is null');
        return;
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      final payload = <String, dynamic>{
        'action': 'messageSent',
        'streamId': streamId,
        'sentAt': now,
        'senderProfileImageUrl': user.userProfileImageUrl,
        'senderName': user.userName,
        'senderIdentifier': user.userIdentifier,
        'senderId': user.userId,
        'searchableTags': <String>[],
        'replyMessage': false,
        'repliesCount': 0,
        'metaData': <String, dynamic>{
          'likeCount': likeCount,
        },
        'messageType': IsmLiveMessageType.heart.value,
        'messageId': '${user.userId}_heart_$now',
        'membersCount': _streamController.streamMembersList.length,
        'viewersCount':
            _streamController.liveStreamViewersCount.value ?? 0,
        'deviceId': config.projectConfig.deviceId,
        'customType': 'like',
        'body': '',
      };

      final topic = '$_topicPrefix/$streamId';
      final jsonStr = jsonEncode(payload);
      _mqttHelper.publishMessage(message: jsonStr, pubTopic: topic);

      IsmLiveLog.info(
          'publishHeartMessage: published $likeCount hearts on $topic');
    } catch (e, st) {
      IsmLiveLog.error('publishHeartMessage failed: $e', st);
    }
  }

  void handleEventsExternally(EventModel payload) => _onEvent(payload);

  @override
  void onClose() {
    _disconnectDebounceTimer?.cancel();
    _mqttConnectionSub?.cancel();
    _mqttEventSub?.cancel();
    unawaited(disconnect());
    if (!actionStreamController.isClosed) {
      actionStreamController.close();
    }
    super.onClose();
  }

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
              payload: '',
            );

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
              payload: '',
            );
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
              payload: '',
            );
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
            _streamController.update([
              IsmLiveStreamView.updateId,
              IsmLiveControlsWidget.updateId,
            ]);
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
            body: message.body,
            title: 'Co-publishing added',
            payload: '',
          );

          unawaited(_streamController.handleMessage(message: message));
          _updateStream([IsmLiveControlsWidget.updateId]);
          if (memberId == userId) {
            _streamController.scheduleAutoOpenCopublishInviteSheetForViewer();
          }
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
          await Future.delayed(const Duration(milliseconds: 500));
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
                  : '$initiatorName has removed $memberName as a member',
              isEvent: true,
            );
            unawaited(_streamController.handleMessage(message: message));
            _streamController.streamMembersList
                .removeWhere((e) => e.userId == memberId);
            if (userId != initiatorId && userId == memberId) {
              await _streamController.disconnectRoom();
              IsmLiveRoute.pop();
            }
            await Future.delayed(const Duration(milliseconds: 300));
            _updateStream();
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
        case IsmLiveActions.messageReplyRemoved:
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
        case IsmLiveActions.messageReplySent:
        case IsmLiveActions.messageSent:
          if (_streamController.streamId == streamId) {
            final message = IsmLiveMessageModel.fromMap(payload);

            await _streamController.handleMessage(
              message: message,
              payload: payload,
            );

            _updateStream();
          }
          break;
        case IsmLiveActions.moderatorAdded:
          if (_streamController.streamId == streamId) {
            final moderatorId = payload['moderatorId'] as String? ?? '';
            final moderatorName = payload['moderatorName'] as String? ?? '';
            final moderatorIdentifier =
                payload['moderatorIdentifier'] as String? ?? '';
            final moderatorProfilePic =
                payload['moderatorProfilePic'] as String? ?? '';
            final initiatorName = payload['initiatorName'] as String? ?? '';

            final moderatorExists = _streamController.moderatorsList
                .any((e) => e.userId == moderatorId);
            if (!moderatorExists) {
              _streamController.moderatorsList.add(
                UserDetails(
                  userId: moderatorId,
                  userName: moderatorName,
                  userIdentifier: moderatorIdentifier,
                  userProfileImageUrl: moderatorProfilePic,
                ),
              );
            }

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
              IsmLiveUtility.openBottomSheet(
                IsmLiveModeratorBottomSheet(
                  type: IsmLiveModeratorBottomSheetType.addedToModerator,
                  moderatorName: moderatorName,
                  initiatorName: initiatorName,
                  streamId: streamId,
                ),
                isDismissible: true,
                isScrollController: true,
              );
            }
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
                  : '$initiatorName has removed $moderatorName from moderator',
              isEvent: true,
            );
            unawaited(_streamController.handleMessage(message: message));
            _streamController.moderatorsList
                .removeWhere((e) => e.userId == moderatorId);
            if (moderatorId == userId) {
              _streamController.userRole?.leaveModeration();
            }
            _updateStream();
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
          if (IsmLiveDelegate.streamListingRefreshCallback != null) {
            IsmLiveDelegate.streamListingRefreshCallback!(
              'streamStartPresence',
              null,
              payload,
            );
          } else {
            unawaited(_streamController.getStreams());
          }
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
          } else {
            if (streamId == _streamController.streamId) {
              _disconnectRoom();
              _streamController.closeStreamView(true,
                  streamId: streamId, fromMqtt: true);
            }
          }

          if (IsmLiveDelegate.streamListingRefreshCallback != null) {
            IsmLiveDelegate.streamListingRefreshCallback!(
              'streamStopped',
              streamId,
              payload,
            );
          } else {
            _updateStreamListing();
          }
          break;
        case IsmLiveActions.viewerJoined:
          if (streamId == _streamController.streamId) {
            _syncLiveViewersCountFromPayload(payload);
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
            }
            _updateStream();
          }
          break;
        case IsmLiveActions.viewerLeft:
          if (streamId == _streamController.streamId) {
            _syncLiveViewersCountFromPayload(payload);
            var viewer = IsmLiveViewerModel.fromMap(payload);
            final message = IsmLiveMessageModel(
              streamId: streamId!,
              senderName: viewer.userName,
              senderProfileImageUrl:
                  _viewerImageUrl(viewer.userId) ?? viewer.imageUrl,
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
            }
            _updateStream();
          }
          break;
        case IsmLiveActions.viewerRemoved:
          final viewerId = payload['viewerId'] as String? ?? '';
          final viewerName = payload['viewerName'] as String? ?? '';
          final initiatorName = payload['initiatorName'] as String? ?? '';
          final initiatorId = payload['initiatorId'] as String? ?? '';
          if (streamId == _streamController.streamId) {
            _syncLiveViewersCountFromPayload(payload);
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
                  : '$initiatorName has removed $viewerName',
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
              IsmLiveUtility.popUntilStreamView();
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
