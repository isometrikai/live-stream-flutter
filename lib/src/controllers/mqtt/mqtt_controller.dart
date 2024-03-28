import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/live_handler.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class IsmLiveMqttController extends GetxController {
  late String userTopic;

  late String userId;

  late String deviceId;

  List<String> topics = [];

  MqttServerClient? client;

  final Rx<IsmLiveConnectionState> _connectionState = IsmLiveConnectionState.disconnected.obs;
  IsmLiveConnectionState get connectionState => _connectionState.value;
  set connectionState(IsmLiveConnectionState value) => _connectionState.value = value;

  bool get isConnected => connectionState == IsmLiveConnectionState.connected;

  final actionStreamController = StreamController<Map<String, dynamic>>.broadcast();

  String _topicPrefix = '';

  IsmLiveConfigData? _config;

  IsmLiveStreamController get _streamController {
    if (!Get.isRegistered<IsmLiveStreamController>()) {
      IsmLiveStreamBinding().dependencies();
    }
    return Get.find<IsmLiveStreamController>();
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

  String? get _hostImageUrl => _streamController.hostDetails?.userProfileImageUrl;

  String? _viewerImageUrl(String viewerId) =>
      _streamController.streamViewersList.cast<IsmLiveViewerModel?>().firstWhere((e) => e!.userId == viewerId, orElse: () => null)?.imageUrl;

  String? _moderatorImageUrl(String moderatorId) =>
      _streamController.moderatorsList.cast<UserDetails?>().firstWhere((e) => e!.userId == moderatorId, orElse: () => null)?.profileUrl;

  String? _memberImageUrl(String moderatorId) => _streamController.streamMembersList
      .cast<IsmLiveMemberDetailsModel?>()
      .firstWhere((e) => e!.userId == moderatorId, orElse: () => null)
      ?.userProfileImageUrl;

  // ----------------- Functios -----------------------

  Future<void> setup(BuildContext context) async {
    _config = IsmLiveConfig.of(context);
    _topicPrefix = '/${_config!.projectConfig.accountId}/${_config!.projectConfig.projectId}';

    deviceId = _config!.projectConfig.deviceId;

    userId = _config!.userConfig.userId;

    userTopic = '$_topicPrefix/User/$userId';

    topics.addAll([userTopic]);

    IsmLiveLog('deviceId $deviceId');
    IsmLiveLog('userId $userId');
    IsmLiveLog('userTopic $userTopic');

    await initializeMqttClient();
    await connectClient();
  }

  Future<void> initializeMqttClient() async {
    client = MqttServerClient(
      _config!.mqttConfig.hostName,
      '$userId$deviceId',
    );

    client?.port = _config!.mqttConfig.port;
    client?.secure = false;
    client?.keepAlivePeriod = IsmLiveConstants.keepAlivePeriod;
    client?.onDisconnected = _onDisconnected;
    client?.onUnsubscribed = _onUnSubscribed;
    client?.onSubscribeFail = _onSubscribeFailed;
    client?.logging(on: IsmLiveHandler.isLogsEnabled);
    client?.autoReconnect = true;
    client?.pongCallback = _pong;
    client?.setProtocolV311();

    /// Add the successful connection callback
    client?.onConnected = _onConnected;
    client?.onSubscribed = _onSubscribed;

    client?.connectionMessage = MqttConnectMessage().startClean();
  }

  Future<void> connectClient() async {
    try {
      IsmLiveLog('username ${_config?.username}');
      IsmLiveLog('password ${_config?.password}');
      var res = await client?.connect(
        _config?.username,
        _config?.password,
      );
      IsmLiveLog.info('MQTT Response ${res?.state}');
      if (res?.state == MqttConnectionState.connected) {
        connectionState = IsmLiveConnectionState.connected;
        await subscribeTopics();
      }
    } on NoConnectionException catch (e) {
      IsmLiveLog.error('NoConnectionException - $e');
    } on SocketException catch (e) {
      IsmLiveLog.error('SocketException - $e');
    }
  }

  Future<void> subscribeTopics() async {
    try {
      for (var topic in topics) {
        if (client?.getSubscriptionsStatus(topic) == MqttSubscriptionStatus.doesNotExist) {
          client?.subscribe(topic, MqttQos.atMostOnce);
        }
      }
    } catch (e) {
      IsmLiveLog.error('Subscribe Error - $e');
    }
  }

  Future<void> subscribeStream(String streamId) async {
    try {
      IsmLiveLog(connectionState);
      if (connectionState != IsmLiveConnectionState.connected) {
        IsmLiveLog.info('MQTT is not connected, try to reconnect');
        await connectClient();
      }
      var topic = '$_topicPrefix/$streamId';
      if (client?.getSubscriptionsStatus(topic) == MqttSubscriptionStatus.doesNotExist) {
        client?.subscribe(topic, MqttQos.atMostOnce);
      }
    } catch (e) {
      IsmLiveLog.error('Subscribe Error - $e');
    }
  }

  Future<void> unsubscribeTopics() async {
    try {
      for (var topic in topics) {
        if (client?.getSubscriptionsStatus(topic) == MqttSubscriptionStatus.active) {
          client?.unsubscribe(topic);
        }
      }
    } catch (e) {
      IsmLiveLog.error('Unsubscribe Error - $e');
    }
  }

  Future<void> unsubscribeStream(String streamId) async {
    try {
      var topic = '$_topicPrefix/$streamId';
      if (client?.getSubscriptionsStatus(topic) == MqttSubscriptionStatus.active) {
        client?.unsubscribe(topic);
      }
    } catch (e) {
      IsmLiveLog.error('Subscribe Error - $e');
    }
  }

  void _pong() {
    IsmLiveLog.info('MQTT pong');
  }

  /// onDisconnected callback, it will be called when connection is breaked
  void _onDisconnected() {
    IsmLiveApp.isMqttConnected = false;
    connectionState = IsmLiveConnectionState.disconnected;
    if (client?.connectionStatus!.returnCode == MqttConnectReturnCode.noneSpecified) {
      IsmLiveLog.success('MQTT Disconnected');
    } else {
      IsmLiveLog.error('MQTT Disconnected');
    }
  }

  /// function call for disconnect host
  Future<void> disconnect() async {
    IsmLiveLog.success('Disconnected');
    client?.autoReconnect = false;
    client?.disconnect();
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
    IsmLiveHandler.isMqttConnected = true;
    client?.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) async {
      final recMess = c!.first.payload as MqttPublishMessage;

      var payload = jsonDecode(MqttPublishPayload.bytesToStringAsString(recMess.payload.message)) as Map<String, dynamic>;

      if (IsmLiveHandler.isLogsEnabled) {
        IsmLiveLog(IsmLiveUtility.jsonEncodePretty(payload));
        IsmLiveLog.success(payload['action']);
      }

      if (payload['action'] != null) {
        actionStreamController.add(payload);
        final action = IsmLiveActions.fromString(payload['action']);
        final streamId = payload['streamId'] as String;
        switch (action) {
          case IsmLiveActions.copublishRequestAccepted:
            final memberId = payload['userId'] as String? ?? '';
            final hostId = payload['initiatorId'] as String? ?? '';
            if (memberId == userId || hostId == userId) {
              _streamController.memberStatus = IsmLiveMemberStatus.requestApproved;
              final hostName = payload['initiatorName'] as String? ?? 'Host';
              final userName = payload['userName'] as String? ?? 'User';
              final message = IsmLiveMessageModel(
                streamId: streamId,
                senderName: hostName,
                senderIdentifier: '',
                senderProfileImageUrl: _hostImageUrl,
                senderId: hostId,
                messageType: IsmLiveMessageType.normal,
                messageId: '',
                body: memberId == userId ? '$hostName has accepted your Co-publisher Request' : 'You\'ve accepted $userName\'s Co-publisher Request',
                isEvent: true,
              );
              unawaited(_streamController.handleMessage(message));
              _updateStream([IsmLiveControlsWidget.updateId]);
            }
            break;
          case IsmLiveActions.copublishRequestAdded:
            final user = UserDetails.fromMap(payload);
            if (_streamController.isHost) {
              final message = IsmLiveMessageModel(
                streamId: streamId,
                senderName: user.userName,
                senderIdentifier: user.userIdentifier,
                senderProfileImageUrl: user.profileUrl,
                senderId: user.userId,
                messageType: IsmLiveMessageType.normal,
                messageId: '',
                body: '${user.userName} has requested for Co-publishing',
                isEvent: true,
              );
              unawaited(_streamController.handleMessage(message));
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
                streamId: streamId,
                senderName: hostName,
                senderProfileImageUrl: _hostImageUrl,
                senderIdentifier: '',
                senderId: hostId,
                messageType: IsmLiveMessageType.normal,
                messageId: '',
                body: memberId == userId ? '$hostName has rejected your Co-publisher Request' : 'You\'ve rejected $userName\'s Co-publisher Request',
                isEvent: true,
              );
              unawaited(_streamController.handleMessage(message));
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
              streamId: streamId,
              senderName: hostName,
              senderProfileImageUrl: memberProfilePic,
              senderIdentifier: memberIdentifier,
              senderId: hostId,
              messageType: IsmLiveMessageType.normal,
              messageId: '',
              body: body,
              isEvent: true,
            );
            unawaited(_streamController.handleMessage(message));
            _updateStream([IsmLiveControlsWidget.updateId]);
            break;
          case IsmLiveActions.memberLeft:
            var member = IsmLiveViewerModel.fromMap(payload);
            final message = IsmLiveMessageModel(
              streamId: streamId,
              senderName: member.userName,
              senderProfileImageUrl: _memberImageUrl(member.userId),
              senderIdentifier: member.identifier,
              senderId: member.userId,
              messageType: IsmLiveMessageType.normal,
              messageId: '',
              body: '${member.userName} has stopped publishing and left',
              isEvent: true,
            );
            unawaited(_streamController.handleMessage(message));
            _streamController.streamMembersList.removeWhere((e) => e.userId == userId);
            _updateStream();
            break;
          case IsmLiveActions.memberRemoved:
            final memberName = payload['memberName'] as String? ?? '';
            final memberId = payload['memberId'] as String? ?? '';
            final initiatorName = payload['initiatorName'] as String? ?? '';
            final initiatorId = payload['initiatorId'] as String? ?? '';
            if (streamId == _streamController.streamId) {
              final message = IsmLiveMessageModel(
                streamId: streamId,
                senderName: initiatorName,
                senderIdentifier: '',
                senderProfileImageUrl: _hostImageUrl,
                senderId: initiatorId,
                messageType: IsmLiveMessageType.normal,
                messageId: '',
                body: userId == initiatorId ? 'You\'ve remove $memberName as a member' : '$initiatorName has remove $memberName as a member',
                isEvent: true,
              );
              unawaited(_streamController.handleMessage(message));
              _updateStream([IsmLiveMembersSheet.updateId]);
              // _streamController.streamMembersList.removeWhere((e) => e.userId == memberId);
              // if (userId != initiatorId) {
              //   _disconnectRoom();
              // }
              if (memberId == userId) {
                unawaited(_streamController.unpublishTracks());
              }
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
              streamId: streamId,
              senderName: memberName,
              senderIdentifier: '',
              senderId: memberId,
              messageType: IsmLiveMessageType.normal,
              messageId: '',
              body: body,
              isEvent: true,
            );
            _streamController.streamViewersList.removeWhere((element) => element.userId == memberId);

            await _streamController.getStreamMembers(
              streamId: streamId,
            );
            unawaited(_streamController.handleMessage(message));
            _updateStream();

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

              await _streamController.handleMessage(message);
              _updateStream();
            }
            break;
          case IsmLiveActions.moderatorAdded:
            final moderatorId = payload['moderatorId'] as String? ?? '';
            final moderatorName = payload['moderatorName'] as String? ?? '';
            final moderatorIdentifier = payload['moderatorIdentifier'] as String? ?? '';
            final moderatorProfilePic = payload['moderatorProfilePic'] as String? ?? '';
            final message = IsmLiveMessageModel(
              streamId: streamId,
              senderName: moderatorName,
              senderIdentifier: moderatorIdentifier,
              senderProfileImageUrl: moderatorProfilePic,
              senderId: moderatorId,
              messageType: IsmLiveMessageType.normal,
              messageId: '',
              body: '$moderatorName is a moderator now',
              isEvent: true,
            );
            unawaited(_streamController.handleMessage(message));
            if (userId == moderatorId) {
              final hostName = payload['initiatorName'];
              IsmLiveUtility.showDialog(
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
                streamId: streamId,
                senderName: moderatorName,
                senderProfileImageUrl: _moderatorImageUrl(moderatorId),
                senderIdentifier: '',
                senderId: moderatorId,
                messageType: IsmLiveMessageType.normal,
                messageId: '',
                body: '$moderatorName has left',
                isEvent: true,
              );
              unawaited(_streamController.handleMessage(message));
              _streamController.moderatorsList.removeWhere((e) => e.userId == moderatorId);
              _streamController.streamViewersList.removeWhere((e) => e.userId == moderatorId);

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
                streamId: streamId,
                senderName: initiatorName,
                senderProfileImageUrl: _hostImageUrl,
                senderIdentifier: '',
                senderId: initiatorId,
                messageType: IsmLiveMessageType.normal,
                messageId: '',
                body: userId == initiatorId ? 'You\'ve remove $moderatorName' : '$initiatorName has remove $moderatorName',
                isEvent: true,
              );
              unawaited(_streamController.handleMessage(message));
              _streamController.moderatorsList.removeWhere((e) => e.userId == moderatorId);
              _streamController.streamViewersList.removeWhere((e) => e.userId == moderatorId);
              if (userId != initiatorId) {
                _disconnectRoom();
              }

              _updateStream();
              if (moderatorId == userId) {
                Get.back();
                IsmLiveUtility.showDialog(const IsmLiveKickoutDialog());
              }
            }
            break;

          case IsmLiveActions.publisherTimeout:
          case IsmLiveActions.publishStarted:
          case IsmLiveActions.publishStopped:
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
              _streamController.closeStreamView(false, fromMqtt: true);
            }
            _updateStreamListing();
            break;
          case IsmLiveActions.viewerJoined:
            if (streamId == _streamController.streamId) {
              var viewer = IsmLiveViewerModel.fromMap(payload);
              final message = IsmLiveMessageModel(
                streamId: streamId,
                senderProfileImageUrl: viewer.imageUrl,
                senderName: viewer.userName,
                senderIdentifier: viewer.identifier,
                senderId: viewer.userId,
                messageType: IsmLiveMessageType.normal,
                messageId: DateTime.now().toString(),
                body: '${viewer.userName} has joined',
                isEvent: true,
              );
              unawaited(_streamController.handleMessage(message));
              await _streamController.addViewers([viewer], false);
              _updateStream();
            }
            break;
          case IsmLiveActions.viewerLeft:
            if (streamId == _streamController.streamId) {
              var viewer = IsmLiveViewerModel.fromMap(payload);
              final message = IsmLiveMessageModel(
                streamId: streamId,
                senderName: viewer.userName,
                senderProfileImageUrl: _viewerImageUrl(viewer.userId),
                senderIdentifier: viewer.identifier,
                senderId: viewer.userId,
                messageType: IsmLiveMessageType.normal,
                messageId: DateTime.now().toString(),
                body: '${viewer.userName} has left',
                isEvent: true,
              );
              unawaited(_streamController.handleMessage(message));
              _streamController.streamViewersList.removeWhere((e) => e.userId == viewer.userId);
              if (viewer.userId != _streamController.user?.userId) {
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
                streamId: streamId,
                senderName: initiatorName,
                senderProfileImageUrl: _hostImageUrl,
                senderIdentifier: '',
                senderId: initiatorId,
                messageType: IsmLiveMessageType.normal,
                messageId: DateTime.now().toString(),
                body: userId == initiatorId ? 'You\'ve remove $viewerName' : '$initiatorName has remove $viewerName',
                isEvent: true,
              );
              unawaited(_streamController.handleMessage(message));
              _streamController.streamViewersList.removeWhere((e) => e.userId == viewerId);
              if (userId != initiatorId) {
                _disconnectRoom();
              }
              _updateStream();
              if (viewerId == userId) {
                Get.back();
                IsmLiveUtility.showDialog(const IsmLiveKickoutDialog());
              }
            }
            break;
          case IsmLiveActions.viewerTimeout:
            break;
        }
      } else {}
    });
  }
}
