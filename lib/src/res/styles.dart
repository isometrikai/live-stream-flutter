import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class IsmLiveStyles {
  const IsmLiveStyles._();

  /// Helper method to apply font family to existing styles
  static TextStyle _applyFontFamily(TextStyle baseStyle) {
    final fontFamily = IsmLiveDelegate.fontFamily;
    return fontFamily != null
        ? baseStyle.copyWith(fontFamily: fontFamily)
        : baseStyle;
  }

  static TextStyle get black16 => _applyFontFamily(TextStyle(
        color: Colors.black,
        fontSize: IsmLiveDimens.sixteen,
      ));

  static TextStyle get lightGrey14 => _applyFontFamily(TextStyle(
        color: Colors.grey[400],
        fontSize: IsmLiveDimens.fourteen,
      ));

  static TextStyle get white16 => _applyFontFamily(TextStyle(
        color: Colors.white,
        fontSize: IsmLiveDimens.sixteen,
      ));

  static TextStyle get white10 => _applyFontFamily(TextStyle(
        color: Colors.white,
        fontSize: IsmLiveDimens.ten,
      ));

  static TextStyle get white12 => _applyFontFamily(TextStyle(
        color: Colors.white,
        fontSize: IsmLiveDimens.twelve,
      ));

  static TextStyle get whiteBold16 => _applyFontFamily(TextStyle(
        color: Colors.white,
        fontSize: IsmLiveDimens.sixteen,
        fontWeight: FontWeight.bold,
      ));

  static TextStyle get whiteBold25 => _applyFontFamily(TextStyle(
        color: Colors.white,
        fontSize: IsmLiveDimens.twentyFive,
        fontWeight: FontWeight.bold,
      ));

  static TextStyle get blackBold16 => _applyFontFamily(TextStyle(
        fontSize: IsmLiveDimens.sixteen,
        fontWeight: FontWeight.bold,
      ));

  static TextStyle get blackBold20 => _applyFontFamily(TextStyle(
        fontSize: IsmLiveDimens.twenty,
        fontWeight: FontWeight.bold,
      ));

  static TextStyle get whiteBold15 => _applyFontFamily(TextStyle(
        color: IsmLiveColors.white,
        fontWeight: FontWeight.bold,
        fontSize: IsmLiveDimens.fifteen,
      ));
}
