class IsmLiveMqttConfig {
  const IsmLiveMqttConfig({
    required this.hostName,
    required this.port,
  });
  final String hostName;
  final int port;

  @override
  String toString() => 'IsmLiveMqttConfig(hostName: $hostName, port: $port)';
}
