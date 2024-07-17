import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class IsmLiveStreamView extends StatelessWidget {
  IsmLiveStreamView({
    super.key,
  })  : room = Get.arguments['room'],
        listener = Get.arguments['listener'],
        streamImage = Get.arguments['streamImage'],
        streamId = Get.arguments['streamId'],
        isHost = Get.arguments['isHost'],
        isNewStream = Get.arguments['isNewStream'],
        isInteractive = Get.arguments['isInteractive'];

  final RoomListener listener;
  final Room room;
  final String? streamImage;
  final String streamId;
  final bool isHost;
  final bool isNewStream;
  final bool isInteractive;

  bool get fastConnection => room.engine.fastConnectOptions != null;

  static const String route = IsmLiveRoutes.streamView;

  static const String updateId = 'ismlive-stream-view';

  @override
  Widget build(BuildContext context) {
    if (isHost) {
      return _IsmLiveStreamView(
        key: key,
        streamImage: streamImage,
        streamId: streamId,
        isHost: isHost,
        isNewStream: isNewStream,
        isInteractive: isInteractive,
      );
    }
    return GetX<IsmLiveStreamController>(
      initState: (_) {
        IsmLiveUtility.updateLater(() {
          var controller = Get.find<IsmLiveStreamController>();
          controller.previousStreamIndex =
              controller.pageController?.page?.toInt() ?? 0;
        });
      },
      builder: (controller) => PageView.builder(
        itemCount: controller.streams.length,
        controller: controller.pageController,
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        pageSnapping: true,
        onPageChanged: (index) => controller.onStreamScroll(
          index: index,
          room: room,
        ),
        itemBuilder: (_, index) {
          final stream = controller.streams[index];
          return _IsmLiveStreamView(
            key: key,
            streamImage: stream.streamImage,
            streamId: stream.streamId ?? '',
            isHost: false,
            isNewStream: false,
            isInteractive: isInteractive,
          );
        },
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
  });

  final String? streamImage;
  final String streamId;
  final bool isHost;
  final bool isNewStream;
  final bool isInteractive;

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: IsmLiveStreamView.updateId,
        initState: (_) async {
          var controller = Get.find<IsmLiveStreamController>();
          controller.memberStatus = IsmLiveMemberStatus.notMember;
          controller.participantList = controller.participantTracks;

          controller.initAnimation();
          await WakelockPlus.enable();
          IsmLiveUtility.updateLater(() {
            if (isHost) {
              Get.find<IsmLiveStreamController>().askPublish();
            }
          });
        },
        dispose: (_) async {
          await WakelockPlus.disable();
          var controller = Get.find<IsmLiveStreamController>();
          var pkcontroller = Get.find<IsmLivePkController>();
          pkcontroller.pkBarPersentage = 0;
          pkcontroller.pkBarGustPersentage = 100;
          pkcontroller.pkBarHostPersentage = 100;
          pkcontroller.pkHostValue = 0;
          pkcontroller.pkGustValue = 0;

          controller.showEmojiBoard = false;
          controller.streamMessagesList.clear();
          controller.streamViewersList.clear();
          controller.searchUserFieldController.clear();
          controller.descriptionController.clear();
          controller.messageFieldController.clear();
          controller.searchModeratorFieldController.clear();
          controller.searchCopublisherFieldController.clear();
          controller.searchExistingMembesFieldController.clear();
          controller.searchMembersFieldController.clear();
          controller.copublisherRequestsList.clear();
          controller.animationController.dispose();
          controller.giftType = 0;

          await controller.room?.dispose();
        },
        builder: (controller) => PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor:
                context.liveTheme?.streamBackgroundColor ?? IsmLiveColors.black,
            body: Stack(
              children: [
                IsmLiveStreamBanner(streamImage),
                const _TopDarkGradient(),
                IsmLivePublisherGrid(
                  streamImage: streamImage ?? '',
                  isInteractive: isInteractive,
                ),
                const _BottomDarkGradient(),
                Align(
                  alignment: IsmLiveApp.headerPosition,
                  child: Obx(
                    () => (controller.room?.localParticipant != null) &&
                            IsmLiveApp.showHeader
                        ? IsmLiveApp.streamHeader?.call(
                              context,
                              controller.hostDetails,
                              controller.descriptionController.text,
                            ) ??
                            _StreamHeader(streamId: controller.streamId ?? '')
                        : IsmLiveDimens.box0,
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
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Expanded(
                                        child: IsmLiveApp.bottomBuilder?.call(
                                              context,
                                              controller.hostDetails,
                                              controller
                                                  .descriptionController.text,
                                            ) ??
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                IsmLiveChatView(
                                                  isHost: controller.isHost,
                                                  streamId: streamId,
                                                ),
                                                IsmLiveDimens.boxHeight8,
                                                IsmLiveApp.inputBuilder?.call(
                                                      context,
                                                      IsmLiveMessageField(
                                                        streamId: controller
                                                                .streamId ??
                                                            '',
                                                        isHost: controller
                                                            .isPublishing,
                                                      ),
                                                    ) ??
                                                    Padding(
                                                      padding: IsmLiveDimens
                                                          .edgeInsets8_0,
                                                      child:
                                                          IsmLiveMessageField(
                                                        streamId: controller
                                                                .streamId ??
                                                            '',
                                                        isHost: controller
                                                            .isPublishing,
                                                      ),
                                                    ),
                                              ],
                                            ),
                                      ),
                                      IsmLiveControlsWidget(
                                        isHost: controller.isPublishing,
                                        isCopublishing: controller
                                                .participantTracks.length >
                                            1,
                                        streamId: controller.streamId ?? '',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              IsmLiveDimens.boxHeight8,
                              if (IsmLiveApp.endStreamPosition.isBottomAligned)
                                ...[],
                              if (controller.showEmojiBoard)
                                const IsmLiveEmojis(),
                            ],
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                Align(
                  alignment: IsmLiveApp.endStreamPosition,
                  child: IsmLiveApp.endButton ??
                      IsmLiveEndStreamButton(
                        onTapExit: () => controller.onExit(
                          isHost: controller.isHost,
                          streamId: streamId,
                        ),
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
                      child: const IsmLiveImage.svg(IsmLiveAssetConstants.v),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: controller.alignmentAnimationRight,
                    builder: (context, child) => AnimatedAlign(
                      alignment: controller.alignmentAnimationRight.value,
                      duration: const Duration(
                        milliseconds: 100,
                      ),
                      child: const IsmLiveImage.svg(IsmLiveAssetConstants.s),
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
            isBattleTie: controller.pkWinnerId != null,
            winnerName: controller.findWinner(controller.pkWinnerId),
            description: controller.descriptionController.text,
            name: controller.hostDetails?.name ?? 'U',
            imageUrl: controller.hostDetails?.image ?? '',
            pkCompleted: (controller.pkStages?.isPkStop ?? false) &&
                controller.participantTracks.length == 2,
            onTapModerators: () {
              IsmLiveUtility.openBottomSheet(
                const IsmLiveModeratorsSheet(),
                isScrollController: true,
              );
            },
            onTapViewers: (viewerList) {
              IsmLiveUtility.openBottomSheet(
                GetBuilder<IsmLiveStreamController>(
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
                            : const IsmLiveButton.icon(
                                icon: Icons.group_add_rounded,
                              ),
                  ),
                ),
              );
            },
          ),
        ),
      );
}

class _TopDarkGradient extends StatelessWidget {
  const _TopDarkGradient({super.key});

  @override
  Widget build(BuildContext context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        height: Get.height * 0.3,
        child: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black26,
                Colors.transparent,
              ],
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
        height: Get.height * 0.3,
        child: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black26,
              ],
            ),
          ),
        ),
      );
}
