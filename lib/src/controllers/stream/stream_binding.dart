import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' show Client;

class IsmLiveStreamBinding implements Bindings {
  @override
  void dependencies() {
    // Register IsmLiveApiWrapper if not already registered
    if (!Get.isRegistered<IsmLiveApiWrapper>()) {
      Get.lazyPut<IsmLiveApiWrapper>(() => IsmLiveApiWrapper(Client()));
    }
    Get.put<IsmLiveStreamController>(
      IsmLiveStreamController(
        IsmLiveStreamViewModel(
          IsmLiveStreamRepository(
            Get.find(),
          ),
        ),
      ),
      permanent: true,
    );
    IsmLivePkBinding().dependencies();
  }
}
