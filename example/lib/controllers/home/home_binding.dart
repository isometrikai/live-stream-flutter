import 'package:appscrip_live_stream_component_example/controllers/home/home_controller.dart';
import 'package:appscrip_live_stream_component_example/repositories/repositories.dart';
import 'package:appscrip_live_stream_component_example/view_models/view_models.dart';
import 'package:get/get.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(
      () => HomeController(
        HomeViewModel(
          HomeRepository(),
        ),
      ),
    );
  }
}
