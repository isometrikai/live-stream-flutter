import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveControlsWidget extends StatelessWidget {
  const IsmLiveControlsWidget({
    super.key,
    required this.isHost,
    required this.streamId,
    required this.isCopublishing,
  });

  final bool isHost;
  final bool isCopublishing;
  final String streamId;

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
          var options = !isHost
              ? IsmLiveStreamOption.viewersOptions
              : isCopublishing
                  ? IsmLiveStreamOption.copublisherOptions
                  : IsmLiveStreamOption.hostOptions;

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  alignment: Alignment.bottomRight,
                  width: IsmLiveDimens.fifty,
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (_, __) => IsmLiveDimens.boxHeight8,
                    itemBuilder: (context, index) => CustomIconButton(
                      dimension: IsmLiveDimens.fortyFive,
                      icon: IsmLiveImage.svg(
                        controller.controlIcon(options[index]),
                      ),
                      onTap: () async {
                        await controller.onOptionTap(options[index]);
                        controller.update([IsmLiveControlsWidget.updateId]);
                      },
                      color: options[index] == IsmLiveStreamOption.heart
                          ? IsmLiveColors.red
                          : options[index] == IsmLiveStreamOption.multiLive
                              ? !isHost && controller.isCopublisher != true
                                  ? controller.memberStatus.canEnableVideo
                                      ? context.theme.primaryColor
                                      : controller.memberStatus.didRequested
                                          ? Colors.blueGrey
                                          : null
                                  : null
                              : null,
                    ),
                  ),
                ),
                // if (isHost)
                //   Container(
                //     height: IsmLiveDimens.twoHundred - IsmLiveDimens.eight,
                //     width: Get.width * 0.4,
                //     padding: IsmLiveDimens.edgeInsets0_4,
                //     child: IsmLiveProductContainer(
                //       productName: 'SOLD',
                //       productDisc: 'hdshhdsfhjdsjsdj',
                //       currencyIcon: '\$',
                //       price: 33.33,
                //       onPress: () {},
                //       imageUrl: '',
                //     ),
                //   )
              ],
            ),
          );
        },
      );
}
