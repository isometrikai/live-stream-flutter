import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/widgets/custom_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

class IsmLiveControlsWidget extends StatelessWidget {
  const IsmLiveControlsWidget(
    this.room,
    this.participant, {
    super.key,
    required this.meetingId,
    required this.audioCallOnly,
  });

  final Room room;
  final LocalParticipant participant;
  final String meetingId;
  final bool audioCallOnly;

  static const String updateId = 'ism-live-controls';

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: updateId,
        initState: (state) {
          final streamController = Get.find<IsmLiveStreamController>();

          participant.addListener(streamController.update);
        },
        dispose: (state) async {
          final streamController = Get.find<IsmLiveStreamController>();

          participant.removeListener(streamController.update);
        },
        builder: (controller) {
          var options = participant.videoTracks.isEmpty
              ? IsmLiveStreamOption.viewersOptions
              : IsmLiveStreamOption.hostOptions;

          return Container(
            alignment: Alignment.bottomRight,
            width: IsmLiveDimens.fifty,
            child: ListView.builder(
              shrinkWrap: true,
              itemBuilder: (context, index) => CustomIconButton(
                icon: IsmLiveImage.svg(controller.controlIcon(options[index])),
                onTap: () async {
                  await controller.onOptionTap(options[index],
                      participant: participant, room: room);
                  controller.update([IsmLiveControlsWidget.updateId]);
                },
                color: IsmLiveColors.transparent,
              ),
              itemCount: options.length,
            ),
          );
        },
      );
}
