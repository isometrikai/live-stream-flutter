import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class IsmLiveThemeData with Diagnosticable {
  const IsmLiveThemeData({
    this.primaryColor,
    this.secondaryColor,
    this.backgroundColor,
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
    properties.add(DiagnosticsProperty<BorderRadius>('buttonRadius', buttonRadius));
    properties.add(DiagnosticsProperty<BorderRadius>('iconButtonRadius', iconButtonRadius));
    properties.add(ColorProperty('cardBackgroundColor', cardBackgroundColor));
  }

  IsmLiveThemeData copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
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
        primaryButtonTheme: primaryButtonTheme ?? primaryButtonTheme,
        secondaryButtonTheme: secondaryButtonTheme ?? secondaryButtonTheme,
        selectedTextColor: selectedTextColor ?? this.selectedTextColor,
        unselectedTextColor: unselectedTextColor ?? this.unselectedTextColor,
        buttonRadius: buttonRadius ?? this.buttonRadius,
        iconButtonRadius: iconButtonRadius ?? this.iconButtonRadius,
        cardBackgroundColor: cardBackgroundColor ?? this.cardBackgroundColor,
      );
}
