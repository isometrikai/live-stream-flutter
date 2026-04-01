import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/controllers/coins_plans_wallet_controller/coins_plans_wallet_binding.dart';
import 'package:appscrip_live_stream_component/src/res/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:livekit_client/livekit_client.dart';

abstract class IsmLiveRouteManagement {
  static void _trackScreen(
    String screenName, {
    Map<String, dynamic>? props,
  }) {
    IsmLiveDelegate.trackEvent(
      IsmLiveAnalyticsEvent.screenView,
      properties: [
        <String, dynamic>{
          'screen': screenName,
          if (props != null) ...props,
        }
      ],
    );
  }

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
    _trackScreen(
      'IsmLiveStreamView',
      props: {
        'stream_id': streamId,
        'is_host': isHost,
        'is_new_stream': isNewStream,
        'is_scrolling': isScrolling,
        'is_schedule': isSchedule,
        'is_interactive': isInteractive,
        're_join': reJoin,
      },
    );
    print('initializeAndJoinStream reJoin checkinggg -------');
    print(
        'initializeAndJoinStream goToStreamView called with reJoin=$reJoin, isHost=$isHost, isNewStream=$isNewStream');
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

    print('initializeAndJoinStream reJoin checkinggg');

    // Determine if we should use pushReplacement or push
    final shouldReplace = (isHost && isNewStream) || reJoin;

    if (shouldReplace) {
      print('initializeAndJoinStream reJoin status: $reJoin');

      // Set preventDispose flag before navigation if reJoin is true
      if (reJoin) {
        final controller = Get.find<IsmLiveStreamController>();
        controller.preventDispose = true;
        print('initializeAndJoinStream preventDispose set true for reJoin');
        print(
            'initializeAndJoinStream controller preventDispose is now: ${controller.preventDispose}');
      }

      // Navigate to the stream view with snappier transition
      print('initializeAndJoinStream: About to call pushReplacement');
      await IsmLiveRoute.pushReplacementStreamView(widget);
      print('initializeAndJoinStream: pushReplacement completed');

      // Reset preventDispose flag after navigation is complete
      if (reJoin) {
        final controller = Get.find<IsmLiveStreamController>();
        controller.preventDispose = false;
        print(
            'initializeAndJoinStream: Reset preventDispose=false after navigation');
      }
    } else {
      // Regular navigation with snappier transition
      await IsmLiveRoute.pushStreamView(widget);
    }
  }

  static void goToEndStreamView(String streamId) {
    if (Get.currentRoute == IsmLiveRoutes.endStream) {
      return;
    }
    _trackScreen(
      'IsmLiveEndStream',
      props: {
        'stream_id': streamId,
      },
    );
    IsmLiveStreamBinding().dependencies();
    IsmLiveRoute.pushReplacement(IsmLiveEndStream(streamId: streamId));
  }

  static void goToGoLiveView({
    bool popPrevious = false,
    IsmLiveStreamDataModel? editStreamData,
  }) {
    _trackScreen(
      'IsmGoLiveView',
      props: {
        'pop_previous': popPrevious,
        'is_edit': editStreamData != null,
        'stream_id': editStreamData?.streamId ?? '',
        'event_id': editStreamData?.eventId ?? '',
      },
    );
    // Only initialize binding if controller is not already registered
    if (!Get.isRegistered<IsmLiveStreamController>()) {
      IsmLiveStreamBinding().dependencies();
    }

    // If editing a scheduled stream, set up the controller with the existing data
    if (editStreamData != null && Get.isRegistered<IsmLiveStreamController>()) {
      final controller = Get.find<IsmLiveStreamController>();

      // Store the edit data in a temporary variable to set it up after the view is built
      controller.streamDetails = editStreamData;
      controller.isSchedulingBroadcast = true;
      controller.scheduleLiveDate =
          editStreamData.scheduleStartTime ?? DateTime.now();
      controller.descriptionController.text =
          editStreamData.streamDescription ?? '';
      controller.isHdBroadcast = editStreamData.hdBroadcast ?? false;
      controller.isRecordingBroadcast = editStreamData.isRecorded ?? false;
      controller.isRestreamBroadcast = editStreamData.restream ?? false;
      // Set the selected stream type based on the existing data
      controller.selectedGoLiveStream = editStreamData.isPaid == true
          ? IsmLiveStreamTypes.premium
          : IsmLiveStreamTypes.free;

      // Trigger an update to refresh the UI
      controller.update([IsmGoLiveView.updateId]);
    }

    if (popPrevious) {
      IsmLiveRoute.pushReplacementWithTransition(const IsmGoLiveView());
    } else {
      IsmLiveRoute.pushWithTransition(const IsmGoLiveView());
    }
  }

  static void goToAddProduct() {
    _trackScreen('IsmLiveAddProduct');
    IsmLiveStreamBinding().dependencies();
    IsmLiveRoute.push(const IsmLiveAddProduct());
  }

  static void goToTagProduct() {
    _trackScreen('IsmLiveTagProducts');
    IsmLiveStreamBinding().dependencies();
    IsmLiveRoute.push(const IsmLiveTagProducts());
  }

  static Future<void> goToRestreamSettingsView(IsmLiveRestreamType type) async {
    _trackScreen(
      'IsmLiveRestreamSettingsView',
      props: {
        'type': type.name,
      },
    );
    IsmLiveStreamBinding().dependencies();
    await IsmLiveRoute.push(IsmLiveRestreamSettingsView(type: type));
  }

  static void goToRestreamView() {
    _trackScreen('IsmLiveRestreamView');
    IsmLiveStreamBinding().dependencies();
    IsmLiveRoute.push(const IsmLiveRestreamView());
  }

  static Future<XFile?> goToCamera(
    bool isPhotoRequired,
    bool isOnlyImage,
  ) async {
    _trackScreen(
      'CameraScreenView',
      props: {
        'is_photo_required': isPhotoRequired,
        'is_only_image': isOnlyImage,
      },
    );
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

  static void goToCoinsPlanWallet({bool fromStream = false}) {
    _trackScreen(
      'CoinsPlansWalletView',
      props: {
        'from_stream': fromStream,
        'presentation': fromStream ? 'bottom_sheet' : 'push',
      },
    );
    CoinsPlansWalletBinding().dependencies();
    if (fromStream) {
      IsmLiveUtility.openBottomSheet(
        Builder(
          builder: (context) {
            final screenHeight = MediaQuery.of(context).size.height;
            return SizedBox(
              height: screenHeight * 0.9,
              child: const CoinsPlansWalletView(fromStream: true),
            );
          },
        ),
        isScrollController: true,
      );
    } else {
      IsmLiveRoute.push(const CoinsPlansWalletView());
    }
  }

  static void goToCoinTransaction({bool fromStream = false}) {
    _trackScreen(
      'IsmLiveCoinTransactions',
      props: {
        'from_stream': fromStream,
        'presentation': fromStream ? 'bottom_sheet' : 'push',
      },
    );
    CoinsPlansWalletBinding().dependencies();
    if (fromStream) {
      IsmLiveUtility.openBottomSheet(
        Builder(
          builder: (context) {
            final screenHeight = MediaQuery.of(context).size.height;
            return SizedBox(
              height: screenHeight * 0.9,
              child: const IsmLiveCoinTransactions(),
            );
          },
        ),
        isScrollController: true,
      );
    } else {
      IsmLiveRoute.push(const IsmLiveCoinTransactions());
    }
  }

  /// Opens the stream recording player with the given recordings.
  /// Host app can use this or [IsmLiveApp.openStreamRecordingPlayer].
  static Future<void> goToStreamRecordingPlayer({
    required List<IsmLiveStreamRecordingItem> recordings,
    int initialIndex = 0,
    IsmLiveStreamRecordingPlayerConfig? config,
    Future<void> Function()? onLoadMore,
  }) async {
    if (recordings.isEmpty) return;
    _trackScreen(
      'IsmLiveStreamRecordingPlayerView',
      props: {
        'initial_index': initialIndex,
        'recordings_count': recordings.length,
      },
    );
    await IsmLiveUtility.navigatorKey.currentState?.push<void>(
      MaterialPageRoute<void>(
        builder: (_) => IsmLiveStreamRecordingPlayerView(
          recordings: recordings,
          initialIndex: initialIndex.clamp(0, recordings.length - 1),
          config: config,
          onLoadMore: onLoadMore,
        ),
        fullscreenDialog: true,
      ),
    );
  }
}

class LiveStreamRoute {
  /// Opens the Go Live view, handling all bindings and navigation internally.
  static Future<void> goLiveView() async {
    IsmLiveDelegate.trackEvent(
      IsmLiveAnalyticsEvent.screenView,
      properties: [
        {
          'screen': 'IsmGoLiveView',
          'presentation': 'navigator_push',
        }
      ],
    );
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
    IsmLiveDelegate.trackEvent(
      IsmLiveAnalyticsEvent.screenView,
      properties: [
        {
          'screen': 'CoinsPlansWalletView',
          'presentation': 'navigator_push',
        }
      ],
    );
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
