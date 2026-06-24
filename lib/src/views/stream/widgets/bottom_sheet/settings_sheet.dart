import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveSettingsSheet extends StatelessWidget {
  const IsmLiveSettingsSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textIconColor = isDarkMode ? Colors.white : Colors.black;

    return GetBuilder<IsmLiveStreamController>(
      builder: (controller) => Container(
        decoration: BoxDecoration(
          color: context.liveTheme?.backgroundColor ??
              (isDarkMode ? const Color(0xFF121212) : Colors.white),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(
              IsmLiveDelegate.bottomSheetBorderRadius?.topLeft.x ??
                  IsmLiveDimens.thirty,
            ),
          ),
        ),
        child: Padding(
          padding: IsmLiveDimens.edgeInsets16_0_16_20.copyWith(bottom: 0),
          child: IsmLiveScrollSheet(
            separatedWidgat: IsmLiveDimens.boxHeight24,
            title: 'Settings',
            showHeader: false,
            showCancelIcon: true,
            cancelIconColor: textIconColor,
            itemCount: IsmLiveHostSettings.values.length,
            itemBuilder: (context, index) => IsmLiveTapHandler(
              onTap: () {
                controller.onSettingTap(
                  IsmLiveHostSettings.values[index],
                );
              },
              child: Row(
                children: [
                  IsmLiveImage.svg(
                    controller
                        .controlSettingIcon(IsmLiveHostSettings.values[index]),
                    color: textIconColor,
                  ),
                  IsmLiveDimens.boxWidth10,
                  Text(
                    controller.controlSetting(
                      IsmLiveHostSettings.values[index],
                    ),
                    style: context.dynamicTextTheme.bodyMedium?.copyWith(
                      color: textIconColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
