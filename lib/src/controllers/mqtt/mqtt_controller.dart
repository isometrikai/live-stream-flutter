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

  late IsmLiveConnectionState connectionState;

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

  void _updateStream() {
    IsmLiveUtility.updateLater(() {
      Future.delayed(const Duration(milliseconds: 100), () {
        _streamController.update([IsmLiveStreamView.updateId]);
      });
    });
  }

  // ----------------- Functios -----------------------

  Future<void> setup(BuildContext context) async {
    _config = IsmLiveConfig.of(context);
    _topicPrefix = '/${_config!.projectConfig.accountId}/${_config!.projectConfig.projectId}';

    deviceId = _config!.projectConfig.deviceId;

    userId = _config!.userConfig.userId;

    userTopic = '$_topicPrefix/User/$userId';

    topics.addAll([userTopic]);

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
    connectionState = IsmLiveConnectionState.subscribed;
    IsmLiveLog.success('MQTT Subscribed - $topic');
  }

  /// onUnsubscribed callback, it will be called when connection successfully unsubscribes to certain topic
  void _onUnSubscribed(String? topic) {
    connectionState = IsmLiveConnectionState.unsubscribed;
    IsmLiveLog.success('MQTT Unsubscribed - $topic');
  }

  /// onSubscribeFailed callback, it will be called when connection fails to subscribe to certain topic
  void _onSubscribeFailed(String topic) {
    connectionState = IsmLiveConnectionState.unsubscribed;
    IsmLiveLog.error('MQTT Subscription failed - $topic');
  }

  /// onConnected callback, it will be called when connection is established
  void _onConnected() {
    IsmLiveHandler.isMqttConnected = true;
    client?.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) async {
      final recMess = c!.first.payload as MqttPublishMessage;

      var payload = jsonDecode(MqttPublishPayload.bytesToStringAsString(recMess.payload.message)) as Map<String, dynamic>;

      // if (IsmLiveHandler.isLogsEnabled) {
      IsmLiveLog(IsmLiveUtility.jsonEncodePretty(payload));
      IsmLiveLog.success(payload['action']);
      // }

      if (payload['action'] != null) {
        actionStreamController.add(payload);
        final action = IsmLiveActions.fromString(payload['action']);
        final streamId = payload['streamId'] as String;
        switch (action) {
          case IsmLiveActions.copublishRequestAccepted:
          case IsmLiveActions.copublishRequestAdded:
          case IsmLiveActions.copublishRequestDenied:
          case IsmLiveActions.copublishRequestRemoved:
          case IsmLiveActions.memberAdded:
          case IsmLiveActions.memberLeft:
          case IsmLiveActions.memberRemoved:
            break;
          case IsmLiveActions.messageRemoved:
            if (_streamController.streamId == streamId) {
              final messageId = payload['messageId'] as String?;
              if (messageId == null) {
                break;
              }
              await _streamController.messageRemoved(messageId);
              _updateStream();
            }
            break;
          case IsmLiveActions.messageReplyRemoved:
          case IsmLiveActions.messageReplySent:
            break;
          case IsmLiveActions.messageSent:
            if (_streamController.streamId == streamId) {
              final message = IsmLiveMessageModel.fromMap(payload);
              await _streamController.handleMessage(message);
              _updateStream();
            }
            break;
          case IsmLiveActions.moderatorAdded:
            final moderatorId = payload['moderatorId'] as String?;
            IsmLiveLog(userId);
            IsmLiveLog.info(moderatorId);
            if (userId == moderatorId) {}
            break;
          case IsmLiveActions.moderatorLeft:
          case IsmLiveActions.moderatorRemoved:
          case IsmLiveActions.profileSwitched:
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
            _streamController.closeStreamView(initiatorId == userId);
            _updateStreamListing();
            break;
          case IsmLiveActions.viewerJoined:
            if (streamId == _streamController.streamId) {
              var viewer = IsmLiveViewerModel.fromMap(payload);
              await _streamController.addViewers([viewer]);
              _updateStream();
            }
            break;
          case IsmLiveActions.viewerLeft:
          case IsmLiveActions.viewerRemoved:
            final viewerId = payload['viewerId'] as String?;
            if (streamId == _streamController.streamId) {
              _streamController.streamViewersList.removeWhere((e) => e.userId == viewerId);
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
