import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Live stream controls widget with support for custom widgets and unified callbacks.
///
/// This widget supports:
/// 1. Custom control widgets via `IsmLiveDelegate.controlWidgetBuilder`
/// 2. Unified option tap handling via `IsmLiveDelegate.controlOptionCallback`
///
/// Usage example:
/// ```dart
/// IsmLiveApp.configureInterface(
///   // Custom widget builder - replace specific control widgets
///   controlWidgetBuilder: (context, option, onTap, isHost, isCopublishing, streamId) {
///     if (option == IsmLiveStreamOption.gift) {
///       return MyCustomGiftButton(onTap: onTap);
///     }
///     return null; // Use default widget
///   },
///
///   // Unified callback - handle all option taps
///   controlOptionCallback: (context, option, streamId, isHost, isCopublishing) async {
///     if (option == IsmLiveStreamOption.share) {
///       // Custom share logic
///       await MyCustomShareService.share(streamId);
///       return true; // Handled, don't use default behavior
///     }
///     return false; // Use default behavior
///   },
/// );
/// ```
class IsmLiveControlsWidget extends StatelessWidget {
  const IsmLiveControlsWidget({
    super.key,
    required this.isHost,
    required this.streamId,
    required this.isCopublishing,
    this.isSchedule = false,
    required this.isKeyboardOpen,
  });

  final bool isHost;
  final bool isCopublishing;
  final bool isSchedule;
  final String streamId;
  final bool isKeyboardOpen;

  static const String updateId = 'ism-live-controls';

  /// Handles option tap with unified callback support
  static Future<void> _handleOptionTap(
    IsmLiveStreamController controller,
    IsmLiveStreamOption option,
    BuildContext context,
  ) async {
    // Check if host app wants to handle the option tap
    final controlCallback = IsmLiveDelegate.controlOptionCallback;
    if (controlCallback != null) {
      final handled = await controlCallback(
        context,
        option,
        controller.streamId ?? '',
        controller.isHost,
        controller.isCopublisher == true,
      );

      // If host app handled the click, don't show default behavior
      if (handled) {
        controller.update([IsmLiveControlsWidget.updateId]);
        return;
      }
    }

    // Default behavior: call the original onOptionTap
    await controller.onOptionTap(option, context);
    controller.update([IsmLiveControlsWidget.updateId]);
  }

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: updateId,
        initState: (state) {
          final streamController = Get.find<IsmLiveStreamController>();

          streamController.room?.localParticipant
              ?.addListener(streamController.update);
        },
        dispose: (state) async {
          final streamController = Get.find<IsmLiveStreamController>();

          streamController.room?.localParticipant
              ?.removeListener(streamController.update);
        },
        builder: (controller) {
          var options = <IsmLiveStreamOption>[];

          if (isHost) {
            options = controller.isRtmp
                ? IsmLiveStreamOption.rtmpOptions
                : controller.isPk
                    ? IsmLiveStreamOption.pkOptions
                    : controller.isCopublisher
                        ? IsmLiveStreamOption.hostOptions
                            .where(
                              (element) => element != IsmLiveStreamOption.vs,
                            )
                            .toList()
                        : IsmLiveStreamOption.hostOptions;
          } else {
            options = controller.userRole?.isPkGuest ?? false
                ? IsmLiveStreamOption.pkOptions
                : isCopublishing
                    ? IsmLiveStreamOption.copublisherOptions
                    : IsmLiveStreamOption.viewersOptions;
          }

          if (isSchedule) {
            options = IsmLiveStreamOption.scheduleOptions;
          }
          // Hide video-specific controls in audio-only mode
          if (controller.isAudioOnly) {
            options = options
                .where((e) => e != IsmLiveStreamOption.rotateCamera)
                .toList();
          }
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: IsmLiveDimens.eight),
                  alignment: Alignment.bottomRight,
                  width: IsmLiveDimens.fifty,
                  margin: IsmLiveDelegate.productStream == true &&
                          !isKeyboardOpen &&
                          !isSchedule
                      ? EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height * 0.28)
                      : null,
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (_, __) => IsmLiveDimens.boxHeight8,
                    itemBuilder: (context, index) {
                      final option = options[index];

                      // Check if host app wants to provide a custom widget
                      final customWidget =
                          IsmLiveDelegate.controlWidgetBuilder?.call(
                        context,
                        option,
                        () async {
                          await _handleOptionTap(controller, option, context);
                        },
                        isHost,
                        isCopublishing,
                        streamId,
                      );

                      // Use custom widget if provided, otherwise use default
                      if (customWidget != null) {
                        return customWidget;
                      }

                      // Default widget implementation
                      return CustomIconButton(
                        dimension: option == IsmLiveStreamOption.heart
                            ? IsmLiveDimens.fortyFive
                            : null,
                        icon: IsmLiveImage.svg(
                          height: option != IsmLiveStreamOption.heart
                              ? IsmLiveDimens.forty
                              : null,
                          width: option != IsmLiveStreamOption.heart
                              ? IsmLiveDimens.forty
                              : null,
                          controller.controlIcon(option),
                        ),
                        onTap: () async {
                          await _handleOptionTap(controller, option, context);
                        },
                        color: option == IsmLiveStreamOption.heart
                            ? IsmLiveColors.red
                            : option == IsmLiveStreamOption.multiLive
                                ? !isHost && controller.isCopublisher != true
                                    ? controller.memberStatus.canEnableVideo
                                        ? context.theme.primaryColor
                                        : controller.memberStatus.didRequested
                                            ? Colors.blueGrey
                                            : null
                                    : null
                                : null,
                        gradient: IsmLiveDelegate.streamOptionsBgGradient,
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
}
