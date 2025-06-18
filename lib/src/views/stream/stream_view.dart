import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        isScrolling = Get.arguments['isScrolling'],
        isSchedule = Get.arguments['isSchedule'],
        isInteractive = Get.arguments['isInteractive'];

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

  @override
  Widget build(BuildContext context) {
    log('IsmLiveStreamView: isHost: $isHost');
    if (isHost) {
      return _IsmLiveStreamView(
        key: key,
        streamImage: streamImage,
        streamId: streamId,
        isHost: isHost,
        isNewStream: isNewStream,
        isInteractive: isInteractive,
        isSchedule: isSchedule,
      );
    } else if (!isScrolling) {
      return _IsmLiveStreamView(
        key: key,
        streamImage: streamImage,
        streamId: streamId,
        isHost: false,
        isNewStream: false,
        isInteractive: isInteractive,
        isSchedule: isSchedule,
      );
    }
    return GetX<IsmLiveStreamController>(
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
          index: index,
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
            isSchedule: isSchedule,
          );
        },
      ),
    );
  }
}

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
  bool _isInPipMode = false;

  @override
  void initState() {
    super.initState();
    _setupPipMode();
  }

  void _setupPipMode() {
    if (Platform.isAndroid) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
        ),
      );
    }
  }

  Future<void> _enterPipMode() async {
    debugPrint('Attempting to enter PiP mode...');
    if (Platform.isAndroid) {
      try {
        debugPrint('Platform is Android, setting system UI mode...');
        await SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.immersiveSticky,
        );
        await SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.manual,
          overlays: [],
        );
        setState(() {
          _isInPipMode = true;
        });
        debugPrint('Successfully entered PiP mode');
      } catch (e) {
        debugPrint('Error entering PiP mode: $e');
      }
    } else if (Platform.isIOS) {
      debugPrint('Platform is iOS, PiP is handled automatically');
      setState(() {
        _isInPipMode = true;
      });
    }
  }

  Future<void> _exitPipMode() async {
    if (Platform.isAndroid) {
      try {
        await SystemChrome.setEnabledSystemUIMode(
          SystemUiMode.edgeToEdge,
        );
        setState(() {
          _isInPipMode = false;
        });
      } catch (e) {
        debugPrint('Error exiting PiP mode: $e');
      }
    } else if (Platform.isIOS) {
      setState(() {
        _isInPipMode = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: IsmLiveStreamView.updateId,
        initState: (_) async {
          var controller = Get.find<IsmLiveStreamController>();
          unawaited(controller.initAnimation());

          controller.participantList = controller.participantTracks;

          await WakelockPlus.enable();
          IsmLiveUtility.updateLater(() {
            if (widget.isHost) {
              if (controller.isRtmp && !controller.usePersistentStreamKey) {
                controller.rtmpSheet();
              } else if (controller.isRtmp) {
              } else {
                Get.find<IsmLiveStreamController>().askPublish();
              }
            }
          });
        },
        builder: (controller) => PopScope(
          canPop: false,
          onPopInvoked: (didPop) async {
            if (!didPop) {
              if (!_isInPipMode) {
                await _enterPipMode();
              } else {
                await _exitPipMode();
              }
            }
          },
          child: Scaffold(
            backgroundColor:
                context.liveTheme?.streamBackgroundColor ?? IsmLiveColors.black,
            body: Stack(
              children: [
                IsmLiveStreamBanner(widget.streamImage),
                const _TopDarkGradient(),
                IsmLivePublisherGrid(
                  streamImage: widget.streamImage ?? '',
                  isInteractive: widget.isInteractive,
                ),
                const _BottomDarkGradient(),
                Align(
                  alignment: IsmLiveApp.headerPosition,
                  child: Obx(
                    () => ((controller.room?.localParticipant != null) &&
                                IsmLiveApp.showHeader) ||
                            widget.isSchedule
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
                                                  streamId: widget.streamId,
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
                                        isHost: widget.isHost,
                                        isCopublishing:
                                            controller.isCopublisher,
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
                      : widget.isSchedule
                          ? const ScheduleStreamView()
                          : const SizedBox.shrink(),
                ),
                Align(
                  alignment: IsmLiveApp.endStreamPosition,
                  child: IsmLiveApp.endButton ??
                      IsmLiveEndStreamButton(
                        onTapExit: () => controller.onExit(
                          isHost: controller.isHost,
                          streamId: widget.streamId,
                        ),
                      ),
                ),
                if (controller.isHost) ...[
                  Positioned(
                    bottom: IsmLiveDimens.eighty,
                    left: IsmLiveDimens.sixteen,
                    child: const IsmLiveModerationWarning(),
                  ),
                  if (widget.isNewStream)
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
            streamCoins: controller.premiumStreamCoinsController.text,
            isBattleTie: controller.pkWinnerId != null,
            winnerName: controller.findWinner(controller.pkWinnerId),
            description: controller.descriptionController.text,
            name: controller.hostDetails?.name ?? 'U',
            imageUrl: controller.hostDetails?.image ?? '',
            pkCompleted: (controller.pkStages?.isPkStop ?? false) &&
                controller.participantTracks.length == 2,
            isPaidStream: controller.isPremium,
            onTapModerators: () {
              IsmLiveUtility.openBottomSheet(
                const IsmLiveModeratorsSheet(),
                isScrollController: true,
              );
            },
            onTapViewers: (viewerList) {
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
                                    child: CustomButton(
                                      title: 'kick out',

                                      onPress: () {
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
                    onViewerProfileTap: (viewer, index) {
                      debugPrint('Viewer profile tapped for user: ${viewer.userId}');
                      var state = context.findAncestorStateOfType<_IsmLiveStreamViewState>();
                      debugPrint('Found state: ${state != null}');
                      if (state != null) {
                        state._enterPipMode();
                      } else {
                        debugPrint('Failed to find _IsmLiveStreamViewState');
                      }
                      IsmLiveDelegate.openUserProfileView?.call(viewer.identifier);
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

class ScheduleStreamView extends StatelessWidget {
  const ScheduleStreamView({super.key});

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
                            IsmLiveChatView(
                              isHost: true,
                              streamId: controller.streamId ?? '',
                            ),
                            IsmLiveDimens.boxHeight8,
                            IsmLiveMessageField(
                              streamId: controller.streamId ?? '',
                              isHost: controller.isPublishing,
                            ),
                          ],
                        ),
                      ),
                      IsmLiveDimens.boxWidth2,
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          IsmLiveControlsWidget(
                            isHost: true,
                            isCopublishing: false,
                            isSchedule: true,
                            streamId: controller.streamId ?? '',
                          ),
                          IsmLiveDimens.boxHeight32,
                          SizedBox(
                            width: Get.width / 3,
                            child: IsmLiveButton(
                              label: 'Go Live',
                              onTap: () {
                                controller.startStream();
                              },
                            ),
                          ),
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
