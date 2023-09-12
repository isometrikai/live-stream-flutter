import 'package:flutter/material.dart';

class IsmLiveAnimatedText extends StatelessWidget {
  final String label;
  final TextStyle? style;

  const IsmLiveAnimatedText(
    this.label, {
    super.key,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return RichText(
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
}
