part of '../stream_view.dart';

class _IsmLiveStreamView extends StatefulWidget {
  const _IsmLiveStreamView({
    super.key,
    required this.streamImage,
    required this.streamId,
    required this.isHost,
    required this.isNewStream,
    this.isInteractive = false,
    required this.isSchedule,
  });

  final String? streamImage;
  final String streamId;
  final bool isHost;
  final bool isNewStream;
  final bool isInteractive;
  final bool isSchedule;

  @override
  State<_IsmLiveStreamView> createState() => _IsmLiveStreamViewState();
}

class _IsmLiveStreamViewState extends State<_IsmLiveStreamView> {
  bool _overlaysVisible = true;

  void _toggleOverlays() {
    // Avoid leaving keyboard open behind hidden overlays.
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _overlaysVisible = !_overlaysVisible);
  }

  /// Full-width widgets from [IsmLiveStreamScreenConfigure.streamBottomWidgetBuilder].
  List<Widget> _streamBottomWidgets(
    BuildContext context,
    IsmLiveStreamController controller,
    bool isKeyboardOpen,
  ) {
    final widget =
        IsmLiveDelegate.streamScreenConfigure.streamBottomWidgetBuilder?.call(
      context,
      controller.streamId ?? '',
      controller.isHost,
      isKeyboardOpen,
    );
    if (widget == null) {
      return const [];
    }
    return [
      SizedBox(
        width: double.infinity,
        child: widget,
      ),
    ];
  }

  /// Builds two arrow buttons for hosts with customizable size
  Widget _buildHostArrowButtons(BuildContext context, {double? size}) =>
      GetBuilder<IsmLiveStreamController>(
        builder: (controller) {
          final buttonSize = size ??
              IsmLiveDelegate.ecomConfigure?.hostArrowButtonsSize ??
              52; // Default size (height and width)
          return SizedBox(
            height: buttonSize,
            width: buttonSize * 2 +
                8, // Width for 2 buttons + spacing (4px right + 4px left)
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(right: 4),
                    height: double.infinity, // Fill the available height
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              12), // Match input field border radius
                        ),
                        padding: EdgeInsets.zero,
                        elevation: 0,
                      ),
                      onPressed: () => _onHostArrowTap(
                        context,
                        IsmLiveArrowDirection.previous,
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_left,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(left: 4),
                    height: double.infinity, // Fill the available height
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              12), // Match input field border radius
                        ),
                        padding: EdgeInsets.zero,
                        elevation: 0,
                      ),
                      onPressed: () => _onHostArrowTap(
                        context,
                        IsmLiveArrowDirection.next,
                      ),
                      child: const Icon(
                        Icons.keyboard_arrow_right,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );

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

  /// Common method to handle "Buy now" button click functionality
  void _onBuyNowTap(BuildContext context, IsmLiveStreamController controller) {
    // Call the buy now callback if provided
    IsmLiveDelegate.ecomConfigure?.buyNowCallback?.call();
  }

  void _onHostArrowTap(
    BuildContext context,
    IsmLiveArrowDirection direction,
  ) {
    IsmLiveDelegate.ecomConfigure?.pinItemCallback?.call(context, direction);
  }

  /// Calculates the dynamic bottom position for `pinnedProductBuilder`.
  ///
  /// Takes into account:
  /// - The reply container (when `parentMessage` is not null)
  /// - The emoji board (when `showEmojiBoard` is true)
  ///
  /// so that the pinned product does not get overlapped by these UI elements.
  double _calculateProductBuilderBottomPosition(
      IsmLiveStreamController controller) {
    // Base bottom position when neither reply nor emoji board is visible
    var bottom = IsmLiveDimens.sixty;

    // If reply feature is active (parentMessage is not null), adjust position
    if (controller.parentMessage != null) {
      // Approximate reply container height (padding + margin + content)
      const replyContainerHeight = 50.0;
      bottom += replyContainerHeight;
    }

    // If emoji board is visible, push the pinned product further up
    if (controller.showEmojiBoard) {
      // Approximate height of the emoji picker + small spacing
      const emojiBoardHeight = 260.0;
      bottom += emojiBoardHeight;
    }

    return bottom;
  }

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: IsmLiveStreamView.updateId,
        initState: (_) {
          var controller = Get.find<IsmLiveStreamController>();

          // Reset preventDispose flag when new view is initialized
          if (controller.preventDispose) {
            controller.preventDispose = false;
            print(
                'initializeAndJoinStream preventDispose reset to false in new view');
          }

          unawaited(controller.initAnimation());

          controller.participantList = controller.participantTracks;

          // Defer wakelock so first frame paints immediately for a snappier open.
          unawaited(WakelockPlus.enable());

          // Note: streamViewLoadedCallback is now triggered when hostDetails becomes available
          // in the _getStreamMembers method of api_mixin.dart

          IsmLiveUtility.updateLater(() {
            if (!widget.isHost) {
              return;
            }

            if (controller.isRtmp && !controller.usePersistentStreamKey) {
              controller.rtmpSheet();
              return;
            } else if (controller.isRtmp) {
              return;
            }

            // For non-deferred connections, keep the original askPublish behavior.
            // When connection is deferred, video/audio will be enabled as part of
            // the deferred LiveKit connection flow.
            if (!controller.pendingConnection) {
              Get.find<IsmLiveStreamController>().askPublish();
            }
          });

          // If connectStream deferred the heavy LiveKit connection, complete it
          // from here *after* the first frame so that navigation stays smooth
          // and dialog/overlay operations happen outside the build phase.
          if (controller.pendingConnection) {
            IsmLiveUtility.updateLater(() {
              if (!controller.pendingConnection) return;
              unawaited(
                controller.completeDeferredConnection(
                  context: context,
                  isHost: widget.isHost,
                  isNewStream: widget.isNewStream,
                  isInteractive: widget.isInteractive,
                  isSchedule: widget.isSchedule,
                ),
              );
            });
          }
        },
        builder: (controller) {
          final mediaQuery = MediaQuery.of(context);
          final isKeyboardOpen = mediaQuery.viewInsets.bottom > 0;
          final systemBottomInset = mediaQuery.viewPadding.bottom;
          final keyboardBottom = mediaQuery.viewInsets.bottom;
          // When the IME is open, keep this sum on bottom-aligned overlays so they
          // stay above the keyboard (body no longer resizes â€” see Scaffold flag).
          final overlayBottomPadding = systemBottomInset + keyboardBottom;
          final isActiveStreamPage = controller.streamId == widget.streamId;
          return PopScope(
            canPop: false,
            onPopInvoked: (didPop) {
              if (didPop && !controller.preventDispose) {
                // Clean up stream data in background so pop transition stays smooth.
                // Awaiting cleanup here was blocking the route transition and causing lag.
                unawaited(IsmLiveStreamView.cleanupStreamData(controller));
              }
            },
            child: Scaffold(
              extendBodyBehindAppBar: true,
              // Keep full viewport height so the video grid does not compress when
              // the IME opens; chat/input use [keyboardBottom] padding instead.
              resizeToAvoidBottomInset: false,
              backgroundColor: context.liveTheme?.streamBackgroundColor ??
                  IsmLiveColors.black,
              body: SafeArea(
                top: false,
                bottom: false,
                child: Container(
                  color: Colors.black, // Ensures status bar area is always dark
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const Positioned.fill(
                        child: ColoredBox(color: Colors.black),
                      ),
                      Positioned.fill(
                        child: IsmLiveStreamBanner(widget.streamImage,
                            isSchedule: widget.isSchedule),
                      ),
                      Positioned.fill(
                        // IMPORTANT (multi-stream scroll):
                        // All pages share the same controller + LiveKit room.
                        // While user is mid-swipe, the next page builds before `onPageChanged`
                        // joins the next stream, so rendering the grid there can show the
                        // *current* stream's video feed on the upcoming page.
                        //
                        // To prevent that production bug, only render the LiveKit grid for
                        // the currently-active stream; inactive pages will show the banner
                        // (cover) until the join completes and controller.streamId updates.
                        child: isActiveStreamPage
                            ? IsmLivePublisherGrid(
                                streamImage: widget.streamImage ?? '',
                                isInteractive: widget.isInteractive,
                                isSchedule: widget.isSchedule,
                              )
                            : const SizedBox.shrink(),
                      ),
                      if ((isActiveStreamPage || widget.isSchedule) &&
                          !(controller.isPk &&
                              (controller.pkStages?.isPkStart ?? false) &&
                              !(controller.userRole?.isHost ?? false) &&
                              !(controller.userRole?.isPkGuest ?? false)))
                        // Tap-to-toggle overlay layer. This sits ABOVE the video/grid
                        // but BELOW all overlay UI, so taps on buttons/chat won't toggle.
                        Positioned.fill(
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: _toggleOverlays,
                            child: const ColoredBox(color: Colors.transparent),
                          ),
                        ),
                      if (isActiveStreamPage ||
                          (widget.isSchedule &&
                              !IsmLiveStreamId.isValid(widget.streamId)))
                        Positioned.fill(
                          child: IgnorePointer(
                            ignoring: !_overlaysVisible,
                            child: AnimatedOpacity(
                              opacity: _overlaysVisible ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 200),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  // Gradients positioned right after publisher grid to only overlay video content
                                  const _TopDarkGradient(),
                                  const _BottomDarkGradient(),
                                  Align(
                                    alignment: IsmLiveApp.headerPosition,
                                    child: Obx(
                                      () {
                                        final isActiveStreamPage =
                                            controller.streamId ==
                                                widget.streamId;
                                        final hostDetails = isActiveStreamPage
                                            ? controller.hostDetails
                                            : null;
                                        if (!((controller.room
                                                        ?.localParticipant !=
                                                    null) &&
                                                IsmLiveApp.showHeader) &&
                                            !widget.isSchedule) {
                                          return IsmLiveDimens.box0;
                                        }
                                        final defaultHeader = _StreamHeader(
                                            streamId: widget.streamId);
                                        return IsmLiveApp.streamHeader?.call(
                                              context,
                                              hostDetails,
                                              controller
                                                  .descriptionController.text,
                                              defaultHeader,
                                            ) ??
                                            defaultHeader;
                                      },
                                    ),
                                  ),
                                  Obx(
                                    () =>
                                        (controller.room?.localParticipant !=
                                                null)
                                            ? SafeArea(
                                                top: false,
                                                child: Padding(
                                                  padding: EdgeInsets.only(
                                                    bottom: keyboardBottom,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Expanded(
                                                        child: Padding(
                                                          padding: IsmLiveDimens
                                                              .edgeInsets8_0,
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Expanded(
                                                                child: IsmLiveApp
                                                                        .bottomBuilder
                                                                        ?.call(
                                                                      context,
                                                                      controller.streamId ==
                                                                              widget.streamId
                                                                          ? controller.hostDetails
                                                                          : null,
                                                                      controller
                                                                          .descriptionController
                                                                          .text,
                                                                    ) ??
                                                                    Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        _buildChatView(
                                                                          context,
                                                                          isHost:
                                                                              controller.isHost,
                                                                          streamId:
                                                                              widget.streamId,
                                                                        ),
                                                                        IsmLiveDimens
                                                                            .boxHeight8,
                                                                      ],
                                                                    ),
                                                              ),
                                                              if (!isKeyboardOpen)
                                                                IsmLiveControlsWidget(
                                                                    isHost: widget
                                                                        .isHost,
                                                                    isCopublishing:
                                                                        controller
                                                                            .isCopublisher,
                                                                    streamId:
                                                                        controller.streamId ??
                                                                            '',
                                                                    isKeyboardOpen:
                                                                        isKeyboardOpen),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    IsmLiveDimens
                                                                        .twelve),
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: IsmLiveApp
                                                                      .inputBuilder
                                                                      ?.call(
                                                                    context,
                                                                    IsmLiveMessageField(
                                                                      streamId:
                                                                          controller.streamId ??
                                                                              '',
                                                                      isHost: controller
                                                                          .isPublishing,
                                                                      disabled:
                                                                          !IsmLiveStreamId.isValid(
                                                                              controller.streamId),
                                                                    ),
                                                                  ) ??
                                                                  IsmLiveMessageField(
                                                                    streamId:
                                                                        controller.streamId ??
                                                                            '',
                                                                    isHost: controller
                                                                        .isPublishing,
                                                                    disabled: !IsmLiveStreamId.isValid(
                                                                        controller
                                                                            .streamId),
                                                                  ),
                                                            ),
                                                            if (IsmLiveDelegate
                                                                        .productStream ==
                                                                    true &&
                                                                !isKeyboardOpen) ...[
                                                              // Determine button visibility and label based on conditions
                                                              if (IsmLiveDelegate
                                                                      .ecomConfigure
                                                                      ?.hasPinnedProduct ??
                                                                  false) ...[
                                                                IsmLiveDimens
                                                                    .boxWidth8,
                                                                ConstrainedBox(
                                                                  constraints:
                                                                      BoxConstraints(
                                                                    maxWidth: MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.5,
                                                                  ),
                                                                  child: controller
                                                                              .isHost &&
                                                                          (IsmLiveDelegate.ecomConfigure?.hasPinnedProduct ??
                                                                              false)
                                                                      ? IsmLiveDelegate
                                                                              .ecomConfigure
                                                                              ?.hostArrowButtonsBuilder
                                                                              ?.call(
                                                                            context,
                                                                            controller.streamId ??
                                                                                '',
                                                                            IsmLiveDelegate.ecomConfigure?.hasPinnedProduct ??
                                                                                false,
                                                                            () =>
                                                                                _onHostArrowTap(context, IsmLiveArrowDirection.previous),
                                                                            () =>
                                                                                _onHostArrowTap(context, IsmLiveArrowDirection.next),
                                                                          ) ??
                                                                          _buildHostArrowButtons(
                                                                              context)
                                                                      : IsmLiveDelegate
                                                                              .ecomConfigure
                                                                              ?.buyNowButtonBuilder
                                                                              ?.call(
                                                                            context,
                                                                            controller.streamId ??
                                                                                '',
                                                                            IsmLiveDelegate.ecomConfigure?.hasPinnedProduct ??
                                                                                false,
                                                                            controller.isHost,
                                                                            () =>
                                                                                _onBuyNowTap(context, controller),
                                                                          ) ??
                                                                          IsmLiveButton(
                                                                            label:
                                                                                'Buy now',
                                                                            onTap: () =>
                                                                                _onBuyNowTap(context, controller),
                                                                          ),
                                                                ),
                                                              ]
                                                            ]
                                                          ],
                                                        ),
                                                      ),
                                                      ..._streamBottomWidgets(
                                                        context,
                                                        controller,
                                                        isKeyboardOpen,
                                                      ),
                                                      IsmLiveDimens.boxHeight8,
                                                      if (IsmLiveApp
                                                          .endStreamPosition
                                                          .isBottomAligned)
                                                        ...[],
                                                      if (controller
                                                          .showEmojiBoard)
                                                        const IsmLiveEmojis(),
                                                    ],
                                                  ),
                                                ),
                                              )
                                            : widget.isSchedule &&
                                                    !IsmLiveStreamId.isValid(
                                                        widget.streamId)
                                                ? ScheduleStreamView(
                                                    isKeyboardOpen:
                                                        isKeyboardOpen)
                                                : const SizedBox.shrink(),
                                  ),
                                  if (IsmLiveDelegate.productStream == true &&
                                      IsmLiveDelegate.ecomConfigure
                                              ?.pinnedProductBuilder !=
                                          null &&
                                      !isKeyboardOpen)
                                    GetBuilder<IsmLiveStreamController>(
                                      id: IsmLiveMessageField.updateId,
                                      builder: (controller) => Positioned(
                                        right: IsmLiveDimens.sixteen,
                                        bottom:
                                            _calculateProductBuilderBottomPosition(
                                                    controller) +
                                                systemBottomInset,
                                        child: IsmLiveDelegate.ecomConfigure!
                                                .pinnedProductBuilder!(
                                              context,
                                              controller,
                                            ) ??
                                            const SizedBox.shrink(),
                                      ),
                                    ),
                                  Align(
                                    alignment: IsmLiveApp.endStreamPosition,
                                    child: Padding(
                                      padding: IsmLiveApp
                                              .endStreamPosition.isBottomAligned
                                          ? EdgeInsets.only(
                                              bottom: overlayBottomPadding)
                                          : EdgeInsets.zero,
                                      child: IsmLiveApp.endButton ??
                                          IsmLiveEndStreamButton(
                                            onTapExit: () =>
                                                IsmLiveApp.endStream(
                                                    context: context,
                                                    isSchedule:
                                                        widget.isSchedule,
                                                    showViewerLeaveDialog:
                                                        true),
                                          ),
                                    ),
                                  ),
                                  if (controller.isHost) ...[
                                    Positioned(
                                      bottom: IsmLiveDimens.eighty +
                                          overlayBottomPadding,
                                      left: IsmLiveDimens.sixteen,
                                      child: const IsmLiveModerationWarning(),
                                    ),
                                    if (widget.isNewStream)
                                      const IsmLiveCounterView(
                                        onCompleteSheet: YourLiveSheet(),
                                      ),
                                  ],
                                  if (controller.isPk &&
                                      !(controller.pkStages?.isPkStart ??
                                          false) &&
                                      ((controller.userRole?.isPkGuest ??
                                              false) ||
                                          (controller.userRole?.isHost ??
                                              false)) &&
                                      !controller
                                          .animationController.isCompleted &&
                                      controller.participantTracks.length ==
                                          2) ...[
                                    AnimatedBuilder(
                                      animation: controller.alignmentAnimation,
                                      child: const IsmLiveImage.svg(
                                        IsmLiveAssetConstants.v,
                                      ),
                                      builder: (context, child) => Align(
                                        alignment:
                                            controller.alignmentAnimation.value,
                                        child: child,
                                      ),
                                    ),
                                    AnimatedBuilder(
                                      animation:
                                          controller.alignmentAnimationRight,
                                      child: const IsmLiveImage.svg(
                                        IsmLiveAssetConstants.s,
                                      ),
                                      builder: (context, child) => Align(
                                        alignment: controller
                                            .alignmentAnimationRight.value,
                                        child: child,
                                      ),
                                    ),
                                  ],
                                  if ((controller.pkStages?.isPk ?? false) &&
                                      controller
                                          .animationController.isCompleted &&
                                      (controller.userRole?.isHost ?? false) &&
                                      !(controller.pkStages?.isPkStart ??
                                          false) &&
                                      controller.participantTracks.length ==
                                          2 &&
                                      !(controller.pkStages?.isPkStop ?? false))
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        final centerY =
                                            IsmLivePublisherGrid
                                                .contentCenterAlignmentY(
                                          context,
                                          description: controller
                                              .descriptionController.text,
                                          layoutHeight: constraints.maxHeight,
                                          layoutWidth: constraints.maxWidth,
                                        );
                                        return Align(
                                          alignment: Alignment(0, centerY),
                                          child: IsmLiveTapHandler(
                                            onTap: controller.pkChallengeSheet,
                                            child: const IsmLiveImage.svg(
                                              IsmLiveAssetConstants.start,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  const IsmLivePkTimerOverlay(),
                                  if ((controller.pkStages?.isPkStop ??
                                          false) &&
                                      controller.pkWinnerId == null)
                                    const Align(
                                      alignment: Alignment.center,
                                      child: IsmLiveImage.svg(
                                          IsmLiveAssetConstants.draw),
                                    ),
                                  Positioned.fill(
                                    child: Obx(
                                      () => Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          ...controller.heartList,
                                          ...controller.giftList,
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
}