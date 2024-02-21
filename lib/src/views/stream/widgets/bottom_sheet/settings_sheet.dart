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
          showHeader: false,
          showCancelIcon: true,
          itemCount: IsmLiveHostSettings.values.length,
          itemBuilder: (context, index) => IsmLiveTapHandler(
            onTap: () {
              controller.onSettingTap(
                IsmLiveHostSettings.values[index],
              );
            },
            child: ListTile(
              leading: IsmLiveImage.svg(
                IsmLiveHostSettings.values[index].icon,
              ),
              title: Text(
                controller.controlSetting(
                  IsmLiveHostSettings.values[index],
                ),
              ),
            ),
          ),
        ),
      );
}
