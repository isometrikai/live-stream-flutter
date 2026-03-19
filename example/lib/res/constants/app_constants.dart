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

  static const String licenseKeyCallQwik =
      'lic-IMKXFhpiprTyYbDZcVFkxQI7hbYRPPgDIWB';
  static const String keySetIdCallQwik = 'Demo Keyset';
  static const String projectIdCallQwik =
      '6407af55-c50d-47d2-9b2e-557f1f5ff404';
  static const String accountIdCallQwik = '65fac77b6a4e7c0001d4dc36';

  static const String appSecretCallQwik =
      'SFMyNTY.g3QAAAACZAAEZGF0YXQAAAADbQAAAAlhY2NvdW50SWRtAAAAGDY1ZmFjNzdiNmE0ZTdjMDAwMWQ0ZGMzNm0AAAAIa2V5c2V0SWRtAAAAJDY3M2E4MjRjLWUwNjktNDRlZS04NWY1LWYxMWVmZmZkNWUxNW0AAAAJcHJvamVjdElkbQAAACQ2NDA3YWY1NS1jNTBkLTQ3ZDItOWIyZS01NTdmMWY1ZmY0MDRkAAZzaWduZWRuBgBQ0JxbjgE.Ep4179UmRq4zDLCsvO3u5kisCS5P2XlCkwyGeLP46F8';
  static const String userSecretCallQwik =
      'SFMyNTY.g3QAAAACZAAEZGF0YXQAAAADbQAAAAlhY2NvdW50SWRtAAAAGDY1ZmFjNzdiNmE0ZTdjMDAwMWQ0ZGMzNm0AAAAIa2V5c2V0SWRtAAAAJDY3M2E4MjRjLWUwNjktNDRlZS04NWY1LWYxMWVmZmZkNWUxNW0AAAAJcHJvamVjdElkbQAAACQ2NDA3YWY1NS1jNTBkLTQ3ZDItOWIyZS01NTdmMWY1ZmY0MDRkAAZzaWduZWRuBgBQ0JxbjgE.ZKih77MLvSYpxEMUSGEopAMVRyM6w_-lYWlgjTLBNCk';

  static const String mqttHost = 'connections.isometrik.io';
  static const int mqttPort = 2052;
}
