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
                      imageUrl: controller.user?.profileUrl,
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
                        crossAxisCount: controller.participantTracks.length < 5 ? 2 : 3,
                        childAspectRatio: controller.participantTracks.length < 3
                            ? 0.5
                            : controller.participantTracks.length < 5
                                ? 0.9
                                : 0.6,
                      ),
                      itemBuilder: (_, index) => ParticipantWidget.widgetFor(
                        controller.participantTracks[index],
                        imageUrl: controller.user?.profileUrl,
                        showStatsLayer: false,
                      ),
                    ),
                  )
            : NoVideoWidget(
                imageUrl: controller.hostDetails?.userProfileImageUrl ?? streamImage,
                name: controller.hostDetails?.userName ?? 'U',
              ),
      );
}
