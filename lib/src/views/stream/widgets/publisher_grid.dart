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

  @override
  Widget build(BuildContext context) => GetX<IsmLiveStreamController>(
        builder: (controller) => controller.participantTracks.isNotEmpty
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
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            controller.participantTracks.length < 5 ? 2 : 3,
                        childAspectRatio:
                            controller.participantTracks.length < 3
                                ? (Get.width / 2) / (Get.height * 0.43)
                                : controller.participantTracks.length < 5
                                    ? (Get.width / 3) / (Get.height / 3)
                                    : 1,
                      ),
                      itemBuilder: (_, index) {
                        var url = '';
                        var participantList = controller.userRole?.isHost ??
                                false
                            ? controller.participantTracks
                            : controller.participantTracks.reversed.toList();

                        for (var element in controller.streamMembersList) {
                          if (element.userId ==
                              participantList[index].participant.identity) {
                            url = element.userProfileImageUrl;
                          }
                        }

                        return ParticipantWidget.widgetFor(
                          participantList[index],
                          imageUrl: url,
                          isFirstIndex: index == 0,
                          isViewer: !(controller.userRole?.isHost ?? false) &&
                              !(controller.userRole?.isPkGuest ?? false),
                          isHost: controller.hostDetails?.userId ==
                              participantList[index].participant.identity,
                          showStatsLayer: controller.isPk,
                          isWinner: controller.hostDetails?.userId ==
                              participantList[index].participant.identity,
                          isbattleFinish:
                              controller.pkStages?.isPkStop ?? false,
                        );
                      },
                    ),
                  )
            : NoVideoWidget(
                imageUrl: controller.hostDetails?.image ?? streamImage,
                name: controller.hostDetails?.name ?? 'U',
              ),
      );
}
