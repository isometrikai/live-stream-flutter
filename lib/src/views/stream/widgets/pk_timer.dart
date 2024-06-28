import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLivePkTimerContainer extends StatelessWidget {
  const IsmLivePkTimerContainer({super.key});

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Align(
            alignment:
                Alignment(0, IsmLiveUtility.alignY(IsmLiveDimens.twoHundred)),
            child: const IsmLiveImage.svg(
              IsmLiveAssetConstants.timerContainer,
            ),
          ),
          Align(
            alignment:
                Alignment(0, IsmLiveUtility.alignY(IsmLiveDimens.twoHundred)),
            child: GetX<IsmLivePkController>(
              builder: (controller) => Text(
                controller.pkDuration.formattedTimeInMin,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: Colors.yellow,
                ),
              ),
            ),
          ),
        ],
      );
}
