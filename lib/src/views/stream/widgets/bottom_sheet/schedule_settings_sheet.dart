import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveScheduleSettingsSheet extends StatelessWidget {
  const IsmLiveScheduleSettingsSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        builder: (controller) => Padding(
          padding: IsmLiveDimens.edgeInsets16_0_16_20,
          child: IsmLiveScrollSheet(
            separatedWidgat: IsmLiveDimens.boxHeight24,
            title: 'Schedule Stream',
            showHeader: false,
            showCancelIcon: true,
            itemCount: IsmLiveScheduleSettings.values.length,
            itemBuilder: (context, index) => IsmLiveTapHandler(
              onTap: () {
                controller.onScheduleSettingTap(
                  IsmLiveScheduleSettings.values[index],
                );
              },
              child: Row(
                children: [
                  IsmLiveImage.svg(
                    IsmLiveScheduleSettings.values[index].icon,
                  ),
                  IsmLiveDimens.boxWidth10,
                  Text(
                    IsmLiveScheduleSettings.values[index].label,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
