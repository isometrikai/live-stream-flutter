class IsmLiveCommunicationConfig {
  const IsmLiveCommunicationConfig({
    required this.licenseKey,
    required this.appSecret,
    required this.userSecret,
  });

  final String licenseKey;
  final String appSecret;
  final String userSecret;
}
