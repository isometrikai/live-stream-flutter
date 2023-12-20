import 'package:flutter/widgets.dart';

class IsmLiveButtonTheme {
  const IsmLiveButtonTheme({
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
    this.borderRadius,
  });

  factory IsmLiveButtonTheme.light() => const IsmLiveButtonTheme();

  factory IsmLiveButtonTheme.dark() => const IsmLiveButtonTheme();

  factory IsmLiveButtonTheme.fallback() => const IsmLiveButtonTheme();

  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextStyle? textStyle;
  final BorderRadius? borderRadius;
}
