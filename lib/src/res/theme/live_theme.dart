import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class IsmLiveTheme extends StatelessWidget {
  const IsmLiveTheme({
    super.key,
    this.data,
    this.lightTheme,
    this.darkTheme,
    this.themeMode,
    required this.child,
  }) : assert(
          data != null || (lightTheme != null && darkTheme != null),
          'Either data or both lightTheme and darkTheme must be provided',
        );

  /// Single theme data for backward compatibility.
  /// If provided, it will be used for both light and dark modes.
  /// If both [lightTheme] and [darkTheme] are provided, this parameter is ignored.
  final IsmLiveThemeData? data;

  /// Theme data for light mode.
  final IsmLiveThemeData? lightTheme;

  /// Theme data for dark mode.
  final IsmLiveThemeData? darkTheme;

  /// Theme mode to use. If null, follows system theme.
  /// Defaults to [ThemeMode.system] to automatically follow system brightness.
  final ThemeMode? themeMode;

  final Widget child;

  /// Gets the current theme data based on brightness
  IsmLiveThemeData _getThemeData(BuildContext context) {
    // If only data is provided (backward compatibility), use it
    if (data != null && lightTheme == null && darkTheme == null) {
      return data!;
    }

    // Determine which theme to use based on themeMode and brightness
    final effectiveThemeMode = themeMode ?? ThemeMode.system;
    final isDark = _isDarkMode(context, effectiveThemeMode);

    return isDark ? (darkTheme ?? data!) : (lightTheme ?? data!);
  }

  /// Determines if dark mode should be used based on themeMode and system brightness
  bool _isDarkMode(BuildContext context, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        // Try to get brightness from Material Theme first
        try {
          final materialTheme = Theme.of(context);
          return materialTheme.brightness == Brightness.dark;
        } catch (_) {
          // Fallback to MediaQuery platform brightness if Theme not available
          return MediaQuery.of(context).platformBrightness == Brightness.dark;
        }
    }
  }

  static IsmLiveThemeData? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_InheritedLiveTheme>()
      ?.theme
      ._getThemeData(context);

  static IsmLiveThemeData of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, 'No IsmLiveThemeData found in the context');
    return result!;
  }

  @override
  Widget build(BuildContext context) => Builder(
        // Use a Builder to ensure we get the current context for brightness detection
        builder: (context) => _InheritedLiveTheme(
          theme: this,
          currentContext: context,
          child: child,
        ),
      );
}

class _InheritedLiveTheme extends InheritedTheme {
  const _InheritedLiveTheme({
    required this.theme,
    required this.currentContext,
    required super.child,
  });

  final IsmLiveTheme theme;
  final BuildContext currentContext;

  IsmLiveThemeData get data => theme._getThemeData(currentContext);

  @override
  bool updateShouldNotify(covariant _InheritedLiveTheme oldWidget) {
    // Check if theme data changed or brightness changed
    final oldData = oldWidget.data;
    final newData = data;
    
    // Also check if brightness changed (for system theme mode)
    if (theme.themeMode == null || theme.themeMode == ThemeMode.system) {
      final oldBrightness = oldWidget._getBrightness();
      final newBrightness = _getBrightness();
      if (oldBrightness != newBrightness) {
        return true;
      }
    }
    
    return oldData != newData;
  }

  Brightness _getBrightness() {
    try {
      final materialTheme = Theme.of(currentContext);
      return materialTheme.brightness;
    } catch (_) {
      // Fallback to MediaQuery platform brightness if Theme not available
      return MediaQuery.of(currentContext).platformBrightness;
    }
  }

  @override
  Widget wrap(BuildContext context, Widget child) => IsmLiveTheme(
        // Preserve all theme parameters when wrapping
        data: theme.data,
        lightTheme: theme.lightTheme,
        darkTheme: theme.darkTheme,
        themeMode: theme.themeMode,
        child: child,
      );
}
