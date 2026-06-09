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
      chatMessageBuilder: IsmLiveDelegate.chatMessageBuilder,
      chatItemBgColorCallback: IsmLiveDelegate.chatItemBgColorCallback,
    );

    return _wrapStreamChatView(context, chatView);
  }

  /// Formats schedule time to "22 Sept, 04:15 PM" format
  String _formatScheduleTime(DateTime scheduleTime) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sept',
      'Oct',
      'Nov',
      'Dec'
    ];

    final day = scheduleTime.day;
    final month = months[scheduleTime.month - 1];
    final hour = scheduleTime.hour;
    final minute = scheduleTime.minute.toString().padLeft(2, '0');

    // Convert to 12-hour format
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

    return '$day $month, ${displayHour.toString().padLeft(2, '0')}:$minute $period';
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

    Widget buttonWidget;

    // Use custom builder if provided
    if (IsmLiveDelegate.goLiveSmallButtonBuilder != null) {
      buttonWidget = IsmLiveDelegate.goLiveSmallButtonBuilder!.call(
        context,
        controller,
        () => controller.startStream(context: context),
        true, // Always enabled - let host manage the logic
      );
    } else if (isTimePassed) {
      // Time has passed, show "Go Live" button
      buttonWidget = IsmLiveButton(
        label: 'Go Live',
        onTap: () {
          controller.startStream(context: context);
        },
      );
    } else {
      // Time hasn't passed yet, show schedule time
      final formattedTime = scheduleTime != null
          ? _formatScheduleTime(scheduleTime)
          : 'No time set';
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
    final builder = IsmLiveDelegate.scheduleStreamCenterOverlayBuilder;
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
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: keyboardBottom),
        child: GetBuilder<IsmLiveStreamController>(
          builder: (controller) => Stack(
            children: [
              Column(
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
                                      controller.streamDetails?.streamId ?? '',
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
              Positioned.fill(
                child: IgnorePointer(
                  ignoring:
                      IsmLiveDelegate.scheduleStreamCenterOverlayBuilder ==
                          null,
                  child: _buildCenterOverlay(context, controller),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}