import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:livekit_client/livekit_client.dart';

abstract class IsmLiveRouteManagement {
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
    required RoomListener listener,
    required bool isHost,
    required bool isScrolling,
    required bool isNewStream,
    required Room room,
    required String streamId,
    bool isInteractive = false,
    bool isSchedule = false,
    String? streamImage,
  }) async {
    var arguments = {
      'room': room,
      'listener': listener,
      'streamImage': streamImage,
      'streamId': streamId,
      'isHost': isHost,
      'isNewStream': isNewStream,
      'isScrolling': isScrolling,
      'isInteractive': isInteractive,
      'isSchedule': isSchedule,
    };

    if (isHost && isNewStream) {
      await Get.offNamed(
        IsmLiveRoutes.streamView,
        arguments: arguments,
      );
    } else {
      await Get.toNamed(
        IsmLiveRoutes.streamView,
        arguments: arguments,
      );
    }
  }

  static void goToSearchUserScreen() {
    Get.toNamed<void>(
      IsmLiveRoutes.searchUserScreen,
    );
  }

  static void goToEndStreamView(String streamId) {
    if (Get.currentRoute == IsmLiveRoutes.endStream) {
      return;
    }

    Get.offAndToNamed<void>(
      IsmLiveRoutes.endStream,
      arguments: {
        'streamId': streamId,
      },
    );
  }

  static void goToGoLiveView({bool popPrevious = false}) {
    if (popPrevious) {
      Get.offAndToNamed<void>(
        IsmLiveRoutes.goLive,
      );
    } else {
      Get.toNamed<void>(
        IsmLiveRoutes.goLive,
      );
    }
  }

  static void goToMyMeetingsView() {
    Get.offAndToNamed<void>(
      IsmLiveRoutes.myMeetingsView,
    );
  }

  static Future<XFile?> goToCamera(
    bool isPhotoRequired,
    bool isOnlyImage,
  ) async {
    if (IsmLiveUtility.cameras.isNotEmpty) {
      return await Get.to<XFile>(
        CameraScreenView(
          isPhotoRequired: isPhotoRequired,
          isOnlyImage: isOnlyImage,
        ),
      );
    } else {
      await IsmLiveUtility.showInfoDialog(
        IsmLiveResponseModel.message('Camera Not Available'),
      );
      return null;
    }
  }

  static void goToRestreamView() {
    Get.toNamed(IsmLiveRoutes.restreamView);
  }

  static Future<void> goToRestreamSettingsView(IsmLiveRestreamType type) async {
    await Get.toNamed(IsmLiveRoutes.restreamSettingsView, arguments: type);
  }

  static void goToAddProduct() {
    Get.toNamed<void>(
      IsmLiveRoutes.addProduct,
    );
  }

  static void goToTagProduct() {
    Get.toNamed<void>(
      IsmLiveRoutes.tagProduct,
    );
  }

  static void goToCoinsPlanWallet() =>
      Get.toNamed(IsmLiveRoutes.coinsPlansWalletView);

  static void goToCoinTransaction() =>
      Get.toNamed(IsmLiveRoutes.coinTransactionsView);
}
