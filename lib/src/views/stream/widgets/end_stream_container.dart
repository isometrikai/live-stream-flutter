import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveEndStreamContainer extends StatelessWidget {
  const IsmLiveEndStreamContainer({
    super.key,
    required this.title,
    required this.points,
    required this.assetConstant,
    this.color,
    this.fromPackage = true,
  });

  final String title;
  final String points;
  final String assetConstant;
  final Color? color;

  /// Whether [assetConstant] is loaded from this package. Host overrides
  /// typically pass `false`.
  final bool fromPackage;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final iconColor = color ??
        (isDarkMode ? Colors.white : Colors.black);
    final titleColor = context.liveTheme?.unselectedTextColor ??
        (isDarkMode ? const Color(0xFFB0B0B0) : Colors.grey);
    final pointsColor = isDarkMode ? Colors.white : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IsmLiveImage.svg(
          assetConstant,
          color: iconColor,
          fromPackage: fromPackage,
        ),
        Text(
          title,
          style: context.textTheme.bodyMedium?.copyWith(
            color: titleColor,
          ),
        ),
        Text(
          points,
          style: context.textTheme.titleMedium?.copyWith(
            color: pointsColor,
          ),
        ),
      ],
    );
  }
}
