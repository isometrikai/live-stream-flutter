import 'package:appscrip_live_stream_component/src/controllers/controllers.dart';
import 'package:get/get.dart';

class IsmLiveMqttBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(IsmLiveMqttController());
  }
}
