part of 'live_app.dart';

const _kThemeData = IsmLiveThemeData(
  primaryColor: IsmLiveColors.primary,
  secondaryColor: IsmLiveColors.secondary,
  backgroundColor: IsmLiveColors.white,
  selectedTextColor: IsmLiveColors.white,
  unselectedTextColor: IsmLiveColors.grey,
  cardBackgroundColor: IsmLiveColors.white,
);

const _kTranslationsData = IsmLiveTranslationsData(
  streamTranslations: IsmLiveStreamTranslations(
    youreLive: IsmLiveStrings.youreLive,
    moderationWarning: IsmLiveStrings.moderationWarning,
  ),
);

class IsmLiveSetup extends StatelessWidget {
  const IsmLiveSetup({
    super.key,
    this.theme,
    this.translations,
    required this.child,
  });

  final IsmLiveThemeData? theme;
  final IsmLiveTranslationsData? translations;
  final Widget child;

  @override
  Widget build(BuildContext context) => IsmLiveTheme(
        data: theme ?? _kThemeData,
        child: IsmLiveTranslations(
          data: translations ?? _kTranslationsData,
          child: child,
        ),
      );
}
