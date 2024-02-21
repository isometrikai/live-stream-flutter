import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveCustomButtomSheet extends StatelessWidget {
  const IsmLiveCustomButtomSheet({
    super.key,
    required this.title,
    this.onLeft,
    required this.leftLabel,
    required this.rightLabel,
    this.onRight,
  });
  final String title;
  final String leftLabel;
  final String rightLabel;
  final VoidCallback? onLeft;
  final VoidCallback? onRight;
  @override
  Widget build(BuildContext context) => Padding(
        padding: IsmLiveDimens.edgeInsets16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IsmLiveDimens.boxHeight10,
            Text(
              title,
              style: context.textTheme.titleLarge,
            ),
            IsmLiveDimens.boxHeight20,
            Row(
              children: [
                Expanded(
                  child: IsmLiveButton.secondary(
                    label: leftLabel,
                    onTap: onLeft,
                  ),
                ),
                IsmLiveDimens.boxWidth16,
                Expanded(
                  child: IsmLiveButton(
                    label: rightLabel,
                    onTap: onRight,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}
