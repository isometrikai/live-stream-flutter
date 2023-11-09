import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

abstract class IsLiveRouteManagement {
  // static void goToMyMeetingsView(IsmLiveStreamConfig configuration) {
  //   Get.toNamed<void>(IsLiveRoutes.myMeetingsView, arguments: configuration);
  // }

  static void goToCreateMeetingScreen() {
    Get.toNamed(IsLiveRoutes.createMeetingScreen);
  }

  static Future<void> goToRoomPage(
    Room room,
    EventsListener<RoomEvent> listener,
    String meetingId,
  ) async {
    await Get.toNamed(IsLiveRoutes.roomPage, arguments: {
      'room': room,
      'listener': listener,
      'meetingId': meetingId,
    });
  }

  /// Go to the Home Screen
  static void goToSearchUserScreen() {
    Get.toNamed<void>(
      IsLiveRoutes.searchUserScreen,
    );
  }
}
