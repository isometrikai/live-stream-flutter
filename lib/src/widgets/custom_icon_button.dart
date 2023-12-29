import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    required this.icon,
    this.radius,
    required this.onTap,
    this.color,
  });
  final Widget icon;
  final double? radius;
  final VoidCallback onTap;
  final Color? color;
  @override
  Widget build(BuildContext context) => Padding(
        padding: IsmLiveDimens.edgeInsetsB10,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: IsmLiveDimens.fortyFive,
            width: IsmLiveDimens.fortyFive,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius ?? IsmLiveDimens.five),
              color: color ?? IsmLiveColors.black.withOpacity(0.4),
            ),
            child: icon,
          ),
        ),
      );
}
