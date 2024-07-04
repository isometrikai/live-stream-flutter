import 'dart:convert';

class IsmLiveProjectConfig {
  factory IsmLiveProjectConfig.fromMap(Map<String, dynamic> map) =>
      IsmLiveProjectConfig(
        accountId: map['accountId'] as String,
        appSecret: map['appSecret'] as String,
        userSecret: map['userSecret'] as String,
        keySetId: map['keySetId'] as String,
        licenseKey: map['licenseKey'] as String,
        projectId: map['projectId'] as String,
        deviceId: map['deviceId'] as String,
      );

  factory IsmLiveProjectConfig.fromJson(String source) =>
      IsmLiveProjectConfig.fromMap(json.decode(source) as Map<String, dynamic>);

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

  Map<String, dynamic> toMap() => <String, dynamic>{
        'accountId': accountId,
        'appSecret': appSecret,
        'userSecret': userSecret,
        'keySetId': keySetId,
        'licenseKey': licenseKey,
        'projectId': projectId,
        'deviceId': deviceId,
      };

  String toJson() => json.encode(toMap());
}
