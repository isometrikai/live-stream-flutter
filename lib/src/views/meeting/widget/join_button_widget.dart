import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class JionButtonWidget extends StatelessWidget {
  const JionButtonWidget(
      {super.key, this.color, required this.title, this.onTap});
  final Color? color;
  final String title;
  final void Function()? onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: IsmLiveDimens.edgeInsets8_4,
          color: color ?? Colors.green,
          child: Text(title),
        ),
      );
}
