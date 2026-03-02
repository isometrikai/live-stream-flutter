import 'dart:async';
import 'dart:developer';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/res/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class IsmLiveStreamView extends StatelessWidget {
  /// Refactored: All arguments must be passed via the constructor.
  const IsmLiveStreamView({
    super.key,
    required this.listener,
    required this.room,
    this.streamImage,
    required this.streamId,
    required this.isHost,
    required this.isNewStream,
    required this.isScrolling,
    required this.isSchedule,
    required this.isInteractive,
  });

  final RoomListener listener;
  final Room room;
  final String? streamImage;
  final String streamId;
  final bool isHost;
  final bool isNewStream;
  final bool isScrolling;
  final bool isSchedule;
  final bool isInteractive;

  bool get fastConnection => room.engine.fastConnectOptions != null;

  static const String route = IsmLiveRoutes.streamView;
  static const String updateId = 'ismlive-stream-view';

  /// Clean up stream data when the view is closed
  static Future<void> cleanupStreamData(
      IsmLiveStreamController controller) async {
    try {
      // Clear all stream-related data
      // Note: streamDispose() will handle the preventDispose check internally
      controller
          .streamDispose(false); // Don't dispose animation controller here

      // Clear camera controller if exists
      controller.cameraController?.dispose();
      controller.cameraController = null;

      // Clear timer-related data
      controller.streamTimer?.cancel();
      controller.streamTimer = null;

      // Clear PK timer if exists
      if (Get.isRegistered<IsmLivePkController>()) {
        final pkController = Get.find<IsmLivePkController>();
        pkController.pkTimer?.cancel();
        pkController.pkTimer = null;
      }

      // Clear stream details and related data
      // Note: Essential data (streamId, room, listener, etc.) are already handled by streamDispose()
      controller.streamDetails = null;
      controller.pickedImage = null;
      controller.bytes = null;

      // Clear participant data
      controller.participantTracks.clear();
      controller.participantList.clear();

      // Clear user role
      controller.userRole = null;

      // Clear analytics data
      controller.streamAnalytis = null;
      controller.analyticsViewers.clear();

      // Clear messages and viewers
      controller.streamMessagesList.clear();
      controller.streamViewersList.clear();
      controller.streamMembersList.clear();

      // Clear gift data
      controller.giftMessages.clear();
      controller.giftList.clear();
      controller.heartList.clear();

      // Clear search controllers
      controller.searchUserFieldController.clear();
      controller.searchModeratorFieldController.clear();
      controller.searchCopublisherFieldController.clear();
      controller.searchExistingMembesFieldController.clear();
      controller.searchMembersFieldController.clear();

      // Clear copublisher requests
      controller.copublisherRequestsList.clear();

      // Clear selected products
      controller.selectedProductsList.clear();

      // Reset member status
      controller.memberStatus = IsmLiveMemberStatus.notMember;

      // Reset UI states
      controller.showEmojiBoard = false;
      controller.speakerOn = true;
      controller.videoOn = true;
      controller.audioOn = true;

      // Clear gift coin balance
      controller.giftcoinBalance = 0;

      // Clear parent message
      controller.parentMessage = null;

      // Reset gift type
      controller.giftType = 0;

      // Clear premium stream coins
      controller.premiumStreamCoinsController.clear();

      // Reset all boolean flags
      controller.isHdBroadcast = false;
      controller.isRecordingBroadcast = false;
      controller.isRestreamBroadcast = false;
      controller.usePersistentStreamKey = false;
      controller.isRtmp = false;
      controller.isPremium = false;
      controller.isSchedulingBroadcast = false;
      controller.restreamFacebook = false;
      controller.restreamYoutube = false;
      controller.restreamInstagram = false;

      // Reset selected items
      controller.selectedGoLiveTabItem = IsmGoLiveTabItem.defaultLive;
      controller.selectedGoLiveStream = IsmLiveStreamTypes.free;

      // Reset schedule date
      controller.scheduleLiveDate = DateTime.now();

      // Clear text controllers
      controller.rtmlUrl.clear();
      controller.streamKey.clear();
      controller.rtmlUrlDevice.clear();
      controller.streamKeyDevice.clear();

      // Disable wakelock
      await WakelockPlus.disable();

      // Call the dispose callback if provided
      IsmLiveDelegate.onStreamEnd?.call();
    } catch (e) {
      IsmLiveLog.error('Error cleaning up stream data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark, // For iOS
      ),
    );
    log('IsmLiveStreamView: isHost: $isHost');
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark, // For iOS
      ),
      child: isHost
          ? _IsmLiveStreamView(
              key: key,
              streamImage: streamImage,
              streamId: streamId,
              isHost: isHost,
              isNewStream: isNewStream,
              isInteractive: isInteractive,
              isSchedule: isSchedule,
            )
          : (!isScrolling)
              ? _IsmLiveStreamView(
                  key: key,
                  streamImage: streamImage,
                  streamId: streamId,
                  isHost: false,
                  isNewStream: false,
                  isInteractive: isInteractive,
                  isSchedule: isSchedule,
                )
              : GetX<IsmLiveStreamController>(
                  initState: (_) {
                    var controller = Get.find<IsmLiveStreamController>();

                    IsmLiveUtility.updateLater(() {
                      controller.previousStreamIndex =
                          controller.pageController?.page?.toInt() ?? 0;
                    });
                  },
                  builder: (controller) => PageView.builder(
                    itemCount: controller.streams.length,
                    controller: controller.pageController,
                    scrollDirection: Axis.vertical,
                    pageSnapping: true,
                    onPageChanged: (index) => controller.onStreamScroll(
                        index: index, context: context),
                    itemBuilder: (_, index) {
                      final stream = controller.streams[index];
                      return _IsmLiveStreamView(
                        key: key,
                        streamImage: stream.streamImage,
                        streamId: stream.streamId ?? '',
                        isHost: false,
                        isNewStream: false,
                        isInteractive: isInteractive,
                        isSchedule: stream.isScheduledStream ?? isSchedule,
                      );
                    },
                  ),
                ),
    );
  }
}

class _IsmLiveStreamView extends StatelessWidget {
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

  /// Validates if streamId is valid
  /// Returns true if streamId is valid (not empty, not null, and doesn't start with '00000')
  /// Returns false otherwise
  static bool isValidStreamId(String? streamId) {
    if (streamId == null || streamId.isEmpty) {
      return false;
    }
    if (streamId.startsWith('00000')) {
      return false;
    }
    return true;
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
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              12), // Match input field border radius
                        ),
                        padding: EdgeInsets.zero,
                        elevation: 0,
                      ),
                      onPressed: () {
                        // Left arrow action - call pinItemCallback with previous direction
                        IsmLiveDelegate.ecomConfigure?.pinItemCallback?.call(
                          context,
                          IsmLiveArrowDirection.previous,
                        );
                      },
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
                        backgroundColor: Colors.white.withOpacity(0.2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              12), // Match input field border radius
                        ),
                        padding: EdgeInsets.zero,
                        elevation: 0,
                      ),
                      onPressed: () {
                        // Right arrow action - call pinItemCallback with next direction
                        IsmLiveDelegate.ecomConfigure?.pinItemCallback?.call(
                          context,
                          IsmLiveArrowDirection.next,
                        );
                      },
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

  /// Wraps IsmLiveChatView with conditional width constraints
  /// When productStream is true, limits width to half screen width
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

    // Apply width constraint only when productStream is enabled
    if (IsmLiveDelegate.productStream == true) {
      return Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.5,
          ),
          child: chatView,
        ),
      );
    }

    return chatView;
  }

  /// Common method to handle "Buy now" button click functionality
  void _onBuyNowTap(BuildContext context, IsmLiveStreamController controller) {
    // Call the buy now callback if provided
    IsmLiveDelegate.ecomConfigure?.buyNowCallback?.call();
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
    var bottom = IsmLiveDimens.eighty;

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
            if (isHost) {
              if (controller.isRtmp && !controller.usePersistentStreamKey) {
                controller.rtmpSheet();
              } else if (controller.isRtmp) {
              } else {
                Get.find<IsmLiveStreamController>().askPublish();
              }
            }
          });
        },
        builder: (controller) {
          final mediaQuery = MediaQuery.of(context);
          final isKeyboardOpen = mediaQuery.viewInsets.bottom > 0;
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
              backgroundColor: context.liveTheme?.streamBackgroundColor ??
                  IsmLiveColors.black,
              body: SafeArea(
                top: false,
                child: Container(
                  color: Colors.black, // Ensures status bar area is always dark
                  child: Stack(
                    children: [
                      const ColoredBox(
                          color:
                              Colors.black), // Bottom-most layer for status bar
                      IsmLiveStreamBanner(streamImage, isSchedule: isSchedule),
                      IsmLivePublisherGrid(
                        streamImage: streamImage ?? '',
                        isInteractive: isInteractive,
                        isSchedule: isSchedule,
                      ),
                      // Gradients positioned right after publisher grid to only overlay video content
                      const _TopDarkGradient(),
                      const _BottomDarkGradient(),
                      Align(
                        alignment: IsmLiveApp.headerPosition,
                        child: Obx(
                          () {
                            if (!((controller.room?.localParticipant != null) &&
                                    IsmLiveApp.showHeader) &&
                                !isSchedule) {
                              return IsmLiveDimens.box0;
                            }
                            final defaultHeader = _StreamHeader(
                                streamId: controller.streamId ?? '');
                            return IsmLiveApp.streamHeader?.call(
                                  context,
                                  controller.hostDetails,
                                  controller.descriptionController.text,
                                  defaultHeader,
                                ) ??
                                defaultHeader;
                          },
                        ),
                      ),
                      Obx(
                        () => (controller.room?.localParticipant != null)
                            ? SafeArea(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: IsmLiveDimens.edgeInsets8_0,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children: [
                                            Expanded(
                                              child: IsmLiveApp.bottomBuilder
                                                      ?.call(
                                                    context,
                                                    controller.hostDetails,
                                                    controller
                                                        .descriptionController
                                                        .text,
                                                  ) ??
                                                  Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      _buildChatView(
                                                        context,
                                                        isHost:
                                                            controller.isHost,
                                                        streamId: streamId,
                                                      ),
                                                      IsmLiveDimens.boxHeight8,
                                                    ],
                                                  ),
                                            ),
                                            IsmLiveControlsWidget(
                                                isHost: isHost,
                                                isCopublishing:
                                                    controller.isCopublisher,
                                                streamId:
                                                    controller.streamId ?? '',
                                                isKeyboardOpen: isKeyboardOpen),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: IsmLiveDimens.twelve),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: IsmLiveApp.inputBuilder
                                                    ?.call(
                                                  context,
                                                  IsmLiveMessageField(
                                                    streamId:
                                                        controller.streamId ??
                                                            '',
                                                    isHost:
                                                        controller.isPublishing,
                                                    disabled:
                                                        !_IsmLiveStreamView
                                                            .isValidStreamId(
                                                                controller
                                                                    .streamId),
                                                  ),
                                                ) ??
                                                IsmLiveMessageField(
                                                  streamId:
                                                      controller.streamId ?? '',
                                                  isHost:
                                                      controller.isPublishing,
                                                  disabled: !_IsmLiveStreamView
                                                      .isValidStreamId(
                                                          controller.streamId),
                                                ),
                                          ),
                                          if (IsmLiveDelegate.productStream ==
                                                  true &&
                                              !isKeyboardOpen) ...[
                                            // Determine button visibility and label based on conditions
                                            if (IsmLiveDelegate.ecomConfigure
                                                    ?.hasPinnedProduct ??
                                                false) ...[
                                              IsmLiveDimens.boxWidth8,
                                              ConstrainedBox(
                                                constraints: BoxConstraints(
                                                  maxWidth:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.5,
                                                ),
                                                child: controller.isHost &&
                                                        (IsmLiveDelegate
                                                                .ecomConfigure
                                                                ?.hasPinnedProduct ??
                                                            false)
                                                    ? _buildHostArrowButtons(
                                                        context)
                                                    : IsmLiveDelegate
                                                            .ecomConfigure
                                                            ?.buyNowButtonBuilder
                                                            ?.call(
                                                          context,
                                                          controller.streamId ??
                                                              '',
                                                          IsmLiveDelegate
                                                                  .ecomConfigure
                                                                  ?.hasPinnedProduct ??
                                                              false,
                                                          controller.isHost,
                                                          () => _onBuyNowTap(
                                                              context,
                                                              controller),
                                                        ) ??
                                                        IsmLiveButton(
                                                          label: 'Buy now',
                                                          onTap: () =>
                                                              _onBuyNowTap(
                                                                  context,
                                                                  controller),
                                                        ),
                                              ),
                                            ]
                                          ]
                                        ],
                                      ),
                                    ),
                                    IsmLiveDimens.boxHeight8,
                                    if (IsmLiveApp
                                        .endStreamPosition.isBottomAligned)
                                      ...[],
                                    if (controller.showEmojiBoard)
                                      const IsmLiveEmojis(),
                                  ],
                                ),
                              )
                            : isSchedule
                                ? ScheduleStreamView(
                                    isKeyboardOpen: isKeyboardOpen)
                                : const SizedBox.shrink(),
                      ),
                      if (IsmLiveDelegate.productStream == true &&
                          IsmLiveDelegate.ecomConfigure?.pinnedProductBuilder !=
                              null)
                        GetBuilder<IsmLiveStreamController>(
                          id: IsmLiveMessageField.updateId,
                          builder: (controller) => Positioned(
                            right: IsmLiveDimens.sixteen,
                            bottom: _calculateProductBuilderBottomPosition(
                                controller),
                            child: IsmLiveDelegate
                                    .ecomConfigure!.pinnedProductBuilder!(
                                  context,
                                  controller,
                                ) ??
                                const SizedBox.shrink(),
                          ),
                        ),
                      Align(
                        alignment: IsmLiveApp.endStreamPosition,
                        child: IsmLiveApp.endButton ??
                            IsmLiveEndStreamButton(
                              onTapExit: () => IsmLiveApp.endStream(
                                  context: context, isSchedule: isSchedule),
                            ),
                      ),
                      if (controller.isHost) ...[
                        Positioned(
                          bottom: IsmLiveDimens.eighty,
                          left: IsmLiveDimens.sixteen,
                          child: const IsmLiveModerationWarning(),
                        ),
                        if (isNewStream)
                          const IsmLiveCounterView(
                            onCompleteSheet: YourLiveSheet(),
                          ),
                      ],
                      if (controller.isPk &&
                          !(controller.pkStages?.isPkStart ?? false) &&
                          ((controller.userRole?.isPkGuest ?? false) ||
                              (controller.userRole?.isHost ?? false)) &&
                          !controller.animationController.isCompleted &&
                          controller.participantTracks.length == 2) ...[
                        AnimatedBuilder(
                          animation: controller.alignmentAnimation,
                          builder: (context, child) => AnimatedAlign(
                            alignment: controller.alignmentAnimation.value,
                            duration: const Duration(
                              milliseconds: 100,
                            ),
                            child:
                                const IsmLiveImage.svg(IsmLiveAssetConstants.v),
                          ),
                        ),
                        AnimatedBuilder(
                          animation: controller.alignmentAnimationRight,
                          builder: (context, child) => AnimatedAlign(
                            alignment: controller.alignmentAnimationRight.value,
                            duration: const Duration(
                              milliseconds: 100,
                            ),
                            child:
                                const IsmLiveImage.svg(IsmLiveAssetConstants.s),
                          ),
                        ),
                      ],
                      if ((controller.pkStages?.isPk ?? false) &&
                          controller.animationController.isCompleted &&
                          (controller.userRole?.isHost ?? false) &&
                          !(controller.pkStages?.isPkStart ?? false) &&
                          controller.participantTracks.length == 2 &&
                          !(controller.pkStages?.isPkStop ?? false))
                        Align(
                          alignment: Alignment.center,
                          child: IsmLiveTapHandler(
                            onTap: controller.pkChallengeSheet,
                            child: const IsmLiveImage.svg(
                              IsmLiveAssetConstants.start,
                            ),
                          ),
                        ),
                      if ((controller.pkStages?.isPkStart ?? false) &&
                          controller.participantTracks.length > 1)
                        const IsmLivePkTimerContainer(),
                      if ((controller.pkStages?.isPkStop ?? false) &&
                          controller.pkWinnerId == null)
                        const Align(
                          alignment: Alignment.center,
                          child: IsmLiveImage.svg(IsmLiveAssetConstants.draw),
                        ),
                      ...controller.heartList,
                      ...controller.giftList,
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      );
}

class _StreamHeader extends StatelessWidget {
  const _StreamHeader({
    required this.streamId,
  });

  final String streamId;

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: IsmLiveStreamView.updateId,
        builder: (controller) => SafeArea(
          child: IsmLiveStreamHeader(
            streamCoins: controller.premiumStreamCoinsController.text,
            isBattleTie: controller.pkWinnerId != null,
            winnerName: controller.findWinner(controller.pkWinnerId),
            description: controller.descriptionController.text,
            name: controller.hostDetails?.name ?? 'U',
            imageUrl: controller.hostDetails?.image ?? '',
            userIdentifier: controller.hostDetails?.userIdentifier ?? '',
            pkCompleted: (controller.pkStages?.isPkStop ?? false) &&
                controller.participantTracks.length == 2,
            isPaidStream: controller.isPremium,
            onTapModerators: () async {
              // If user is a moderator (not host), show moderator status bottom sheet
              if (controller.isModerator && !controller.isHost) {
                IsmLiveUtility.openBottomSheet(
                  IsmLiveModeratorBottomSheet(
                    type: IsmLiveModeratorBottomSheetType.currentlyModerating,
                    streamId: streamId,
                  ),
                  isDismissible: true,
                );
                return;
              }

              // Check if host app wants to handle the moderators list tap
              final moderatorsCallback = IsmLiveDelegate.moderatorsListCallback;
              if (moderatorsCallback != null) {
                final handled = await moderatorsCallback(
                  context,
                  streamId,
                  controller.isHost,
                  controller.isModerator,
                  controller.moderatorsList,
                  controller.hostDetails,
                );

                // If host app handled the tap, don't show default moderators sheet
                if (handled) {
                  return;
                }
              }

              // Ensure we have latest moderators before deciding flow
              await controller.fetchModerators(
                forceFetch: true,
                streamId: streamId,
              );

              final hostUserId = controller.hostDetails?.userId;
              final hostIdentifier = controller.hostDetails?.userIdentifier;

              final nonHostModerators = controller.moderatorsList.where(
                (moderator) {
                  if (hostUserId != null && moderator.userId == hostUserId) {
                    return false;
                  }
                  if (hostIdentifier != null &&
                      moderator.userIdentifier == hostIdentifier) {
                    return false;
                  }
                  return true;
                },
              ).toList();

              final sheetContext =
                  IsmLiveUtility.navigatorKey.currentContext ?? context;

              // If no moderators (excluding host), open Add Moderator flow
              if (nonHostModerators.isEmpty) {
                IsmLiveUtility.openBottomSheet(
                  const AddModeratorsListBottomSheet(),
                  isScrollController: true,
                  backgroundColor: sheetContext.liveTheme?.backgroundColor ??
                      (Theme.of(sheetContext).brightness == Brightness.dark
                          ? const Color(0xFF121212)
                          : Colors.white),
                );
                return;
              }

              // If we have moderators, show moderators sheet first
              IsmLiveUtility.openBottomSheet(
                const IsmLiveModeratorsSheet(),
                isScrollController: true,
                backgroundColor: sheetContext.liveTheme?.backgroundColor ??
                    (Theme.of(sheetContext).brightness == Brightness.dark
                        ? const Color(0xFF121212)
                        : Colors.white),
              );
            },
            onTapViewers: (viewerList) async {
              // Check if host app wants to handle the viewers list tap
              final viewersCallback = IsmLiveDelegate.topViewersListCallback;
              if (viewersCallback != null) {
                final handled = await viewersCallback(
                  context,
                  viewerList,
                  streamId,
                  controller.isHost,
                  controller.isModerator,
                  controller.streamViewersList,
                );

                // If host app handled the tap, don't show default viewers sheet
                if (handled) {
                  return;
                }
              }

              // Default behavior: show viewers sheet
              IsmLiveUtility.openBottomSheet(
                GetBuilder<IsmLiveStreamController>(
                  initState: (state) {
                    IsmLiveUtility.updateLater(
                        () => controller.getStreamViewer(streamId: streamId));
                  },
                  id: IsmLiveStreamView.updateId,
                  builder: (controller) => IsmLiveListSheet(
                    scrollController: controller.viewerListController,
                    items: controller.streamViewersList,
                    trailing: (_, viewer) =>
                        controller.isModerator || controller.isHost
                            ? viewer.userId == controller.user?.userId
                                ? IsmLiveDimens.box0
                                : SizedBox(
                                    width: IsmLiveDimens.hundred,
                                    child: IsmLiveButton(
                                      label: 'kick out',
                                      onTap: () {
                                        controller.kickoutViewer(
                                          streamId: streamId,
                                          viewerId: viewer.userId,
                                        );
                                      },
                                    ),
                                  )
                            : IsmLiveDimens.box0,
                    onViewerProfileTap: (viewer, index) {
                      if (!IsmLiveDelegate.restrictProfileSheetOnProfileClick) {
                        IsmLiveUtility.openBottomSheet(
                          StreamLiveSheet(
                            widget: IsmLiveImage.network(
                              IsmLiveDelegate.getUserProfileUrl
                                      ?.call(viewer.imageUrl ?? '') ??
                                  viewer.imageUrl ??
                                  '',
                              isProfileImage: true,
                              name: viewer.userName,
                              height: IsmLiveDimens.hundred,
                              width: IsmLiveDimens.hundred,
                            ),
                            title: viewer.userName,
                            subTitle: null,
                            buttonLable: 'View Profile',
                            onTap: () {
                              IsmLiveDelegate.openUserProfileView
                                  ?.call(viewer.identifier);
                            },
                          ),
                          isScrollController: true,
                        );
                      }
                    },
                  ),
                ),
              );
            },
          ),
        ),
      );
}

class _TopDarkGradient extends StatelessWidget {
  const _TopDarkGradient();

  @override
  Widget build(BuildContext context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        height: MediaQuery.of(context).size.height * 0.3,
        child: const IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black54,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      );
}

class _BottomDarkGradient extends StatelessWidget {
  const _BottomDarkGradient();

  @override
  Widget build(BuildContext context) => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        height: MediaQuery.of(context).size.height * 0.3,
        child: const IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black54,
                ],
              ),
            ),
          ),
        ),
      );
}

class ScheduleStreamView extends StatelessWidget {
  const ScheduleStreamView({super.key, required this.isKeyboardOpen});

  final bool isKeyboardOpen;

  /// Wraps IsmLiveChatView with conditional width constraints
  /// When productStream is true, limits width to half screen width
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

    // Apply width constraint only when productStream is enabled
    if (IsmLiveDelegate.productStream == true) {
      return Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.5,
          ),
          child: chatView,
        ),
      );
    }

    return chatView;
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
          color: Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.withOpacity(0.5)),
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

  @override
  Widget build(BuildContext context) => SafeArea(
        child: GetBuilder<IsmLiveStreamController>(
          builder: (controller) => Column(
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
                                    disabled:
                                        !_IsmLiveStreamView.isValidStreamId(
                                            controller.streamId),
                                  ),
                                ) ??
                                IsmLiveMessageField(
                                  streamId: () {
                                    // Debug logging for streamId at line 903
                                    final streamId =
                                        controller.streamDetails?.streamId ??
                                            '';
                                    return streamId;
                                  }(),
                                  isHost: controller.isPublishing,
                                  disabled: !_IsmLiveStreamView.isValidStreamId(
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
                              isHost: true,
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
        ),
      );
}
