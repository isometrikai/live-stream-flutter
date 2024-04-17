import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    required this.icon,
    this.radius,
    this.onTap,
    this.color,
    this.dimension,
  });
  final Widget icon;
  final double? radius;
  final VoidCallback? onTap;
  final Color? color;
  final double? dimension;

  @override
  Widget build(BuildContext context) => IsmLiveTapHandler(
        onTap: onTap,
        child: Container(
          height: dimension,
          width: dimension,
          decoration: BoxDecoration(
            borderRadius: radius == null ? null : BorderRadius.circular(radius!),
            color: color ?? Colors.black12,
            shape: radius == null ? BoxShape.circle : BoxShape.rectangle,
          ),
          child: UnconstrainedBox(child: icon),
        ),
      );
}
