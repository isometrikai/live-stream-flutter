import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:get/get.dart';

class IsmLiveBroadcastBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IsmLiveBroadcastController>(
      () => IsmLiveBroadcastController(
        IsmLiveBroadcastViewModel(
          IsmLiveBroadcastRepository(
            Get.find(),
          ),
        ),
      ),
    );
  }
}
