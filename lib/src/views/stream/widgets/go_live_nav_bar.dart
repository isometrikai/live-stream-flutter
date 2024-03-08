import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmGoLiveNavBar extends StatelessWidget {
  const IsmGoLiveNavBar({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
        child: GetBuilder<IsmLiveStreamController>(
          id: IsmGoLiveView.updateId,
          builder: (controller) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: IsmLiveDimens.edgeInsets16_0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: IsmLiveColors.red,
                    borderRadius: BorderRadius.circular(IsmLiveDimens.twentyFive),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: IsmLiveDimens.edgeInsets4,
                        child: Text(
                          'Broadcasters under 18 are not permitted',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IsmLiveButton(
                        label: 'Go Live',
                        showBorder: true,
                        onTap: controller.startStream,
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: IsmGoLiveTabItem.values.map((e) {
                  final isSelected = controller.selectedGoLiveTabItem == e;
                  return Expanded(
                    child: IsmLiveTapHandler(
                      onTap: () {
                        controller.selectedGoLiveTabItem = e;
                        controller.onChangePersistent(false);
                        controller.update([IsmGoLiveView.updateId]);
                      },
                      child: Padding(
                        padding: IsmLiveDimens.edgeInsets0_4,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              e.label,
                              style: context.textTheme.labelLarge?.copyWith(
                                color: isSelected ? context.liveTheme.selectedTextColor : context.liveTheme.unselectedTextColor,
                              ),
                            ),
                            if (isSelected) ...[
                              IsmLiveDimens.boxHeight4,
                              Container(
                                height: 2,
                                width: Get.width * 0.25,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
}
