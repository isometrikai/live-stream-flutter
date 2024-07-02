import 'dart:convert';

class IsmLiveMqttConfig {
  factory IsmLiveMqttConfig.fromMap(Map<String, dynamic> map) =>
      IsmLiveMqttConfig(
        hostName: map['hostName'] as String,
        port: map['port'] as int,
      );

  factory IsmLiveMqttConfig.fromJson(String source) =>
      IsmLiveMqttConfig.fromMap(json.decode(source) as Map<String, dynamic>);

  const IsmLiveMqttConfig({
    required this.hostName,
    required this.port,
  });
  final String hostName;
  final int port;

  @override
  String toString() => 'IsmLiveMqttConfig(hostName: $hostName, port: $port)';

  Map<String, dynamic> toMap() => <String, dynamic>{
        'hostName': hostName,
        'port': port,
      };

  String toJson() => json.encode(toMap());
}
