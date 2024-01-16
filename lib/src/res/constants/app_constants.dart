import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';

/// `AppConstants` is a singleton class with all static variables.
///
/// It contains all constants that are to be used within the project
///
/// If need to check the translated strings that are used in UI (Views) of the app, check TranslationKeys
class IsmLiveConstants {
  const IsmLiveConstants._();

  static const String name = 'IsmLive';

  static const String packageName = 'appscrip_live_stream_component';

  static const Duration animationDuration = Duration(milliseconds: 300);

  static const Duration timeOutDuration = Duration(seconds: 60);

  static double imageHeight = IsmLiveDimens.twentyFive;

  static const int keepAlivePeriod = 60;

  static const int counterTime = 3;
  static const int animationTime = 7;
  static const int giftTime = 3;
}
