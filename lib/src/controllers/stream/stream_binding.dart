import 'package:appscrip_live_stream_component/src/controllers/controllers.dart';
import 'package:appscrip_live_stream_component/src/repositories/repositories.dart';
import 'package:appscrip_live_stream_component/src/view_models/view_models.dart';
import 'package:get/get.dart';

class StreamBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StreamController>(
      () => StreamController(
        StreamViewModel(
          StreamRepository(),
        ),
      ),
    );
  }
}
