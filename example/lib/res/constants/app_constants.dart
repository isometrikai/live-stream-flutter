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

  // static const String accountId = '652f9ad3e24477cce4a025d5';

  // static const String projectId = '88cad458-e9a0-4109-a2d6-df520e56b4f7';

  // static const String keySetId = 'b17b380d-153e-4017-8a8f-26b61f5c23c8';

  // static const String licenseKey = 'lic-IMKm3wNSIeSnxmdj/lOy4mB55sziy2A1NhU';

  // static const String appSecret =
  //     'SFMyNTY.g3QAAAACZAAEZGF0YXQAAAADbQAAAAlhY2NvdW50SWRtAAAAGDY1MmY5YWQzZTI0NDc3Y2NlNGEwMjVkNW0AAAAIa2V5c2V0SWRtAAAAJGIxN2IzODBkLTE1M2UtNDAxNy04YThmLTI2YjYxZjVjMjNjOG0AAAAJcHJvamVjdElkbQAAACQ4OGNhZDQ1OC1lOWEwLTQxMDktYTJkNi1kZjUyMGU1NmI0ZjdkAAZzaWduZWRuBgAyh_ZBiwE.u0RqujyPa8EB036aYWH50kME2sMLgjC7faUtYTJxHFM';

  // static const String userSecret =
  //     'SFMyNTY.g3QAAAACZAAEZGF0YXQAAAADbQAAAAlhY2NvdW50SWRtAAAAGDY1MmY5YWQzZTI0NDc3Y2NlNGEwMjVkNW0AAAAIa2V5c2V0SWRtAAAAJGIxN2IzODBkLTE1M2UtNDAxNy04YThmLTI2YjYxZjVjMjNjOG0AAAAJcHJvamVjdElkbQAAACQ4OGNhZDQ1OC1lOWEwLTQxMDktYTJkNi1kZjUyMGU1NmI0ZjdkAAZzaWduZWRuBgAyh_ZBiwE.nWn8_aZvCwqH1smL9Mp8tgYeG4S04WWSrbwczusX5Cg';

  // static const String licenseKey = 'lic-IMKPioj9hM3hMCh5eoeRC+d+l2TuxWOyPK3';
  // static const String keySetId = '40063abb-5af1-4fd4-a7f0-adc4767810b1';
  // static const String projectId = 'e1241039-2fef-4830-b927-5bb3424f1764';
  // static const String accountId = '5eb3db9ba9252000014f82ff';

  // static const String appSecret =
  //     'SFMyNTY.g3QAAAACZAAEZGF0YXQAAAADbQAAAAlhY2NvdW50SWRtAAAAGDVlYjNkYjliYTkyNTIwMDAwMTRmODJmZm0AAAAIa2V5c2V0SWRtAAAAJDQwMDYzYWJiLTVhZjEtNGZkNC1hN2YwLWFkYzQ3Njc4MTBiMW0AAAAJcHJvamVjdElkbQAAACRlMTI0MTAzOS0yZmVmLTQ4MzAtYjkyNy01YmIzNDI0ZjE3NjRkAAZzaWduZWRuBgAyRZTfiQE.Cd8oTBl0_bylLMQ45YXxUYqyIhbxstGEwCRIgLlQC3Y';
  // static const String userSecret =
  //     'SFMyNTY.g3QAAAACZAAEZGF0YXQAAAADbQAAAAlhY2NvdW50SWRtAAAAGDVlYjNkYjliYTkyNTIwMDAwMTRmODJmZm0AAAAIa2V5c2V0SWRtAAAAJDQwMDYzYWJiLTVhZjEtNGZkNC1hN2YwLWFkYzQ3Njc4MTBiMW0AAAAJcHJvamVjdElkbQAAACRlMTI0MTAzOS0yZmVmLTQ4MzAtYjkyNy01YmIzNDI0ZjE3NjRkAAZzaWduZWRuBgA2RZTfiQE.ci4LzhsWp_E8bTTFVymYqWrCfCBm92uJ1QlczU1PvbY';

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

/*
{ "accountId": "65fac77b6a4e7c0001d4dc36"
    "userSecret": "SFMyNTY.g3QAAAACZAAEZGF0YXQAAAADbQAAAAlhY2NvdW50SWRtAAAAGDY1ZmFjNzdiNmE0ZTdjMDAwMWQ0ZGMzNm0AAAAIa2V5c2V0SWRtAAAAJDY3M2E4MjRjLWUwNjktNDRlZS04NWY1LWYxMWVmZmZkNWUxNW0AAAAJcHJvamVjdElkbQAAACQ2NDA3YWY1NS1jNTBkLTQ3ZDItOWIyZS01NTdmMWY1ZmY0MDRkAAZzaWduZWRuBgBQ0JxbjgE.ZKih77MLvSYpxEMUSGEopAMVRyM6w_-lYWlgjTLBNCk",
    "subscribeKey": "sub-IMKHzLoe2MDG8RSadie/yNbxlhYvApPpU8/",
    "publishKey": "pub-IMKo2udqF+j9YkIHcybf8PwBXyPiYZKz+Wj",
    "projectId": "6407af55-c50d-47d2-9b2e-557f1f5ff404",
  
    "licenseKey": "lic-IMKXFhpiprTyYbDZcVFkxQI7hbYRPPgDIWB",
    "keysetName": "Demo Keyset",
    "keysetId": "673a824c-e069-44ee-85f5-f11efffd5e15",
    "appSecret": "SFMyNTY.g3QAAAACZAAEZGF0YXQAAAADbQAAAAlhY2NvdW50SWRtAAAAGDY1ZmFjNzdiNmE0ZTdjMDAwMWQ0ZGMzNm0AAAAIa2V5c2V0SWRtAAAAJDY3M2E4MjRjLWUwNjktNDRlZS04NWY1LWYxMWVmZmZkNWUxNW0AAAAJcHJvamVjdElkbQAAACQ2NDA3YWY1NS1jNTBkLTQ3ZDItOWIyZS01NTdmMWY1ZmY0MDRkAAZzaWduZWRuBgBQ0JxbjgE.Ep4179UmRq4zDLCsvO3u5kisCS5P2XlCkwyGeLP46F8"
}
 */