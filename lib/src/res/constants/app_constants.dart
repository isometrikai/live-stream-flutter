import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';

/// `AppConstants` is a singleton class with all static variables.
///
/// It contains all constants that are to be used within the project
///
/// If need to check the translated strings that are used in UI (Views) of the app, check TranslationKeys
class IsmLiveConstants {
  const IsmLiveConstants._();

  static const String name = 'Appscrip Live Stream';

  static const Duration timeOutDuration = Duration(seconds: 60);

  static double imageHeight = IsmLiveDimens.twentyFive;
}
