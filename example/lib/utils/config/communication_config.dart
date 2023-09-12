class CommunicationConfig {
  const CommunicationConfig({
    required this.oneSignalId,
    required this.serverUrl,
    required this.username,
    required this.password,
    required this.port,
  });
  final String oneSignalId;
  final String serverUrl;
  final String username;
  final String password;
  final int port;
}
