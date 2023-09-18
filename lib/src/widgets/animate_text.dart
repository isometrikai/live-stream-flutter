import 'package:flutter/material.dart';

class IsmLiveAnimatedText extends StatelessWidget {
  const IsmLiveAnimatedText(
    this.label, {
    super.key,
    this.style,
  });
  final String label;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: label,
              style: style ??
                  const TextStyle(
                    color: Colors.black,
                  ),
            ),
          ],
        ),
      );
}
