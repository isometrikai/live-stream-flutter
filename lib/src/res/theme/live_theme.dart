import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/widgets.dart';

class IsmLiveTheme extends StatelessWidget {
  const IsmLiveTheme({
    super.key,
    required this.data,
    required this.child,
  });

  final IsmLiveThemeData data;
  final Widget child;

  static IsmLiveThemeData? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_InheritedLiveTheme>()
      ?.theme
      .data;

  static IsmLiveThemeData of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, 'No IsmLiveThemeData found in the context');
    return result!;
  }

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
  bool updateShouldNotify(covariant _InheritedLiveTheme oldWidget) =>
      oldWidget.theme.data != theme.data;

  @override
  Widget wrap(BuildContext context, Widget child) => IsmLiveTheme(
        data: theme.data,
        child: child,
      );
}
