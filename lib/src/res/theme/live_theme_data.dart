import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class IsmLiveThemeData with Diagnosticable {
  const IsmLiveThemeData({
    this.primaryColor,
    this.secondaryColor,
    this.backgroundColor,
    this.streamBackgroundColor,
    this.borderColor,
    this.primaryButtonTheme,
    this.secondaryButtonTheme,
    this.buttonRadius,
    this.iconButtonRadius,
    this.cardBackgroundColor,
    this.selectedTextColor,
    this.unselectedTextColor,
  });

  final Color? primaryColor;
  final Color? secondaryColor;
  final Color? backgroundColor;
  final Color? streamBackgroundColor;
  final Color? borderColor;
  final IsmLiveButtonThemeData? primaryButtonTheme;
  final IsmLiveButtonThemeData? secondaryButtonTheme;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final BorderRadius? buttonRadius;
  final BorderRadius? iconButtonRadius;
  final Color? cardBackgroundColor;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(ColorProperty('primaryColor', primaryColor));
    properties.add(ColorProperty('secondaryColor', secondaryColor));
    properties.add(ColorProperty('backgroundColor', backgroundColor));
    properties
        .add(ColorProperty('streamBackgroundColor', streamBackgroundColor));
    properties.add(ColorProperty('borderColor', borderColor));
    properties.add(
      DiagnosticsProperty<IsmLiveButtonThemeData>(
        'secondaryButtonTheme',
        secondaryButtonTheme,
      ),
    );
    properties.add(
      DiagnosticsProperty<IsmLiveButtonThemeData>(
        'primaryButtonTheme',
        primaryButtonTheme,
      ),
    );
    properties.add(ColorProperty('selectedTextColor', selectedTextColor));
    properties.add(ColorProperty('unselectedTextColor', unselectedTextColor));
    properties
        .add(DiagnosticsProperty<BorderRadius>('buttonRadius', buttonRadius));
    properties.add(DiagnosticsProperty<BorderRadius>(
        'iconButtonRadius', iconButtonRadius));
    properties.add(ColorProperty('cardBackgroundColor', cardBackgroundColor));
  }

  IsmLiveThemeData lerp(covariant IsmLiveThemeData? other, double t) {
    if (other is! IsmLiveThemeData) {
      return this;
    }
    return IsmLiveThemeData(
      primaryColor: Color.lerp(primaryColor, other.primaryColor, t),
      secondaryColor: Color.lerp(secondaryColor, other.secondaryColor, t),
      backgroundColor: Color.lerp(backgroundColor, other.backgroundColor, t),
      streamBackgroundColor:
          Color.lerp(streamBackgroundColor, other.streamBackgroundColor, t),
      borderColor: Color.lerp(borderColor, other.borderColor, t),
      primaryButtonTheme: primaryButtonTheme?.lerp(other.primaryButtonTheme, t),
      secondaryButtonTheme:
          secondaryButtonTheme?.lerp(other.secondaryButtonTheme, t),
      selectedTextColor:
          Color.lerp(selectedTextColor, other.selectedTextColor, t),
      unselectedTextColor:
          Color.lerp(unselectedTextColor, other.unselectedTextColor, t),
      buttonRadius: BorderRadius.lerp(buttonRadius, other.buttonRadius, t),
      iconButtonRadius:
          BorderRadius.lerp(iconButtonRadius, other.iconButtonRadius, t),
      cardBackgroundColor:
          Color.lerp(cardBackgroundColor, other.cardBackgroundColor, t),
    );
  }

  IsmLiveThemeData copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    Color? streamBackgroundColor,
    Color? borderColor,
    IsmLiveButtonThemeData? primaryButtonTheme,
    IsmLiveButtonThemeData? secondaryButtonTheme,
    Color? selectedTextColor,
    Color? unselectedTextColor,
    BorderRadius? buttonRadius,
    BorderRadius? iconButtonRadius,
    Color? cardBackgroundColor,
  }) =>
      IsmLiveThemeData(
        primaryColor: primaryColor ?? this.primaryColor,
        secondaryColor: secondaryColor ?? this.secondaryColor,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        streamBackgroundColor:
            streamBackgroundColor ?? this.streamBackgroundColor,
        borderColor: borderColor ?? this.borderColor,
        primaryButtonTheme: primaryButtonTheme ?? primaryButtonTheme,
        secondaryButtonTheme: secondaryButtonTheme ?? secondaryButtonTheme,
        selectedTextColor: selectedTextColor ?? this.selectedTextColor,
        unselectedTextColor: unselectedTextColor ?? this.unselectedTextColor,
        buttonRadius: buttonRadius ?? this.buttonRadius,
        iconButtonRadius: iconButtonRadius ?? this.iconButtonRadius,
        cardBackgroundColor: cardBackgroundColor ?? this.cardBackgroundColor,
      );
}
