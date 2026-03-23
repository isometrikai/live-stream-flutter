part of 'live_app.dart';

const _kThemeData = IsmLiveThemeData(
  primaryColor: IsmLiveColors.black,
  secondaryColor: IsmLiveColors.secondary,
  backgroundColor: IsmLiveColors.white,
  borderColor: IsmLiveColors.border,
  selectedTextColor: IsmLiveColors.white,
  unselectedTextColor: IsmLiveColors.grey,
  cardBackgroundColor: IsmLiveColors.white,
  primaryButtonTheme: IsmLiveButtonThemeData(
    backgroundColor: IsmLiveColors.black,
    foregroundColor: IsmLiveColors.white,
    disableColor: IsmLiveColors.grey,
  ),
  secondaryButtonTheme: IsmLiveButtonThemeData(
    backgroundColor: IsmLiveColors.white,
    foregroundColor: IsmLiveColors.black,
    disableColor: IsmLiveColors.grey,
  ),
  fontFamily: null, // Will be set dynamically from delegate
);

const _kDarkThemeData = IsmLiveThemeData(
  primaryColor: IsmLiveColors.white,
  secondaryColor: IsmLiveColors.secondary,
  backgroundColor: Color(0xFF121212), // Material dark background
  borderColor: Color(0xFF1E1E1E), // Dark border
  selectedTextColor: IsmLiveColors.white,
  unselectedTextColor: Color(0xFFB0B0B0), // Light grey for dark theme
  cardBackgroundColor: Color(0xFF1E1E1E), // Dark card background
  primaryButtonTheme: IsmLiveButtonThemeData(
    backgroundColor: IsmLiveColors.white,
    foregroundColor: IsmLiveColors.black,
    disableColor: Color(0xFF424242), // Dark grey for disabled state
  ),
  secondaryButtonTheme: IsmLiveButtonThemeData(
    backgroundColor: Color(0xFF2C2C2C), // Dark secondary button
    foregroundColor: IsmLiveColors.white,
    disableColor: Color(0xFF424242),
  ),
  fontFamily: null, // Will be set dynamically from delegate
);

const _kTranslationsData = IsmLiveTranslationsData(
  uploadingImage: IsmLiveStrings.uploadingImage,
  streamTranslations: IsmLiveStreamTranslations(
    youreLive: IsmLiveStrings.youreLive,
    moderationWarning: IsmLiveStrings.moderationWarning,
    connectingToLiveStream: IsmLiveStrings.connectingToLiveStream,
  ),
);

const _kPropertiesData = IsmLivePropertiesData(
  streamProperties: IsmLiveStreamProperties(
    counterProperties: IsmLiveCounterProperties(
      showYoureLiveSheet: true,
      showYoureLiveText: false,
    ),
  ),
);

class IsmLiveData extends StatelessWidget {
  const IsmLiveData({
    super.key,
    this.theme,
    this.lightTheme,
    this.darkTheme,
    this.themeMode,
    this.translations,
    this.properties,
    this.configurations,
    required this.child,
  });

  /// Single theme parameter for backward compatibility.
  /// If provided, it will be used for both light and dark modes.
  /// If both [lightTheme] and [darkTheme] are provided, this parameter is ignored.
  final IsmLiveThemeData? theme;

  /// Theme data for light mode.
  /// If not provided, defaults to [_kThemeData] or [theme] if provided.
  final IsmLiveThemeData? lightTheme;

  /// Theme data for dark mode.
  /// If not provided, defaults to [_kDarkThemeData] or [theme] if provided.
  final IsmLiveThemeData? darkTheme;

  /// Theme mode to use. If null, follows system theme.
  /// Defaults to [ThemeMode.system] to automatically follow system brightness.
  final ThemeMode? themeMode;

  final IsmLiveTranslationsData? translations;
  final IsmLivePropertiesData? properties;
  final IsmLiveConfigData? configurations;
  final Widget child;

  /// Gets the theme data with dynamic font family from delegate
  IsmLiveThemeData _getDynamicThemeData(IsmLiveThemeData baseTheme) {
    final delegateFontFamily = IsmLiveDelegate.fontFamily;

    if (delegateFontFamily != null &&
        baseTheme.fontFamily != delegateFontFamily) {
      return baseTheme.copyWith(fontFamily: delegateFontFamily);
    }

    return baseTheme;
  }

  @override
  Widget build(BuildContext context) {
    // Try to get theme from Material Theme extension (if available)
    // Material Theme extension provides the theme for the current brightness
    final materialExtension = Theme.of(context).extension<IsmLiveDataExtension>();
    final currentBrightness = Theme.of(context).brightness;
    final materialTheme = materialExtension?.theme;

    // Determine which themes to use
    // Priority: explicit parameters > Material Theme extension (for current mode) > theme parameter > defaults
    final effectiveLightTheme = lightTheme ??
        (materialTheme != null && currentBrightness == Brightness.light
            ? materialTheme
            : null) ??
        theme ??
        _kThemeData;

    final effectiveDarkTheme = darkTheme ??
        (materialTheme != null && currentBrightness == Brightness.dark
            ? materialTheme
            : null) ??
        theme ??
        _kDarkThemeData;

    return IsmLiveTheme(
      lightTheme: _getDynamicThemeData(effectiveLightTheme),
      darkTheme: _getDynamicThemeData(effectiveDarkTheme),
      themeMode: themeMode ?? ThemeMode.system,
      child: IsmLiveTranslations(
        data: translations ?? materialExtension?.translations ?? _kTranslationsData,
        child: IsmLiveProperties(
          data: properties ?? materialExtension?.properties ?? _kPropertiesData,
          child: configurations != null
              ? IsmLiveConfig(
                  data: configurations!,
                  child: child,
                )
              : child,
        ),
      ),
    );
  }
}
