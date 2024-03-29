class IsmLiveProjectConfig {
  const IsmLiveProjectConfig({
    required this.accountId,
    required this.appSecret,
    required this.userSecret,
    required this.keySetId,
    required this.licenseKey,
    required this.projectId,
    required this.deviceId,
  });
  final String accountId;
  final String appSecret;
  final String userSecret;
  final String keySetId;
  final String licenseKey;
  final String projectId;
  final String deviceId;

  @override
  String toString() =>
      'IsmLiveProjectConfig(accountId: $accountId, appSecret: $appSecret, userSecret: $userSecret, keySetId: $keySetId, licenseKey: $licenseKey, projectId: $projectId, deviceId: $deviceId)';
}
