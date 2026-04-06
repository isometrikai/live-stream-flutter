import 'dart:math';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
                    );
            } else if (controller.participantTracks.isEmpty) {
              child = !isSchedule
                  ? NoVideoWidget(
                      imageUrl: controller.hostDetails?.image ?? streamImage,
                      name: controller.hostDetails?.name ?? '',
                      showConnectingState: controller.isViewerJoiningStream,
                      connectingText: context.liveTranslations
                              ?.streamTranslations?.connectingToLiveStream ??
                          IsmLiveStrings.connectingToLiveStream,
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
                  final topPad = IsmLiveDimens.hundred;
                  final maxGridHeight =
                      max(1.0, constraints.maxHeight - topPad);
                  final crossCount =
                      controller.participantTracks.length < 3 ? 2 : 3;
                  final rowCount =
                      (controller.participantTracks.length + crossCount - 1) ~/
                          crossCount;
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
                  final participantCount = controller.participantTracks.length;
                  final minDesiredHeight = maxGridHeight *
                      _minHeightFractionForParticipantCount(participantCount);
                  final gridHeight = min(
                    max(intrinsicGridHeight, minDesiredHeight),
                    maxGridHeight,
                  );
                  final mainExtent =
                      (gridHeight - (rowCount - 1) * mainSpacing) / rowCount;
                  final aspectRatio =
                      (crossExtent / mainExtent).clamp(0.25, 4.0);

                  return Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      padding: EdgeInsets.only(top: topPad),
                      child: SizedBox(
                        width: constraints.maxWidth,
                        height: gridHeight,
                        child: GridView.builder(
                          restorationId: '',
                          itemCount: controller.participantTracks.length,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossCount,
                            mainAxisSpacing: mainSpacing,
                            crossAxisSpacing: crossSpacing,
                            childAspectRatio: aspectRatio,
                          ),
                          itemBuilder: (_, index) {
                            var url = '';

                            for (var element in controller.streamMembersList) {
                              if (element.userId ==
                                  controller.participantList[index].participant
                                      .identity) {
                                url = element.userProfileImageUrl;
                              }
                            }

                            return ParticipantWidget.widgetFor(
                              controller.participantList[index],
                              imageUrl: url,
                              isFirstIndex: index == 0,
                              isViewer: !(controller.userRole?.isHost ??
                                      false) &&
                                  !(controller.userRole?.isPkGuest ?? false) &&
                                  (controller.pkStages?.isPkStart ?? false),
                              isHost: index == 0,
                              showStatsLayer: controller.isPk,
                              isWinner: controller.pkWinnerId ==
                                  controller.participantList[index].participant
                                      .identity,
                              isbattleFinish:
                                  (controller.pkStages?.isPkStop ?? false) &&
                                      controller.pkWinnerId != null,
                            );
                          },
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
