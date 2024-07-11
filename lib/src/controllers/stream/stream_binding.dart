import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:get/get.dart';

class IsmLiveStreamBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IsmLiveStreamController>(
      () => IsmLiveStreamController(
        IsmLiveStreamViewModel(
          IsmLiveStreamRepository(
            Get.find(),
          ),
        ),
      ),
    );
    IsmLivePkBinding().dependencies();
  }
}
