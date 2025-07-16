import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveScheduleTimeBottomSheet extends StatelessWidget {
  const IsmLiveScheduleTimeBottomSheet({super.key});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(IsmLiveDimens.twelve),
          ),
        ),
        padding: IsmLiveDimens.edgeInsets8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IsmLiveDimens.boxHeight10,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Schedule Stream',
                  style: context.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const IconButton(
                  icon: Icon(Icons.close),
                  color: IsmLiveColors.lightGray,
                  onPressed: IsmLiveRoute.pop,
                ),
              ],
            ),
            const Divider(),
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
            const IsmLiveButton(
              label: 'Confirm',
              onTap: IsmLiveRoute.pop,
            ),
          ],
        ),
      );
}
