import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:get/get.dart';

class IsmLiveMeetingBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IsmLiveMeetingController>(
      () => IsmLiveMeetingController(
        IsmLiveMeetingViewModel(
          IsmLiveMeetingRepository(
            Get.find(),
          ),
        ),
      ),
    );
  }
}
