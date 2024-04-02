import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class IsmLiveDataExtension extends ThemeExtension<IsmLiveDataExtension> {
  IsmLiveDataExtension({
    this.theme,
    this.translations,
    this.properties,
  });

  final IsmLiveThemeData? theme;
  final IsmLiveTranslationsData? translations;
  final IsmLivePropertiesData? properties;

  @override
  ThemeExtension<IsmLiveDataExtension> copyWith({
    IsmLiveThemeData? theme,
    IsmLiveTranslationsData? translations,
    IsmLivePropertiesData? properties,
  }) =>
      IsmLiveDataExtension(
        theme: theme ?? this.theme,
        properties: properties ?? this.properties,
        translations: translations ?? this.translations,
      );

  @override
  ThemeExtension<IsmLiveDataExtension> lerp(covariant ThemeExtension<IsmLiveDataExtension>? other, double t) {
    if (other is! IsmLiveDataExtension) {
      return this;
    }
    return IsmLiveDataExtension(
      theme: theme?.lerp(other.theme, t),
      translations: other.translations ?? translations,
      properties: other.properties ?? properties,
    );
  }
}
