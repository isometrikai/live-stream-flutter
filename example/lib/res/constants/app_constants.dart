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
  static const String userSecret =
      'SFMyNTY.g3QAAAACZAAEZGF0YXQAAAADbQAAAAlhY2NvdW50SWRtAAAAGDYxMDkyZDY3YzRmYWMzMDAwMTQwNWQ3Zm0AAAAIa2V5c2V0SWRtAAAAJDc2ZWNkZjEwLThlM2ItNGVmZS04NDZkLTU3NDJmODYxZjgzOG0AAAAJcHJvamVjdElkbQAAACQwMTEzYzQ0ZC04NmQzLTQyM2QtYjkyYS0xYmU2NTExZjdiOGZkAAZzaWduZWRuBgDRqeZ4hgE.DkR1H6BMWCQn1njtbaDc8WNBnIdALzjBAs_8Ks7AERE';

  static const String appSecret =
      'SFMyNTY.g3QAAAACZAAEZGF0YXQAAAADbQAAAAlhY2NvdW50SWRtAAAAGDYxMDkyZDY3YzRmYWMzMDAwMTQwNWQ3Zm0AAAAIa2V5c2V0SWRtAAAAJDc2ZWNkZjEwLThlM2ItNGVmZS04NDZkLTU3NDJmODYxZjgzOG0AAAAJcHJvamVjdElkbQAAACQwMTEzYzQ0ZC04NmQzLTQyM2QtYjkyYS0xYmU2NTExZjdiOGZkAAZzaWduZWRuBgDRqeZ4hgE.1GhE6fDbTPUWBbHNEptDylNxFHv67AMSH6nWq4OC8pY';

  static const String accountId = '61092d67c4fac30001405d7f';
  static const String keySetId = '76ecdf10-8e3b-4efe-846d-5742f861f838';
  static const String projectId = '0113c44d-86d3-423d-b92a-1be6511f7b8f';
  static const String licenseKey = 'lic-IMK/+mao5KikRmifcmkjavAZa4vGnIwiRTz';

  static const String mqttHost = 'connections.isometrik.ai';
  static const int mqttPort = 2086;

  static const String videoEffectsAndroidCustomerId =
      'dbd344bfa2116a416703372a88eeeb2e8f012b9e';
  static const String videoEffectsIosCustomerId =
      '8927ba46e6cc19248889f9d2450f6163334fc754';


  /// True when every required project credential was provided at compile time.
  static bool get hasProjectConfig =>
      userSecret.isNotEmpty &&
          appSecret.isNotEmpty &&
          accountId.isNotEmpty &&
          keySetId.isNotEmpty &&
          projectId.isNotEmpty &&
          licenseKey.isNotEmpty;

  /// Throws if dart-defines are missing. Call before building live config.
  static void ensureProjectConfig() {
    if (hasProjectConfig) return;
    throw StateError(
      'Missing Isometrik project config. Copy example/secrets.json.example '
          'to example/secrets.json, fill in values, then run with '
          '--dart-define-from-file=secrets.json',
    );
  }
}
