// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:appscrip_live_stream_component/src/res/res.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IsmLiveThemeData with Diagnosticable {
  const IsmLiveThemeData({
    this.primaryColor,
    this.secondaryColor,
    this.backgroundColor,
    this.fontFamily,
    this.textTheme,
    this.buttonTheme,
    this.cardBackgroundColor,
    this.selectedTextColor,
    this.unselectedTextColor,
  });

  factory IsmLiveThemeData.fallback() => IsmLiveThemeData(
        primaryColor: IsmLiveColors.primary,
        secondaryColor: IsmLiveColors.secondary,
        backgroundColor: IsmLiveColors.white,
        textTheme: GoogleFonts.getTextTheme('Roboto'),
        selectedTextColor: IsmLiveColors.white,
        unselectedTextColor: IsmLiveColors.grey,
        // buttonTheme:
        cardBackgroundColor: IsmLiveColors.white,
      );

  factory IsmLiveThemeData.light() => IsmLiveThemeData.fallback();

  factory IsmLiveThemeData.dark() => IsmLiveThemeData.fallback();

  final Color? primaryColor;
  final Color? secondaryColor;
  final Color? backgroundColor;
  final Color? selectedTextColor;
  final Color? unselectedTextColor;
  final String? fontFamily;
  final TextTheme? textTheme;
  final ButtonStyle? buttonTheme;
  final Color? cardBackgroundColor;

  IsmLiveThemeData copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    Color? backgroundColor,
    Color? selectedTextColor,
    Color? unselectedTextColor,
    String? fontFamily,
    TextTheme? textTheme,
    ButtonStyle? buttonTheme,
    Color? cardBackgroundColor,
  }) =>
      IsmLiveThemeData(
        primaryColor: primaryColor ?? this.primaryColor,
        secondaryColor: secondaryColor ?? this.secondaryColor,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        selectedTextColor: selectedTextColor ?? this.selectedTextColor,
        unselectedTextColor: unselectedTextColor ?? this.unselectedTextColor,
        fontFamily: fontFamily ?? this.fontFamily,
        textTheme: textTheme ?? this.textTheme,
        buttonTheme: buttonTheme ?? this.buttonTheme,
        cardBackgroundColor: cardBackgroundColor ?? this.cardBackgroundColor,
      );
}
