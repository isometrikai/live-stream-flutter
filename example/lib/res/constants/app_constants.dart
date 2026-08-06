/// `AppConstants` is a singleton class with all static variables.
///
/// It contains all constants that are to be used within the project
///
/// Project credentials are injected at build time via `--dart-define` /
/// `--dart-define-from-file` so they are not committed to source control.
///
/// Copy `example/secrets.json.example` → `example/secrets.json`, fill values,
/// then run:
/// `flutter run --dart-define-from-file=secrets.json`
class AppConstants {
  const AppConstants._();

  static const String appName = 'Appscrip Live Stream Example';

  static const Duration timeOutDuration = Duration(seconds: 60);

  static const String userSecret = String.fromEnvironment('ISM_USER_SECRET');
  static const String appSecret = String.fromEnvironment('ISM_APP_SECRET');
  static const String accountId = String.fromEnvironment('ISM_ACCOUNT_ID');
  static const String keySetId = String.fromEnvironment('ISM_KEYSET_ID');
  static const String projectId = String.fromEnvironment('ISM_PROJECT_ID');
  static const String licenseKey = String.fromEnvironment('ISM_LICENSE_KEY');

  static const String mqttHost = 'connections.isometrik.ai';
  static const int mqttPort = 2086;

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
