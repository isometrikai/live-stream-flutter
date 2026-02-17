import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveScheduleTimeBottomSheet extends StatelessWidget {
  const IsmLiveScheduleTimeBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textIconColor = isDarkMode ? Colors.white : Colors.black;
    final dividerColor = context.liveTheme?.borderColor ??
        (isDarkMode ? const Color(0xFF1E1E1E) : Colors.grey.shade300);

    return Container(
      decoration: BoxDecoration(
        color: context.liveTheme?.backgroundColor ??
            (isDarkMode ? const Color(0xFF121212) : Colors.white),
        borderRadius: IsmLiveDelegate.bottomSheetBorderRadius ??
            BorderRadius.vertical(
              top: Radius.circular(IsmLiveDimens.twelve),
            ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IsmLiveDimens.boxHeight10,
          Padding(
            padding: EdgeInsets.symmetric(
                vertical: IsmLiveDimens.four,
                horizontal: IsmLiveDimens.twelve),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  IsmLiveStrings.scheduleStream,
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textIconColor,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: textIconColor),
                  onPressed: IsmLiveRoute.pop,
                ),
              ],
            ),
          ),
          Divider(color: dividerColor),
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.3,
            child: GetBuilder<IsmLiveStreamController>(
              builder: (controller) => CupertinoDatePicker(
                minimumDate: DateTime.now(),
                onDateTimeChanged: (date) {
                  controller.scheduleLiveDate = date;
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(IsmLiveDimens.twelve),
            child: IsmLiveButton(
              label: IsmLiveStrings.confirm,
              onTap: IsmLiveRoute.pop,
            ),
          ),
        ],
      ),
    );
  }
}
