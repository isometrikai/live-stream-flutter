part of 'live_app.dart';

const _kThemeData = IsmLiveThemeData(
  primaryColor: IsmLiveColors.black,
  secondaryColor: IsmLiveColors.secondary,
  backgroundColor: IsmLiveColors.white,
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
);

const _kTranslationsData = IsmLiveTranslationsData(
  uploadingImage: IsmLiveStrings.uploadingImage,
  streamTranslations: IsmLiveStreamTranslations(
    youreLive: IsmLiveStrings.youreLive,
    moderationWarning: IsmLiveStrings.moderationWarning,
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
    this.translations,
    this.properties,
    this.configurations,
    required this.child,
  });

  final IsmLiveThemeData? theme;
  final IsmLiveTranslationsData? translations;
  final IsmLivePropertiesData? properties;
  final IsmLiveConfigData? configurations;
  final Widget child;

  @override
  Widget build(BuildContext context) => IsmLiveTheme(
        data: theme ?? _kThemeData,
        child: IsmLiveTranslations(
          data: translations ?? _kTranslationsData,
          child: IsmLiveProperties(
            data: properties ?? _kPropertiesData,
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
