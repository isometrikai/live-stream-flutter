import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveEmptyScreen extends StatelessWidget {
  const IsmLiveEmptyScreen({
    super.key,
    required this.label,
    required this.placeHolder,
  });

  final String label;
  final String placeHolder;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final iconColor = context.liveTheme?.primaryColor ??
        (isDarkMode ? Colors.white : IsmLiveColors.primary);
    final textColor = context.liveTheme?.unselectedTextColor ??
        (isDarkMode ? const Color(0xFFB0B0B0) : IsmLiveColors.grey);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IsmLiveImage.svg(
            placeHolder,
            color: iconColor,
          ),
          IsmLiveDimens.boxHeight16,
          Text(
            label,
            style: context.textTheme.titleMedium?.copyWith(
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
