import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    required this.icon,
    this.radius,
    required this.onTap,
    this.color,
    this.hight,
    this.width,
  });
  final Widget icon;
  final double? radius;
  final VoidCallback onTap;
  final Color? color;
  final double? hight;
  final double? width;
  @override
  Widget build(BuildContext context) => Padding(
        padding: IsmLiveDimens.edgeInsetsB10,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: hight,
            width: width,
            decoration: BoxDecoration(
              borderRadius:
                  radius == null ? null : BorderRadius.circular(radius!),
              color: color ?? IsmLiveColors.black.withOpacity(0.4),
              shape: radius == null ? BoxShape.circle : BoxShape.rectangle,
            ),
            child: icon,
          ),
        ),
      );
}
