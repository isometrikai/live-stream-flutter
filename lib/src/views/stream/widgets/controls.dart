import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/widgets/custom_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

class IsmLiveControlsWidget extends StatelessWidget {
  const IsmLiveControlsWidget(
    this.room,
    this.participant, {
    Key? key,
    required this.meetingId,
    required this.audioCallOnly,
  }) : super(key: key);

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
                icon: IsmLiveImage.svg(
                  IsmLiveAssetConstants.icMembersLiveStream,
                  dimensions: IsmLiveDimens.fifty,
                ),
                onTap: () {},
                color: IsmLiveColors.transparent,
              ),
              CustomIconButton(
                icon: IsmLiveImage.svg(
                  IsmLiveAssetConstants.icMultiLiveStream,
                  dimensions: IsmLiveDimens.fifty,
                ),
                onTap: () {},
                color: IsmLiveColors.transparent,
              ),
              CustomIconButton(
                icon: IsmLiveImage.svg(
                  IsmLiveAssetConstants.icGiftStream,
                  dimensions: IsmLiveDimens.fifty,
                ),
                onTap: () {},
                color: IsmLiveColors.transparent,
              ),
              CustomIconButton(
                icon: IsmLiveImage.svg(
                  IsmLiveAssetConstants.icFavouriteStream,
                  dimensions: IsmLiveDimens.fifty,
                ),
                onTap: () {},
                color: IsmLiveColors.transparent,
              ),
              CustomIconButton(
                icon: IsmLiveImage.svg(
                  IsmLiveAssetConstants.icSettingStream,
                  dimensions: IsmLiveDimens.fifty,
                ),
                onTap: () {},
                color: IsmLiveColors.transparent,
              ),
              CustomIconButton(
                icon: IsmLiveImage.svg(
                  IsmLiveAssetConstants.icShareLiveStream,
                  dimensions: IsmLiveDimens.fifty,
                ),
                onTap: () {},
                color: IsmLiveColors.transparent,
              ),
              CustomIconButton(
                icon: IsmLiveImage.svg(
                  IsmLiveAssetConstants.icRotateCamera,
                  dimensions: IsmLiveDimens.fifty,
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
