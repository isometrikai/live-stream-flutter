import 'package:appscrip_live_stream_component/src/res/res.dart';
import 'package:flutter/widgets.dart';

class IsmLiveTheme extends StatelessWidget {
  const IsmLiveTheme({
    super.key,
    required this.data,
    required this.child,
  });

  final IsmLiveThemeData data;
  final Widget child;

  static final IsmLiveThemeData _kFallbackTheme = IsmLiveThemeData.fallback();

  static IsmLiveThemeData of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_InheritedLiveTheme>()?.theme.data ?? _kFallbackTheme;

  @override
  Widget build(BuildContext context) => _InheritedLiveTheme(
        theme: this,
        child: child,
      );
}

class _InheritedLiveTheme extends InheritedTheme {
  const _InheritedLiveTheme({
    required this.theme,
    required super.child,
  });

  final IsmLiveTheme theme;

  @override
  bool updateShouldNotify(covariant _InheritedLiveTheme oldWidget) => oldWidget.theme.data != theme.data;

  @override
  Widget wrap(BuildContext context, Widget child) => IsmLiveTheme(
        data: theme.data,
        child: child,
      );
}
