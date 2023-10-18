import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

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

  static Future<void> goToRoomPage(
    Room room,
    EventsListener<RoomEvent> listener,
  ) async {
    await Get.toNamed(IsLiveRoutes.roomPage, arguments: {
      'room': room,
      'listener': listener,
    });
  }

  /// Go to the Home Screen
  static void goToSearchUserScreen() {
    Get.toNamed<void>(
      IsLiveRoutes.searchUserScreen,
    );
  }
}
