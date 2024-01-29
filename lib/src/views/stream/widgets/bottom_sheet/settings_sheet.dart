import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveSettingsSheet extends StatelessWidget {
  const IsmLiveSettingsSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        builder: (controller) => IsmLiveScrollSheet(
          title: 'Settings',
          itemCount: IsmLiveHostSettings.values.length,
          itemBuilder: (context, index) => IsmLiveTapHandler(
            onTap: () {
              controller.onSettingTap(
                IsmLiveHostSettings.values[index],
              );
            },
            child: Container(
              margin: IsmLiveDimens.edgeInsets0_4,
              child: Text(
                controller.controlSetting(
                  IsmLiveHostSettings.values[index],
                ),
              ),
            ),
          ),
          separatorBuilder: (context, index) => const Divider(
            thickness: 0.5,
          ),
        ),
      );
}
