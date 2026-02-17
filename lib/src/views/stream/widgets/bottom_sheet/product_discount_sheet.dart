import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveProductDiscountSheet extends StatelessWidget {
  const IsmLiveProductDiscountSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = context.liveTheme?.backgroundColor ??
        (isDarkMode ? const Color(0xFF121212) : Colors.white);
    final textColor = context.liveTheme?.primaryColor ??
        (isDarkMode ? Colors.white : Colors.black);
    final iconColor = context.liveTheme?.primaryColor ??
        (isDarkMode ? Colors.white : Colors.black);
    final subtitleColor = context.liveTheme?.unselectedTextColor ??
        (isDarkMode ? const Color(0xFFB0B0B0) : Colors.grey);
    final borderColor = context.liveTheme?.borderColor ??
        (isDarkMode ? const Color(0xFF1E1E1E) : Colors.purple[100]!);

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
      padding: IsmLiveDimens.edgeInsets16_30_16_5,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                IsmLiveStrings.discountPercentage,
                style: context.textTheme.headlineSmall?.copyWith(
                  color: textColor,
                ),
              ),
              IconButton(
                onPressed: IsmLiveRoute.pop,
                icon: Icon(
                  Icons.close,
                  color: iconColor,
                ),
              ),
            ],
          ),
          IsmLiveDimens.boxHeight32,
          Text(
            IsmLiveStrings.enterDiscountPercentage,
            style: context.textTheme.bodySmall?.copyWith(
              color: subtitleColor,
            ),
          ),
          IsmLiveInputField(
            radius: IsmLiveDimens.five,
            controller: TextEditingController(),
            suffixIcon: Icon(Icons.percent, color: iconColor),
            borderColor: borderColor,
            textInputType: const TextInputType.numberWithOptions(),
          ),
          IsmLiveDimens.boxHeight32,
          IsmLiveDimens.boxHeight32,
          IsmLiveButton(label: IsmLiveStrings.add),
        ],
      ),
    );
  }
}
