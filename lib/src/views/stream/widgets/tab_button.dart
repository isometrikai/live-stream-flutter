import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveTabButton extends StatelessWidget {
  const IsmLiveTabButton(
    this.type, {
    super.key,
  });

  final IsmLiveStreamType type;

  @override
  Widget build(BuildContext context) => GetX<IsmLiveStreamController>(
        builder: (controller) {
          var isSelected = type == controller.streamType;
          return DecoratedBox(
            decoration: BoxDecoration(
              color: isSelected
                  ? context.liveTheme?.primaryColor
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(IsmLiveDimens.eighty),
            ),
            child: Padding(
              padding: IsmLiveDimens.edgeInsets16_10,
              child: Text(
                type.label,
                style: context.textTheme.titleSmall?.copyWith(
                  color: isSelected
                      ? context.liveTheme?.selectedTextColor
                      : context.liveTheme?.unselectedTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      );
}
