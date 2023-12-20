import 'package:appscrip_live_stream_component_example/utils/utils.dart';

/// `AppConstants` is a singleton class with all static variables.
///
/// It contains all constants that are to be used within the project
///
/// If need to check the translated strings that are used in UI (Views) of the app, check [TranslationKeys]
class AppConstants {
  const AppConstants._();

  static const String appName = 'Appscrip Live Stream Example';

  static const Duration timeOutDuration = Duration(seconds: 60);

  static const String licenseKey = 'lic-IMKDU24b/rXNdtyHLbW2Wz2MJdEhU76pidJ';
  static const String keySetId = '14514e5f-c0aa-4acc-8c54-aadf12057975';
  static const String projectId = '0b5facf4-cff7-4b7a-a386-ee3945f895f0';
  static const String accountId = '5eb3db9ba9252000014f82ff';

  static const String appSecret =
      'SFMyNTY.g3QAAAACZAAEZGF0YXQAAAADbQAAAAlhY2NvdW50SWRtAAAAGDVlYjNkYjliYTkyNTIwMDAwMTRmODJmZm0AAAAIa2V5c2V0SWRtAAAAJDE0NTE0ZTVmLWMwYWEtNGFjYy04YzU0LWFhZGYxMjA1Nzk3NW0AAAAJcHJvamVjdElkbQAAACQwYjVmYWNmNC1jZmY3LTRiN2EtYTM4Ni1lZTM5NDVmODk1ZjBkAAZzaWduZWRuBgAJquZ4hgE.39woSdaHP5QFUCbinqwoKSqR0xhm6tndiwrlFKeB608';
  static const String userSecret =
      'SFMyNTY.g3QAAAACZAAEZGF0YXQAAAADbQAAAAlhY2NvdW50SWRtAAAAGDVlYjNkYjliYTkyNTIwMDAwMTRmODJmZm0AAAAIa2V5c2V0SWRtAAAAJDE0NTE0ZTVmLWMwYWEtNGFjYy04YzU0LWFhZGYxMjA1Nzk3NW0AAAAJcHJvamVjdElkbQAAACQwYjVmYWNmNC1jZmY3LTRiN2EtYTM4Ni1lZTM5NDVmODk1ZjBkAAZzaWduZWRuBgAJquZ4hgE._bm1V7mVGLt1CPyj8x1tB9LbOiO0qVfDH5JrtQ6cwzo';

  static const String mqttHost = 'connections.isometrik.io';
  static const int mqttPort = 2052;
}
