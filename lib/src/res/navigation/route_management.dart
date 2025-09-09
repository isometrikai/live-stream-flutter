import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/controllers/coins_plans_wallet_controller/coins_plans_wallet_binding.dart';
import 'package:appscrip_live_stream_component/src/res/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:livekit_client/livekit_client.dart';

abstract class IsmLiveRouteManagement {
  // static void goToMyMeetingsView(IsmLiveStreamConfig configuration) {
  //   Get.toNamed<void>(IsLiveRoutes.myMeetingsView, arguments: configuration);
  // }

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
    bool reJoin = false,
  }) async {
    IsmLiveStreamBinding().dependencies();
    var widget = IsmLiveStreamView(
      listener: listener,
      room: room,
      streamImage: streamImage,
      streamId: streamId,
      isHost: isHost,
      isNewStream: isNewStream,
      isScrolling: isScrolling,
      isSchedule: isSchedule,
      isInteractive: isInteractive,
    );
    if ((isHost && isNewStream) || reJoin) {
      await IsmLiveRoute.pushReplacement(widget);
    } else {
      await IsmLiveRoute.push(widget);
    }
  }

  static void goToEndStreamView(String streamId) {
    if (Get.currentRoute == IsmLiveRoutes.endStream) {
      return;
    }
    IsmLiveStreamBinding().dependencies();
    IsmLiveRoute.pushReplacement(IsmLiveEndStream(streamId: streamId));
  }

  static void goToGoLiveView({bool popPrevious = false}) {
    IsmLiveStreamBinding().dependencies();
    if (popPrevious) {
      IsmLiveRoute.pushReplacement(const IsmGoLiveView());
    } else {
      IsmLiveRoute.push(const IsmGoLiveView());
    }
  }

  static void goToAddProduct() {
    IsmLiveStreamBinding().dependencies();
    IsmLiveRoute.push(const IsmLiveAddProduct());
  }

  static void goToTagProduct() {
    IsmLiveStreamBinding().dependencies();
    IsmLiveRoute.push(const IsmLiveTagProducts());
  }

  static Future<void> goToRestreamSettingsView(IsmLiveRestreamType type) async {
    IsmLiveStreamBinding().dependencies();
    await IsmLiveRoute.push(IsmLiveRestreamSettingsView(type: type));
  }

  static void goToRestreamView() {
    IsmLiveStreamBinding().dependencies();
    IsmLiveRoute.push(const IsmLiveRestreamView());
  }

  static Future<XFile?> goToCamera(
    bool isPhotoRequired,
    bool isOnlyImage,
  ) async {
    if (IsmLiveUtility.cameras.isNotEmpty) {
      IsmLiveStreamBinding().dependencies();
      return await IsmLiveRoute.push(
        CameraScreenView(
          isPhotoRequired: isPhotoRequired,
          isOnlyImage: isOnlyImage,
        ),
      ) as XFile?;
    } else {
      await IsmLiveUtility.showInfoDialog(
        IsmLiveResponseModel.message('Camera Not Available'),
      );
      return null;
    }
  }

  static void goToCoinsPlanWallet() {
    CoinsPlansWalletBinding().dependencies();
    IsmLiveRoute.push(const CoinsPlansWalletView());
  }

  static void goToCoinTransaction() {
    CoinsPlansWalletBinding().dependencies();
    IsmLiveRoute.push(const IsmLiveCoinTransactions());
  }
}

class LiveStreamRoute {
  /// Opens the Go Live view, handling all bindings and navigation internally.
  static Future<void> goLiveView() async {
    // Ensure bindings are set up
    IsmLiveStreamBinding().dependencies();
    // Push the Go Live view using the global navigator key
    await IsmLiveUtility.navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => const IsmGoLiveView(),
      ),
    );
  }

  static Future<void> coinsPlansWalletView() async {
    // Ensure bindings are set up
    CoinsPlansWalletBinding().dependencies();
    // Push the Coins Plans Wallet view using the global navigator key
    await IsmLiveUtility.navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (_) => const CoinsPlansWalletView(),
      ),
    );
  }
}
