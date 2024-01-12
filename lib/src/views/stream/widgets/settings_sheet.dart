import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveSettings extends StatelessWidget {
  const IsmLiveSettings({
    super.key,
  });

  @override
  Widget build(BuildContext context) => Padding(
        padding: IsmLiveDimens.edgeInsets16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: IsmLiveDimens.edgeInsets0,
              leading: Text(
                'Settings',
                style: context.textTheme.bodyLarge!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              trailing: CustomIconButton(
                icon: Icon(
                  Icons.cancel,
                  color: IsmLiveColors.grey,
                  size: IsmLiveDimens.twenty,
                ),
                color: Colors.transparent,
                onTap: Get.back,
              ),
            ),
            IsmLiveDimens.boxHeight20,
            Expanded(
              child: GetBuilder<IsmLiveStreamController>(
                  builder: (controller) => ListView.separated(
                        shrinkWrap: true,
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
                        itemCount: IsmLiveHostSettings.values.length,
                      )),
            ),
          ],
        ),
      );
}
