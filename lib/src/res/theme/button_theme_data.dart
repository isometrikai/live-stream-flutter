import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class IsmLiveButtonThemeData with Diagnosticable {
  const IsmLiveButtonThemeData({
    this.foregroundColor,
    this.backgroundColor,
    this.disableColor,
  });

  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? disableColor;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('foregroundColor', foregroundColor));
    properties.add(ColorProperty('backgroundColor', backgroundColor));
    properties.add(ColorProperty('disableColor', disableColor));
  }

  IsmLiveButtonThemeData lerp(covariant IsmLiveButtonThemeData? other, double t) {
    if (other is! IsmLiveButtonThemeData) {
      return this;
    }
    return IsmLiveButtonThemeData(
      foregroundColor: Color.lerp(foregroundColor, other.foregroundColor, t),
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      disableColor: Color.lerp(disableColor, other.disableColor, t),
    );
  }

  IsmLiveButtonThemeData copyWith({
    Color? foregroundColor,
    Color? backgroundColor,
    Color? disableColor,
  }) =>
      IsmLiveButtonThemeData(
        foregroundColor: foregroundColor ?? this.foregroundColor,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        disableColor: disableColor ?? this.disableColor,
      );
}
