import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLivePublisherGrid extends StatelessWidget {
  const IsmLivePublisherGrid({
    super.key,
    required this.streamImage,
    this.isInteractive = false,
  });

  final String streamImage;
  final bool isInteractive;

  static const String updateId = 'publisher-grid';

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: updateId,
        builder: (controller) => Obx(
          () {
            if (controller.isRtmp) {
              return controller.participantTracks.isNotEmpty
                  ? const _RtmlView()
                  : NoVideoWidget(
                      imageUrl: controller.hostDetails?.image ?? streamImage,
                      name: controller.hostDetails?.name ?? 'U',
                    );
            }
            return controller.participantTracks.isNotEmpty
                ? controller.participantTracks.length == 1
                    ? InteractiveViewer(
                        maxScale: isInteractive ? 3 : 1,
                        panEnabled: isInteractive,
                        scaleEnabled: isInteractive,
                        child: ParticipantWidget.widgetFor(
                          controller.participantTracks.first,
                          imageUrl: controller.hostDetails?.userProfileImageUrl,
                          showStatsLayer: false,
                          showFullVideo: isInteractive,
                        ),
                      )
                    : Padding(
                        padding: IsmLiveDimens.edgeInsetsT100,
                        child: GridView.builder(
                          restorationId: '',
                          itemCount: controller.participantTracks.length,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                controller.participantTracks.length < 3 ? 2 : 3,
                            childAspectRatio:
                                controller.participantTracks.length < 3
                                    ? (Get.width / 2) / (Get.height * 0.4)
                                    : controller.participantTracks.length < 7
                                        ? (Get.width / 3) / (Get.height * 0.3)
                                        : 1,
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
                      )
                : NoVideoWidget(
                    imageUrl: controller.hostDetails?.image ?? streamImage,
                    name: controller.hostDetails?.name ?? 'U',
                  );
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

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IsmLiveDimens.boxHeight50,
              IsmLiveDimens.boxHeight50,
              SizedBox(
                height: Get.height * 0.3,
                child: hostScreen == null
                    ? NoVideoWidget(
                        imageUrl: controller.hostDetails?.image ?? '',
                        name: controller.hostDetails?.name ?? 'U',
                      )
                    : ParticipantWidget.widgetFor(
                        hostScreen,
                        imageUrl: controller.hostDetails?.userProfileImageUrl,
                        showStatsLayer: false,
                        showFullVideo: true,
                      ),
              ),
              GridView.builder(
                padding: IsmLiveDimens.edgeInsets0,
                restorationId: '',
                itemCount: 4,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 0.5,
                ),
                itemBuilder: (_, index) {
                  if (controller.participantTracks.length > index &&
                      hostScreen != controller.participantTracks[index]) {
                    var url = '';
                    for (var element in controller.streamMembersList) {
                      if (element.userId ==
                          controller
                              .participantList[index].participant.identity) {
                        url = element.userProfileImageUrl;
                      }
                    }

                    return ParticipantWidget.widgetFor(
                      controller.participantList[index],
                      imageUrl: url,
                    );
                  }
                  return const NoVideoIconWidget();
                },
              )
            ],
          );
        },
      );
}
