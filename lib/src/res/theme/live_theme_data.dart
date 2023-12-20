import 'package:appscrip_live_stream_component/src/res/res.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class IsmLiveThemeData with Diagnosticable {
  const IsmLiveThemeData({
    this.primaryColor,
    this.backgroundColor,
    this.textTheme,
    this.buttonTheme,
  });

  factory IsmLiveThemeData.fallback() => IsmLiveThemeData(
        primaryColor: IsmLiveColors.primary,
        backgroundColor: IsmLiveColors.white,
        textTheme: GoogleFonts.getTextTheme('Roboto'),
        buttonTheme: IsmLiveButtonTheme.fallback(),
      );

  factory IsmLiveThemeData.light() => IsmLiveThemeData.fallback();

  factory IsmLiveThemeData.dark() => IsmLiveThemeData.fallback();

  final Color? primaryColor;
  final Color? backgroundColor;
  final TextTheme? textTheme;
  final IsmLiveButtonTheme? buttonTheme;
}
