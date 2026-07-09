import 'package:appscrip_live_stream_component/src/models/translations/translations.dart';
import 'package:appscrip_live_stream_component/src/res/localization/ism_live_strings_en.dart';
import 'package:appscrip_live_stream_component/src/res/localization/ism_live_strings_fr.dart';
import 'package:appscrip_live_stream_component/src/res/localization/ism_live_strings_pt.dart';
import 'package:appscrip_live_stream_component/src/res/translations/live_translations_data.dart';
import 'package:flutter/material.dart';

/// Supported locales for the live stream component.
class IsmLiveSupportedLocales {
  const IsmLiveSupportedLocales._();

  static const Locale english = Locale('en');
  static const Locale french = Locale('fr');
  static const Locale portuguese = Locale('pt');

  static const List<Locale> all = [
    english,
    french,
    portuguese,
  ];

  static bool isSupported(Locale locale) => all.any(
        (supported) =>
            supported.languageCode == locale.languageCode &&
            (supported.countryCode == null ||
                supported.countryCode == locale.countryCode),
      );

  /// Resolves [locale] to the closest supported locale, defaulting to English.
  static Locale resolve(Locale? locale) {
    if (locale == null) return english;
    for (final supported in all) {
      if (supported.languageCode == locale.languageCode) {
        return supported;
      }
    }
    return english;
  }
}

/// Localization state for the live stream component.
class IsmLiveLocalization {
  IsmLiveLocalization._(this.locale, this._strings, this._overrides);

  final Locale locale;
  final Map<String, String> _strings;
  final Map<String, String> _overrides;

  static IsmLiveLocalization _current =
      IsmLiveLocalization._(IsmLiveSupportedLocales.english, ismLiveStringsEn, {});

  /// Active localization used when no [BuildContext] is available.
  static IsmLiveLocalization get current => _current;

  static set current(IsmLiveLocalization value) => _current = value;

  /// Returns the localized string for [key], falling back to English.
  String translate(String key) =>
      _overrides[key] ?? _strings[key] ?? ismLiveStringsEn[key] ?? key;

  /// Builds localization for [locale], optionally applying legacy overrides.
  factory IsmLiveLocalization.forLocale(
    Locale locale, {
    IsmLiveTranslationsData? overrides,
  }) {
    final resolved = IsmLiveSupportedLocales.resolve(locale);
    final strings = _stringsForLocale(resolved);
    return IsmLiveLocalization._(
      resolved,
      strings,
      _overridesFromTranslationsData(overrides),
    );
  }

  static Map<String, String> _stringsForLocale(Locale locale) {
    switch (locale.languageCode) {
      case 'fr':
        return ismLiveStringsFr;
      case 'pt':
        return ismLiveStringsPt;
      case 'en':
      default:
        return ismLiveStringsEn;
    }
  }

  static Map<String, String> _overridesFromTranslationsData(
    IsmLiveTranslationsData? overrides,
  ) {
    if (overrides == null) return const {};

    final map = <String, String>{};
    void add(String key, String? value) {
      if (value != null && value.isNotEmpty) {
        map[key] = value;
      }
    }

    add('uploadingImage', overrides.uploadingImage);
    add('kickoutMessage', overrides.kickoutMessage);
    add('addedModerator', overrides.addedModerator);
    add('streamEnded', overrides.streamEnded);
    add('attention', overrides.attention);
    add('requestCopublishingTitle', overrides.requestCopublishingTitle);
    add(
      'requestCopublishingDescription',
      overrides.requestCopublishingDescription,
    );
    add(
      'hostAcceptedCopublishRequestTitle',
      overrides.hostAcceptedCopublishRequestTitle,
    );
    add(
      'hostAcceptedCopublishRequestDescription',
      overrides.hostAcceptedCopublishRequestDescription,
    );

    final stream = overrides.streamTranslations;
    if (stream != null) {
      add('youreLive', stream.youreLive);
      add('moderationWarning', stream.moderationWarning);
      add('preparingYourStream', stream.preparingYourStream);
      add('reconnecting', stream.reconnecting);
      add('joiningLiveStream', stream.joiningLiveStream);
      add('connectingToLiveStream', stream.connectingToLiveStream);
      add('enablingYourVideo', stream.enablingYourVideo);
      add('pkMessage', stream.pkMessage);
    }

    return map;
  }
}

/// Provides [IsmLiveLocalization] to the widget tree.
class IsmLiveLocalizationScope extends InheritedWidget {
  const IsmLiveLocalizationScope({
    super.key,
    required this.localization,
    required super.child,
  });

  final IsmLiveLocalization localization;

  static IsmLiveLocalization of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<IsmLiveLocalizationScope>();
    return scope?.localization ?? IsmLiveLocalization.current;
  }

  static IsmLiveLocalization? maybeOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<IsmLiveLocalizationScope>()
          ?.localization;

  @override
  bool updateShouldNotify(covariant IsmLiveLocalizationScope oldWidget) =>
      oldWidget.localization.locale != localization.locale ||
      oldWidget.localization._overrides != localization._overrides;
}
