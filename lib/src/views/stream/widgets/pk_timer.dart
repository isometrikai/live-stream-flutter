import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLivePkTimerContainer extends StatelessWidget {
  const IsmLivePkTimerContainer({super.key});

  @override
  Widget build(BuildContext context) => Container(
        width: IsmLiveDimens.eighty,
        height: IsmLiveDimens.eighty,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.yellow, Colors.green, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'VS',
              style: context.textTheme.bodyLarge
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            IsmLiveDimens.boxHeight2,
            GetX<IsmLivePkController>(
              builder: (controller) => Text(
                controller.pkDuration.formattedTimeInMin,
                style: context.textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      );
}
