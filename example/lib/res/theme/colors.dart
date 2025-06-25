import 'package:flutter/material.dart';

class ColorsValue {
  const ColorsValue._();

  static const Color primary = Colors.black;

  static const Color white = Colors.white;

  // Gradient Colors
  static const Color gradientStart = Color(0xFFDB354D);
  static const Color gradientEnd = Color(0xFF4F1299);

  // Button Gradient
  static const LinearGradient buttonTopBottomGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      gradientStart,
      gradientEnd,
    ],
  );

  static LinearGradient disableButtonTopBottomGradient = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      gradientStart.withAlpha(127),
      gradientEnd.withAlpha(127),
    ],
  );
}
