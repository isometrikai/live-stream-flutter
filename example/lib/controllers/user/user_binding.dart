import 'package:appscrip_live_stream_component_example/controllers/user/user.dart';
import 'package:get/get.dart';

class UserBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<UserController>(
      UserController(),
      // permanent: true,
    );
  }
}
