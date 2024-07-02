import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLivePkTimerContainer extends StatelessWidget {
  const IsmLivePkTimerContainer({super.key});

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          const Align(
            alignment: Alignment(0, -0.4),
            child: IsmLiveImage.svg(
              IsmLiveAssetConstants.timerContainer,
            ),
          ),
          Align(
            alignment: const Alignment(0, -0.4),
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
