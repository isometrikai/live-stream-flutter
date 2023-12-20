import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:get/get.dart';

class IsmLiveHandler {
  const IsmLiveHandler._();

  static final RxBool _isMqttConnected = false.obs;
  static bool get isMqttConnected => _isMqttConnected.value;
  static set isMqttConnected(bool value) => _isMqttConnected.value = value;

  static bool isLogsEnabled = false;

  static MapStreamSubscription addListener(
    MapFunction listener,
  ) {
    if (!Get.isRegistered<IsmLiveMqttController>()) {
      IsmLiveMqttBinding().dependencies();
    }
    var mqttController = Get.find<IsmLiveMqttController>();
    return mqttController.actionStreamController.stream.listen(listener);
  }
}
