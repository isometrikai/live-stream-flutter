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
      IsmLiveLog(jsonEncode(payload));
      IsmLiveLog.success(payload['action']);
      // }

      if (payload['action'] != null) {
        actionStreamController.add(payload);
        final action = IsmLiveActions.fromString(payload['action']);
        final streamId = payload['streamId'];
        switch (action) {
          case IsmLiveActions.copublishRequestAccepted:
          case IsmLiveActions.copublishRequestAdded:
          case IsmLiveActions.copublishRequestDenied:
          case IsmLiveActions.copublishRequestRemoved:
          case IsmLiveActions.memberAdded:
          case IsmLiveActions.memberLeft:
          case IsmLiveActions.memberRemoved:
          case IsmLiveActions.messageRemoved:
          case IsmLiveActions.messageReplyRemoved:
          case IsmLiveActions.messageReplySent:
          case IsmLiveActions.messageSent:
          case IsmLiveActions.moderatorAdded:
          case IsmLiveActions.moderatorLeft:
          case IsmLiveActions.moderatorRemoved:
          case IsmLiveActions.profileSwitched:
          case IsmLiveActions.publisherTimeout:
          case IsmLiveActions.publishStarted:
          case IsmLiveActions.publishStopped:
            break;
          case IsmLiveActions.streamStartPresence:
            if (!Get.isRegistered<IsmLiveStreamController>()) {
              IsmLiveStreamBinding().dependencies();
            }
            var streamController = Get.find<IsmLiveStreamController>();
            unawaited(streamController.getStreams());
            break;
          case IsmLiveActions.streamStarted:
          case IsmLiveActions.streamStopped:
            break;
          case IsmLiveActions.viewerJoined:
          case IsmLiveActions.viewerLeft:
            if (!Get.isRegistered<IsmLiveStreamController>()) {
              IsmLiveStreamBinding().dependencies();
            }
            var streamController = Get.find<IsmLiveStreamController>();
            unawaited(streamController.getStreamViewer(streamId: streamId));
            break;
          case IsmLiveActions.viewerRemoved:
          case IsmLiveActions.viewerTimeout:
            break;
        }
      } else {}
    });
  }
}
