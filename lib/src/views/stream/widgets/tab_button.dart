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
          var theme = IsmLiveTheme.of(context);
          return DecoratedBox(
            decoration: BoxDecoration(
              color: isSelected ? theme.primaryColor : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(IsmLiveDimens.eighty),
            ),
            child: Padding(
              padding: IsmLiveDimens.edgeInsets16_10,
              child: Text(
                type.label,
                style: IsmLiveStyles.white16.copyWith(
                  color: isSelected ? null : theme.unselectedTextColor,
                ),
              ),
            ),
          );
        },
      );
}
