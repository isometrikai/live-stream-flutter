import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:get/get.dart';

class IsmLiveCallingBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IsmLiveCallingController>(
      () => IsmLiveCallingController(
        IsmLiveCallingViewModel(
          IsmLiveCallingRepository(
            Get.find(),
          ),
        ),
      ),
    );
  }
}
