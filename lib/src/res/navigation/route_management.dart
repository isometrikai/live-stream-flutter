import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

abstract class IsLiveRouteManagement {
  // static void goToMyMeetingsView(IsmLiveStreamConfig configuration) {
  //   Get.toNamed<void>(IsLiveRoutes.myMeetingsView, arguments: configuration);
  // }

  static void goToCreateMeetingScreen() {
    Get.toNamed(IsmLiveRoutes.createMeetingScreen);
  }

  static Future<void> goToRoomPage(
    Room room,
    EventsListener<RoomEvent> listener,
    String meetingId,
    bool audioCallOnly,
  ) async {
    await Get.toNamed(IsmLiveRoutes.roomPage, arguments: {
      'room': room,
      'listener': listener,
      'meetingId': meetingId,
      'audioCallOnly': audioCallOnly,
    });
  }

  static Future<void> goToStreamView({
    required Room room,
    required EventsListener<RoomEvent> listener,
    required String streamId,
    bool audioCallOnly = false,
  }) async {
    await Get.toNamed(
      IsmLiveRoutes.streamView,
      arguments: {
        'room': room,
        'listener': listener,
        'streamId': streamId,
        'audioCallOnly': audioCallOnly,
      },
    );
  }

  static void goToSearchUserScreen() {
    Get.toNamed<void>(
      IsmLiveRoutes.searchUserScreen,
    );
  }

  static void goToMyMeetingsView() {
    Get.offAndToNamed<void>(
      IsmLiveRoutes.myMeetingsView,
    );
  }
}
