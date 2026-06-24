import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveScheduleSettingsSheet extends StatelessWidget {
  const IsmLiveScheduleSettingsSheet({
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
            title: IsmLiveStrings.scheduleStream,
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
                    color: textIconColor,
                  ),
                  IsmLiveDimens.boxWidth10,
                  Text(
                    IsmLiveScheduleSettings.values[index].label,
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
