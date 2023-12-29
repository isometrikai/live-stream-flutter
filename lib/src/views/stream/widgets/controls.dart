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

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        initState: (state) {
          final streamController = Get.find<IsmLiveStreamController>();

          participant.addListener(streamController.update);
        },
        dispose: (state) async {
          final streamController = Get.find<IsmLiveStreamController>();

          participant.removeListener(streamController.update);
        },
        builder: (controller) => Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomIconButton(
                icon: const IsmLiveImage.svg(
                  IsmLiveAssetConstants.icMembersLiveStream,
                ),
                onTap: () {},
                color: IsmLiveColors.transparent,
              ),
              CustomIconButton(
                icon: const IsmLiveImage.svg(
                  IsmLiveAssetConstants.icMultiLiveStream,
                ),
                onTap: () {},
                color: IsmLiveColors.transparent,
              ),
              CustomIconButton(
                icon: const IsmLiveImage.svg(
                  IsmLiveAssetConstants.icGiftStream,
                ),
                onTap: () {},
                color: IsmLiveColors.transparent,
              ),
              CustomIconButton(
                icon: const IsmLiveImage.svg(
                  IsmLiveAssetConstants.icFavouriteStream,
                ),
                onTap: () {},
                color: IsmLiveColors.transparent,
              ),
              CustomIconButton(
                icon: const IsmLiveImage.svg(
                  IsmLiveAssetConstants.icSettingStream,
                ),
                onTap: () {},
                color: IsmLiveColors.transparent,
              ),
              CustomIconButton(
                icon: const IsmLiveImage.svg(
                  IsmLiveAssetConstants.icShareLiveStream,
                ),
                onTap: () {},
                color: IsmLiveColors.transparent,
              ),
              CustomIconButton(
                icon: const IsmLiveImage.svg(
                  IsmLiveAssetConstants.icRotateCamera,
                ),
                onTap: () {
                  controller.toggleCamera(participant);
                },
                color: IsmLiveColors.transparent,
              ),
            ],
          ),
        ),
      );
}
