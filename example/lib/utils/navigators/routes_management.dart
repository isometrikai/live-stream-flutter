import 'package:appscrip_live_stream_component_example/utils/navigators/app_pages.dart';
import 'package:get/get.dart';

abstract class RouteManagement {
  /// Go to the SignIn Screen
  static void goToLogin([bool fromSignup = false]) {
    if (fromSignup) {
      Get.back();
    } else {
      Get.offAllNamed<void>(
        AppRoutes.login,
      );
    }
  }

  static void goToSignUp() {
    Get.offNamed(AppRoutes.signup);
    // Get.offNamed(AppRoutes.signup);
  }

  /// Go to the Home Screen
  static void goToHome() {
    Get.offAllNamed<void>(
      AppRoutes.home,
    );
  }
}
