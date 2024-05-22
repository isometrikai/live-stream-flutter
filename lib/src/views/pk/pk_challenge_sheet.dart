import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLivePkChallengeSheet extends StatelessWidget {
  const IsmLivePkChallengeSheet({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: IsmLiveDimens.edgeInsets16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IsmLiveDimens.boxHeight10,
            Text(
              'PK Challenge Settings',
              style: context.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            IsmLiveDimens.boxHeight2,
            Text(
              'Configure your PK challenge by modifying the settings below',
              style: context.textTheme.bodySmall
                  ?.copyWith(color: Colors.grey.shade400),
            ),
            IsmLiveDimens.boxHeight20,
            Container(
              decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(IsmLiveDimens.eight)),
              child: ListTile(
                leading: const IsmLiveImage.svg(
                  IsmLiveAssetConstants.cup,
                ),
                title: Text(
                  'Winner takes all',
                  style: context.textTheme.bodyMedium
                      ?.copyWith(color: Colors.green),
                ),
                subtitle: Text(
                  'This would transfer all the gifts earned by the looser to the winner',
                  style: context.textTheme.bodySmall,
                ),
              ),
            ),
            IsmLiveDimens.boxHeight32,
            Text(
              'Choose PK Challenge Duration',
              style: context.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            IsmLiveDimens.boxHeight20,
            SizedBox(
              height: IsmLiveDimens.thirty,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                itemBuilder: (context, index) {
                  var time = (index + 1 * 2).toString();
                  return GetX<IsmLivePkController>(
                      builder: (controller) => IsmLiveTapHandler(
                            onTap: () {
                              controller.pkSelectTime = time;
                            },
                            child: Container(
                              margin: IsmLiveDimens.edgeInsets10_0,
                              width: IsmLiveDimens.seventy,
                              decoration: BoxDecoration(
                                border: controller.pkSelectTime == time
                                    ? Border.all(color: Colors.red)
                                    : null,
                                borderRadius:
                                    BorderRadius.circular(IsmLiveDimens.fifty),
                              ),
                              child: Center(child: Text('$time min')),
                            ),
                          ));
                },
              ),
            ),
            IsmLiveDimens.boxHeight32,
            IsmLiveButton(
              label: 'Confirm & Start',
              small: true,
              onTap: Get.find<IsmLivePkController>().startPkBattle,
            ),
          ],
        ),
      );
}
