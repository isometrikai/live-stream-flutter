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

    // Native tap feedback only when SDK default runs (not when host handled the tap).
    if (option == IsmLiveStreamOption.heart) {
      IsmLiveHeartTapFeedback.trigger();
    }

    await controller.onOptionTap(option, context);
    controller.update([IsmLiveControlsWidget.updateId]);
  }

  /// Ensures [IsmLiveStreamOption.multiLive] appears for viewers in a co-publish
  /// flow when the host app omits it from [IsmLiveDelegate.viewersOption].
  ///
  /// Uses a mutable copy of the options list so the delegate list is never mutated.
  static EdgeInsets _productStreamSideOptionsBottomMargin(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final custom = IsmLiveDelegate.productStreamSideOptionsBottomMargin
        ?.call(context);
    final bottom = custom ?? screenHeight * 0.28;
    return EdgeInsets.only(bottom: bottom);
  }

  static void _ensureMultiLiveForViewerCopublishFlow(
    List<IsmLiveStreamOption> options,
    IsmLiveMemberStatus memberStatus,
  ) {
    if (options.contains(IsmLiveStreamOption.multiLive)) {
      return;
    }
    final needsMultiLive = memberStatus.canEnableVideo ||
        memberStatus.didRequested ||
        memberStatus.isRejected;
    if (!needsMultiLive) {
      return;
    }
    final heartIndex = options.indexOf(IsmLiveStreamOption.heart);
    if (heartIndex >= 0) {
      options.insert(heartIndex, IsmLiveStreamOption.multiLive);
    } else {
      options.add(IsmLiveStreamOption.multiLive);
    }
  }

  static CrossAxisAlignment _sideIconsCrossAxisAlignment() {
    switch (IsmLiveDelegate.sideIconsConfigure.horizontalAlignment) {
      case IsmLiveSideIconsHorizontalAlignment.start:
        return CrossAxisAlignment.start;
      case IsmLiveSideIconsHorizontalAlignment.center:
        return CrossAxisAlignment.center;
      case IsmLiveSideIconsHorizontalAlignment.end:
        return CrossAxisAlignment.end;
    }
  }

  static AlignmentGeometry _sideIconsItemAlignment() {
    switch (IsmLiveDelegate.sideIconsConfigure.horizontalAlignment) {
      case IsmLiveSideIconsHorizontalAlignment.start:
        return AlignmentDirectional.centerStart;
      case IsmLiveSideIconsHorizontalAlignment.center:
        return Alignment.center;
      case IsmLiveSideIconsHorizontalAlignment.end:
        return AlignmentDirectional.centerEnd;
    }
  }

  static Alignment _sideIconsContainerAlignment() {
    switch (IsmLiveDelegate.sideIconsConfigure.horizontalAlignment) {
      case IsmLiveSideIconsHorizontalAlignment.start:
        return Alignment.bottomLeft;
      case IsmLiveSideIconsHorizontalAlignment.center:
        return Alignment.bottomCenter;
      case IsmLiveSideIconsHorizontalAlignment.end:
        return Alignment.bottomRight;
    }
  }

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: updateId,
        initState: (state) {
          final streamController = Get.find<IsmLiveStreamController>();

          streamController.room?.localParticipant
              ?.addListener(streamController.update);
        },
        dispose: (state) {
          if (!Get.isRegistered<IsmLiveStreamController>()) {
            return;
          }
          final streamController = Get.find<IsmLiveStreamController>();
          streamController.room?.localParticipant
              ?.removeListener(streamController.update);
        },
        builder: (controller) {
          final sideIconsWidth =
              IsmLiveDelegate.sideIconsConfigure.width ?? IsmLiveDimens.fifty;
          final sideIconsCrossAxisAlignment = _sideIconsCrossAxisAlignment();
          final sideIconsItemAlignment = _sideIconsItemAlignment();
          final sideIconsContainerAlignment = _sideIconsContainerAlignment();
          var options = <IsmLiveStreamOption>[];
          final hasMultiplePublishers = controller.participantTracks.length > 1;

          if (isHost) {
            options = controller.isRtmp
                ? IsmLiveStreamOption.rtmpOptions
                : controller.isPk
                    ? IsmLiveStreamOption.pkOptions
                    : controller.isCopublisher
                        ? (() {
                            final hostCopublisherOptions =
                                IsmLiveStreamOption.hostOptions
                                    .where(
                                      (element) =>
                                          element != IsmLiveStreamOption.vs,
                                    )
                                    .toList();
                            if (!hostCopublisherOptions.contains(
                              IsmLiveStreamOption.speaker,
                            ) &&
                                hasMultiplePublishers) {
                              hostCopublisherOptions.add(
                                IsmLiveStreamOption.speaker,
                              );
                            }
                            return hostCopublisherOptions;
                          })()
                        : IsmLiveStreamOption.hostOptions;
          } else {
            if (controller.userRole?.isPkGuest ?? false) {
              options = IsmLiveStreamOption.pkOptions;
            } else if (isCopublishing) {
              options = IsmLiveStreamOption.copublisherOptions;
            } else {
              options = List<IsmLiveStreamOption>.from(
                IsmLiveStreamOption.viewersOptions,
              );
              _ensureMultiLiveForViewerCopublishFlow(
                options,
                controller.memberStatus,
              );
            }
          }

          if (isSchedule) {
            options = IsmLiveStreamOption.scheduleOptions;
          }
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: sideIconsCrossAxisAlignment,
              children: [
                Container(
                  padding: EdgeInsets.only(bottom: IsmLiveDimens.eight),
                  alignment: sideIconsContainerAlignment,
                  width: sideIconsWidth,
                  margin: IsmLiveDelegate.productStream == true &&
                          !isKeyboardOpen &&
                          !isSchedule
                      ? _productStreamSideOptionsBottomMargin(context)
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
                        return Align(
                          alignment: sideIconsItemAlignment,
                          child: customWidget,
                        );
                      }

                      // Default widget implementation
                      return Align(
                        alignment: sideIconsItemAlignment,
                        child: CustomIconButton(
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
                        ),
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
