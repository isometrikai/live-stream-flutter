part of '../stream_view.dart';

class ScheduleStreamView extends StatelessWidget {
  const ScheduleStreamView({super.key, required this.isKeyboardOpen});

  final bool isKeyboardOpen;

  /// Wraps [IsmLiveChatView] with optional width constraints from
  /// [IsmLiveStreamScreenConfigure].
  Widget _buildChatView(
    BuildContext context, {
    required bool isHost,
    required String streamId,
  }) {
    final chatView = IsmLiveChatView(
      isHost: isHost,
      streamId: streamId,
      chatMessageBuilder:
          IsmLiveDelegate.streamScreenConfigure.chatMessageBuilder,
      chatItemBgColorCallback:
          IsmLiveDelegate.streamScreenConfigure.chatItemBgColorCallback,
    );

    return _wrapStreamChatView(context, chatView);
  }

  /// Determines if the scheduled time has passed
  bool _isScheduleTimePassed(DateTime? scheduleTime) {
    if (scheduleTime == null) return true;
    return DateTime.now().isAfter(scheduleTime);
  }

  /// Gets the appropriate button content for scheduled streams
  /// with max width constraint of half screen width
  Widget _buildScheduledGoLiveButton(BuildContext context,
      IsmLiveStreamController controller, bool isKeyboardOpen) {
    final scheduleTime = controller.streamDetails?.scheduleStartTime;
    final isTimePassed = _isScheduleTimePassed(scheduleTime);
    final isStreamCreator =
        controller.streamDetails?.userId == controller.user?.userId;

    Widget buttonWidget;

    // Use custom builder if provided
    if (IsmLiveDelegate.streamScreenConfigure.goLiveSmallButtonBuilder !=
        null) {
      buttonWidget =
          IsmLiveDelegate.streamScreenConfigure.goLiveSmallButtonBuilder!.call(
        context,
        controller,
        () => controller.startStream(context: context),
        true, // Always enabled - let host manage the logic
      );
    } else if (isTimePassed && isStreamCreator) {
      // Time has passed and current user created the stream
      buttonWidget = IsmLiveButton(
        label: IsmLiveStrings.goLive,
        onTap: () {
          controller.startStream(context: context);
        },
      );
    } else {
      // Future schedule time, or past time for non-creators
      final formattedTime = scheduleTime != null
          ? scheduleTime.formattedScheduleDate
          : IsmLiveStrings.noTimeSet;
      buttonWidget = Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
        ),
        child: Text(
          formattedTime,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Wrap with ConstrainedBox to set max width to half screen width
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.5,
      ),
      child: buttonWidget,
    );
  }

  Widget _buildCenterOverlay(
    BuildContext context,
    IsmLiveStreamController controller,
  ) {
    final builder = IsmLiveDelegate
        .streamScreenConfigure.scheduleStreamCenterOverlayBuilder;
    if (builder == null) {
      return const SizedBox.shrink();
    }

    return Center(
      child: builder(context, controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final keyboardBottom = MediaQuery.viewInsetsOf(context).bottom;
    return GetBuilder<IsmLiveStreamController>(
      builder: (controller) {
        final gradientOverlay = IsmLiveDelegate
            .streamScreenConfigure.streamGradientOverlayBuilder
            ?.call(
          context,
          controller.streamDetails?.streamId ?? controller.streamId ?? '',
          controller.isHost,
          true,
        );
        return Stack(
          children: [
            // Full-screen gradients (match live stream: extend behind status bar).
            ...(gradientOverlay != null
                ? [gradientOverlay]
                : const [
                    _TopDarkGradient(),
                    _BottomDarkGradient(),
                  ]),
            SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(bottom: keyboardBottom),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: IsmLiveDimens.edgeInsets8_0,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _buildChatView(
                                    context,
                                    isHost: true,
                                    streamId: controller.streamId ?? '',
                                  ),
                                  IsmLiveDimens.boxHeight8,
                                  IsmLiveApp.inputBuilder?.call(
                                        context,
                                        IsmLiveMessageField(
                                          streamId: controller.streamId ?? '',
                                          isHost: controller.isPublishing,
                                          disabled: !IsmLiveStreamId.isValid(
                                              controller.streamId),
                                        ),
                                      ) ??
                                      IsmLiveMessageField(
                                        streamId: () {
                                          // Debug logging for streamId at line 903
                                          final streamId = controller
                                                  .streamDetails?.streamId ??
                                              '';
                                          return streamId;
                                        }(),
                                        isHost: controller.isPublishing,
                                        disabled: !IsmLiveStreamId.isValid(
                                            controller.streamDetails?.streamId),
                                      ),
                                ],
                              ),
                            ),
                            IsmLiveDimens.boxWidth2,
                            if (!isKeyboardOpen)
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  IsmLiveControlsWidget(
                                    isHost: controller.isHost,
                                    isCopublishing: false,
                                    isSchedule: true,
                                    streamId:
                                        controller.streamDetails?.streamId ??
                                            '',
                                    isKeyboardOpen: isKeyboardOpen,
                                  ),
                                  IsmLiveDimens.boxHeight32,
                                  _buildScheduledGoLiveButton(
                                      context, controller, isKeyboardOpen),
                                ],
                              )
                          ],
                        ),
                      ),
                    ),
                    IsmLiveDimens.boxHeight4,
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                ignoring: IsmLiveDelegate.streamScreenConfigure
                        .scheduleStreamCenterOverlayBuilder ==
                    null,
                child: _buildCenterOverlay(context, controller),
              ),
            ),
          ],
        );
      },
    );
  }
}
