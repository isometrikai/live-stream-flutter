import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:get/get.dart';

abstract class IsLiveRouteManagement {
  /// Go to the SignIn Screen
  static void goToMyMeetingsView() {
    Get.toNamed<void>(
      IsLiveRoutes.myMeetingsView,
    );
  }

  static void goToCreateMeetingScreen() {
    Get.toNamed(IsLiveRoutes.createMeetingScreen);
    // Get.offNamed(AppRoutes.signup);
  }

  /// Go to the Home Screen
  static void goToSearchUserScreen() {
    Get.toNamed<void>(
      IsLiveRoutes.searchUserScreen,
    );
  }
}
