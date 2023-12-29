import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class IsmLiveTranslations extends StatelessWidget {
  const IsmLiveTranslations({
    super.key,
    required this.data,
    required this.child,
  });

  static IsmLiveTranslationsData? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_InheritedLiveranslations>()?.translations.data;

  static IsmLiveTranslationsData of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, 'No IsmLiveTranslations found in the context');
    return result!;
  }

  final IsmLiveTranslationsData data;
  final Widget child;

  @override
  Widget build(BuildContext context) => _InheritedLiveranslations(
        translations: this,
        child: child,
      );
}

class _InheritedLiveranslations extends InheritedTheme {
  const _InheritedLiveranslations({
    required this.translations,
    required super.child,
  });

  final IsmLiveTranslations translations;

  @override
  bool updateShouldNotify(covariant _InheritedLiveranslations oldWidget) => oldWidget.translations.data != translations.data;

  @override
  Widget wrap(BuildContext context, Widget child) => IsmLiveTranslations(
        data: translations.data,
        child: child,
      );
}
