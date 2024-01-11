import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveControlsWidget extends StatelessWidget {
  const IsmLiveControlsWidget({
    super.key,
    required this.isHost,
    required this.streamId,
    required this.audioCallOnly,
  });

  final bool isHost;
  final String streamId;
  final bool audioCallOnly;

  static const String updateId = 'ism-live-controls';

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: updateId,
        initState: (state) {
          final streamController = Get.find<IsmLiveStreamController>();

          streamController.room?.localParticipant?.addListener(streamController.update);
        },
        dispose: (state) async {
          final streamController = Get.find<IsmLiveStreamController>();

          streamController.room?.localParticipant?.removeListener(streamController.update);
        },
        builder: (controller) {
          var options = !isHost ? IsmLiveStreamOption.viewersOptions : IsmLiveStreamOption.hostOptions;

          return Container(
            alignment: Alignment.bottomRight,
            width: IsmLiveDimens.fifty,
            child: ListView.builder(
              shrinkWrap: true,
              itemBuilder: (context, index) => CustomIconButton(
                icon: IsmLiveImage.svg(controller.controlIcon(options[index])),
                onTap: () async {
                  await controller.onOptionTap(options[index]);
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
