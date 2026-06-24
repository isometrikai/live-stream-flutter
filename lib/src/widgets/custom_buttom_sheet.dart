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
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = context.liveTheme?.backgroundColor ??
        (isDarkMode ? const Color(0xFF121212) : Colors.white);
    final titleColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            IsmLiveDelegate.bottomSheetBorderRadius?.topLeft.x ??
                IsmLiveDimens.thirty,
          ),
        ),
      ),
      child: Padding(
        padding: IsmLiveDimens.edgeInsets16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IsmLiveDimens.boxHeight10,
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Text(
                title,
                style: context.textTheme.titleMedium?.copyWith(
                  color: titleColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            IsmLiveDimens.boxHeight20,
            Row(
              children: [
                Expanded(
                  child: IsmLiveButton.secondary(
                    onTap: onLeft,
                    label: leftLabel,
                  ),
                ),
                IsmLiveDimens.boxWidth16,
                Expanded(
                  child: IsmLiveButton(
                    onTap: onRight,
                    label: rightLabel,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: ismLiveBottomSheetActionBottomInset(context, designBottom: 20),
            ),
          ],
        ),
      ),
    );
  }
}
