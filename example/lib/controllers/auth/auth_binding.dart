import 'package:appscrip_live_stream_component_example/controllers/controllers.dart';
import 'package:appscrip_live_stream_component_example/repositories/repositories.dart';
import 'package:appscrip_live_stream_component_example/view_models/view_models.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' show Client;

class AuthBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(
      AuthController(
        AuthViewModel(
          AuthRepository(
            Client(),
          ),
        ),
      ),
    );
  }
}
