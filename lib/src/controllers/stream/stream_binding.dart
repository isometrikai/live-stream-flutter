import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:get/get.dart';

class StreamBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StreamController>(
      () => StreamController(
        StreamViewModel(
          StreamRepository(
            IsmLiveApiWrapper(),
          ),
        ),
      ),
    );
  }
}
