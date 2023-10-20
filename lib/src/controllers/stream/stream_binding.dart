import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' show Client;

class IsmLiveStreamBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IsmLiveStreamController>(
      () => IsmLiveStreamController(
        IsmLiveStreamViewModel(
          IsmLiveStreamRepository(
            Client(),
          ),
        ),
      ),
    );
  }
}
