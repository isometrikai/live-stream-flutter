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
    unawaited(availableCameras().then((value) {
      IsmLiveUtility.cameras = value;
    }));

    Get.put(IsmLiveApiWrapper(Client()));
    Get.lazyPut(IsmLivePreferencesManager.new);
    unawaited(Get.put<IsmLiveDBWrapper>(IsmLiveDBWrapper()).init());
  }

  static MapStreamSubscription addListener(
    MapFunction listener,
  ) {
    if (!Get.isRegistered<IsmLiveMqttController>()) {
      IsmLiveMqttBinding().dependencies();
    }
    var mqttController = Get.find<IsmLiveMqttController>();
    return mqttController.actionStreamController.stream.listen(listener);
  }

  static Future<void> logout(
      {bool isStreaming = true, VoidCallback? logoutCallback}) async {
    IsmLiveUtility.showLoader();
    if (isStreaming) {
      var isUnsubscribed =
          await Get.find<IsmLiveStreamController>().unsubscribeUser();
      if (!isUnsubscribed) {
        return;
      }
      var mqttController = Get.find<IsmLiveMqttController>();
      await mqttController.unsubscribeTopics();
      await Get.delete<IsmLiveMqttController>(force: true);
    }
    (logoutCallback ?? onLogout)?.call();
    IsmLiveUtility.closeLoader();
  }
}
