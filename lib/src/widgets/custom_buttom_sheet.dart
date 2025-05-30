import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/widgets/custom_button.dart';
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
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 10),
              child: Text(
                title,
                style: context.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ),
            IsmLiveDimens.boxHeight20,
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    onlyBorder: true,
                    onPress: onLeft,
                    title: leftLabel,
                  ),
                ),
                IsmLiveDimens.boxWidth16,
                Expanded(
                  child: CustomButton(
                    onPress: onRight,
                    title: rightLabel,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
}
