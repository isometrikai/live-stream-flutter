import 'dart:math';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

String _participantProfileImageUrl(
    IsmLiveStreamController controller, int index) {
  for (final element in controller.streamMembersList) {
    if (element.userId ==
        controller.participantList[index].participant.identity) {
      return element.userProfileImageUrl;
    }
  }
  return '';
}

String _participantFullName(IsmLiveStreamController controller, int index) {
  final participant = controller.participantList[index].participant;
  return ParticipantWidget.resolvedDisplayNameForParticipant(participant);
}

Widget _multiParticipantTile(
  IsmLiveStreamController controller,
  int index, {
  required int participantCount,
}) {
  final base = ParticipantWidget.widgetFor(
    controller.participantList[index],
    imageUrl: _participantProfileImageUrl(controller, index),
    isFirstIndex: index == 0,
    isViewer: !(controller.userRole?.isHost ?? false) &&
        !(controller.userRole?.isPkGuest ?? false) &&
        (controller.pkStages?.isPkStart ?? false),
    isHost: index == 0,
    showStatsLayer: controller.isPk,
    isWinner: controller.pkWinnerId ==
        controller.participantList[index].participant.identity,
    isbattleFinish: (controller.pkStages?.isPkStop ?? false) &&
        controller.pkWinnerId != null,
  );

  final showName =
      IsmLiveDelegate.showParticipantFullNamesInPublisherGrid &&
          participantCount > 1;
  if (!showName) {
    return base;
  }

  final fullName = _participantFullName(controller, index);
  if (fullName.isEmpty) {
    return base;
  }

  return Stack(
    fit: StackFit.expand,
    clipBehavior: Clip.hardEdge,
    children: [
      base,
      Positioned(
        left: IsmLiveDimens.eight,
        right: IsmLiveDimens.eight,
        bottom: IsmLiveDimens.eight,
        child: Align(
          alignment: Alignment.bottomLeft,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(IsmLiveDimens.four),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: IsmLiveDimens.eight,
                vertical: IsmLiveDimens.four,
              ),
              child: Text(
                fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: IsmLiveDimens.twelve,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

class IsmLivePublisherGrid extends StatelessWidget {
  const IsmLivePublisherGrid({
    super.key,
    required this.streamImage,
    this.isInteractive = false,
    this.isSchedule = false,
  });

  final String streamImage;
  final bool isInteractive;
  final bool isSchedule;

  static const String updateId = 'publisher-grid';

  /// Lower bound on grid height as a fraction of available viewport below the top inset.
  /// Pairs with 16:9 intrinsic sizing: common live apps use large tiles for few hosts
  /// (side-by-side ~half screen for 2) and scale up as the grid grows (2×2, 3×3, …).
  static double _minHeightFractionForParticipantCount(int count) {
    assert(count >= 2);
    if (count == 2) return 0.5;
    if (count == 3) return 1.0 / 3.0;
    if (count == 4) return 0.48;
    if (count <= 6) return 0.52;
    if (count <= 9) return 0.58;
    return 0.68;
  }

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: updateId,
        builder: (controller) => Obx(
          () {
            late final Widget child;
            if (controller.isRtmp) {
              child = controller.participantTracks.isNotEmpty
                  ? const _RtmlView()
                  : NoVideoWidget(
                      imageUrl: controller.hostDetails?.image ?? streamImage,
                      name: controller.hostDetails?.name ?? '',
                      showConnectingState: controller.isViewerJoiningStream,
                      connectingText: context.liveTranslations
                              ?.streamTranslations?.connectingToLiveStream ??
                          IsmLiveStrings.connectingToLiveStream,
                      initials: controller.hostDetails?.profileInitials,
                    );
            } else if (controller.participantTracks.isEmpty) {
              final streamIdOkForScheduled = !isSchedule ||
                  IsmLiveStreamId.isValid(controller.streamId);
              child = streamIdOkForScheduled
                  ? NoVideoWidget(
                      imageUrl: controller.hostDetails?.image ?? streamImage,
                      name: controller.hostDetails?.name ?? '',
                      showConnectingState: controller.isViewerJoiningStream,
                      connectingText: context.liveTranslations
                              ?.streamTranslations?.connectingToLiveStream ??
                          IsmLiveStrings.connectingToLiveStream,
                      initials: controller.hostDetails?.profileInitials,
                    )
                  : const SizedBox.shrink();
            } else if (controller.participantTracks.length == 1) {
              child = InteractiveViewer(
                maxScale: isInteractive ? 3 : 1,
                panEnabled: isInteractive,
                scaleEnabled: isInteractive,
                child: SizedBox.expand(
                  child: ParticipantWidget.widgetFor(
                    controller.participantTracks.first,
                    imageUrl: controller.hostDetails?.userProfileImageUrl,
                    showStatsLayer: false,
                    showFullVideo: isInteractive,
                  ),
                ),
              );
            } else {
              child = LayoutBuilder(
                builder: (context, constraints) {
                  final participantCount = controller.participantTracks.length;

                  if (!IsmLiveDelegate.useGridLayoutForMultipleParticipants) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: List<Widget>.generate(
                        participantCount,
                        (index) => Expanded(
                          child: _multiParticipantTile(
                            controller,
                            index,
                            participantCount: participantCount,
                          ),
                        ),
                      ),
                    );
                  }

                  final topPad = IsmLiveDimens.hundred;

                  final mq = MediaQuery.of(context);
                  final imeBottom = mq.viewInsets.bottom;
                  final viewportCap =
                      max(1.0, mq.size.height - mq.viewPadding.vertical);
                  // Ancestors may shrink [constraints.maxHeight] when the IME is open.
                  // Use full-viewport height for grid math so tiles match the full-bleed
                  // video layer; [UnconstrainedBox] below lets this paint past the
                  // shrunk layout box when needed (stream Stack uses [Clip.none]).
                  final layoutViewportHeight = min(
                    constraints.maxHeight + imeBottom,
                    viewportCap,
                  );

                  final maxGridHeight =
                      max(1.0, layoutViewportHeight - topPad);
                  final crossCount = participantCount < 3 ? 2 : 3;
                  final rowCount =
                      (participantCount + crossCount - 1) ~/ crossCount;
                  const crossSpacing = 0.0;
                  const mainSpacing = 0.0;
                  final crossExtent =
                      (constraints.maxWidth - (crossCount - 1) * crossSpacing) /
                          crossCount;
                  // Prefer 16:9 tiles, but enforce a minimum grid height by participant
                  // count so 1×2 / 2×2 / 3×3 style layouts stay readable on phones.
                  const videoTileAspectRatio = 16.0 / 9.0;
                  final idealMainExtent = crossExtent / videoTileAspectRatio;
                  final intrinsicGridHeight =
                      rowCount * idealMainExtent + (rowCount - 1) * mainSpacing;
                  final minDesiredHeight = maxGridHeight *
                      _minHeightFractionForParticipantCount(participantCount);
                  final gridHeight = min(
                    max(intrinsicGridHeight, minDesiredHeight),
                    maxGridHeight,
                  );
                  final mainExtent =
                      (gridHeight - (rowCount - 1) * mainSpacing) / rowCount;
                  // childAspectRatio = cross/main. An upper clamp (e.g. 4.0) made
                  // cells taller than [mainExtent], clipping the last row when
                  // height is tight (IME). Keep only a small positive floor.
                  final aspectRatio = max(crossExtent / mainExtent, 0.02);

                  return Align(
                    alignment: Alignment.topCenter,
                    child: UnconstrainedBox(
                      constrainedAxis: Axis.horizontal,
                      clipBehavior: Clip.none,
                      child: SizedBox(
                        width: constraints.maxWidth,
                        height: layoutViewportHeight,
                        child: Padding(
                          padding: EdgeInsets.only(top: topPad),
                          child: SizedBox(
                            width: constraints.maxWidth,
                            height: gridHeight,
                            child: GridView.builder(
                              restorationId: '',
                              itemCount: participantCount,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossCount,
                                mainAxisSpacing: mainSpacing,
                                crossAxisSpacing: crossSpacing,
                                childAspectRatio: aspectRatio,
                              ),
                              itemBuilder: (_, index) =>
                                  _multiParticipantTile(
                                    controller,
                                    index,
                                    participantCount: participantCount,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
            return SizedBox.expand(child: child);
          },
        ),
      );
}

class _RtmlView extends StatelessWidget {
  const _RtmlView();

  @override
  Widget build(BuildContext context) => GetX<IsmLiveStreamController>(
        builder: (controller) {
          IsmLiveParticipantTrack? hostScreen;

          for (var value in controller.participantTracks) {
            if (value.participant.identity == controller.hostDetails?.userId) {
              hostScreen = value;
            }
          }

          return Container(
            color: Colors.black,
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: hostScreen == null
                      ? NoVideoWidget(
                          imageUrl: controller.hostDetails?.image ?? '',
                          name: controller.hostDetails?.name ?? '',
                          showConnectingState: controller.isViewerJoiningStream,
                          connectingText: context
                                  .liveTranslations
                                  ?.streamTranslations
                                  ?.connectingToLiveStream ??
                              IsmLiveStrings.connectingToLiveStream,
                          initials: controller.hostDetails?.profileInitials,
                        )
                      : ParticipantWidget.widgetFor(
                          hostScreen,
                          imageUrl: controller.hostDetails?.userProfileImageUrl,
                          showStatsLayer: false,
                          showFullVideo: true,
                        ),
                ),
              ),
            ),
          );
          // IN RTMP NOT REQUIRED MUlTIPLE STREAMS
          // GridView.builder(
          //   padding: IsmLiveDimens.edgeInsets0,
          //   restorationId: '',
          //   itemCount: 4,
          //   shrinkWrap: true,
          //   physics: const NeverScrollableScrollPhysics(),
          //   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          //     crossAxisCount: 4,
          //     childAspectRatio: 0.5,
          //   ),
          //   itemBuilder: (_, index) {
          //     if (controller.participantTracks.length > index &&
          //         hostScreen != controller.participantTracks[index]) {
          //       var url = '';
          //       for (var element in controller.streamMembersList) {
          //         if (element.userId ==
          //             controller
          //                 .participantList[index].participant.identity) {
          //           url = element.userProfileImageUrl;
          //         }
          //       }

          //       return ParticipantWidget.widgetFor(
          //         controller.participantList[index],
          //         imageUrl: url,
          //       );
          //     }
          //     return const NoVideoIconWidget();
          //   },
          // )
          // ],
          // )
        },
      );
}
