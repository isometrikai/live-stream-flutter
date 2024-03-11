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

  static const String licenseKey = 'lic-IMKPioj9hM3hMCh5eoeRC+d+l2TuxWOyPK3';
  static const String keySetId = '40063abb-5af1-4fd4-a7f0-adc4767810b1';
  static const String projectId = 'e1241039-2fef-4830-b927-5bb3424f1764';
  static const String accountId = '5eb3db9ba9252000014f82ff';

  static const String appSecret =
      'SFMyNTY.g3QAAAACZAAEZGF0YXQAAAADbQAAAAlhY2NvdW50SWRtAAAAGDVlYjNkYjliYTkyNTIwMDAwMTRmODJmZm0AAAAIa2V5c2V0SWRtAAAAJDQwMDYzYWJiLTVhZjEtNGZkNC1hN2YwLWFkYzQ3Njc4MTBiMW0AAAAJcHJvamVjdElkbQAAACRlMTI0MTAzOS0yZmVmLTQ4MzAtYjkyNy01YmIzNDI0ZjE3NjRkAAZzaWduZWRuBgAyRZTfiQE.Cd8oTBl0_bylLMQ45YXxUYqyIhbxstGEwCRIgLlQC3Y';
  static const String userSecret =
      'SFMyNTY.g3QAAAACZAAEZGF0YXQAAAADbQAAAAlhY2NvdW50SWRtAAAAGDVlYjNkYjliYTkyNTIwMDAwMTRmODJmZm0AAAAIa2V5c2V0SWRtAAAAJDQwMDYzYWJiLTVhZjEtNGZkNC1hN2YwLWFkYzQ3Njc4MTBiMW0AAAAJcHJvamVjdElkbQAAACRlMTI0MTAzOS0yZmVmLTQ4MzAtYjkyNy01YmIzNDI0ZjE3NjRkAAZzaWduZWRuBgA2RZTfiQE.ci4LzhsWp_E8bTTFVymYqWrCfCBm92uJ1QlczU1PvbY';

  static const String mqttHost = 'connections.isometrik.io';
  static const int mqttPort = 2052;
}
