import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' show Client;

class IsmLiveHandler {
  const IsmLiveHandler._();

  static final RxBool _isMqttConnected = false.obs;
  static bool get isMqttConnected => _isMqttConnected.value;
  static set isMqttConnected(bool value) => _isMqttConnected.value = value;

  static bool isLogsEnabled = false;

  static VoidCallback? onLogout;

  static Future<void> initialize() async {
    Get.put(IsmLiveApiWrapper(Client()), permanent: true);
    Get.lazyPut(IsmLivePreferencesManager.new);
    unawaited(availableCameras().then((value) {
      IsmLiveUtility.cameras = value;
    }));

    await Get.put<IsmLiveDBWrapper>(IsmLiveDBWrapper(), permanent: true).init();
  }

  static EventStreamSubscription addListener(
    EventFunction listener,
  ) {
    if (!Get.isRegistered<IsmLiveMqttController>()) {
      IsmLiveMqttBinding().dependencies();
    }
    var mqttController = Get.find<IsmLiveMqttController>();
    return mqttController.actionStreamController.stream.listen(listener);
  }

  static Future<void> removeListener(EventFunction listener) async {
    var mqttController = Get.find<IsmLiveMqttController>();
    mqttController.actionListeners.remove(listener);
    await mqttController.actionStreamController.stream.drain();
    for (var listener in mqttController.actionListeners) {
      mqttController.actionStreamController.stream.listen(listener);
    }
  }

  static Future<void> dispose({
    bool? isStreaming,
    VoidCallback? logoutCallback,
    bool isLoading = true,
  }) async {
    if (isLoading) {
      IsmLiveUtility.showLoader();
    }

    await Future.wait([
      if ((isStreaming ?? false) &&
          Get.isRegistered<IsmLiveStreamController>()) ...[
        Get.find<IsmLiveStreamController>().unsubscribeUser(),
      ],
      if (Get.isRegistered<IsmLiveMqttController>()) ...[
        Get.find<IsmLiveMqttController>().unsubscribeTopics(),
        // Get.find<IsmLiveMqttController>().disconnect(),
      ],
    ]);

    if (Get.isRegistered<IsmLiveMqttController>()) {
      unawaited(Get.delete<IsmLiveMqttController>(force: true));
    }
    IsmLiveUtility.config = null;
    (logoutCallback ?? onLogout)?.call();

    if (isLoading) {
      IsmLiveUtility.closeLoader();
    }
  }
}
