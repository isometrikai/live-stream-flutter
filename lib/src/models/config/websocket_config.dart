import 'dart:convert';

import 'package:flutter/foundation.dart';

class IsmLiveWebSocketConfig {
  const IsmLiveWebSocketConfig({
    required this.useWebsocket,
    required this.websocketProtocols,
  }) : assert(
          !useWebsocket || (useWebsocket && websocketProtocols.length != 0),
          'if useWebsocket is set to true, the websocket protocols must be specified',
        );

  factory IsmLiveWebSocketConfig.fromMap(Map<String, dynamic> map) =>
      IsmLiveWebSocketConfig(
        useWebsocket: map['useWebsocket'] as bool,
        websocketProtocols: (map['websocketProtocols'] as List).cast(),
      );

  factory IsmLiveWebSocketConfig.fromJson(String source) =>
      IsmLiveWebSocketConfig.fromMap(
          json.decode(source) as Map<String, dynamic>);

  final bool useWebsocket;
  final List<String> websocketProtocols;

  IsmLiveWebSocketConfig copyWith({
    bool? useWebsocket,
    List<String>? websocketProtocols,
  }) =>
      IsmLiveWebSocketConfig(
        useWebsocket: useWebsocket ?? this.useWebsocket,
        websocketProtocols: websocketProtocols ?? this.websocketProtocols,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'useWebsocket': useWebsocket,
        'websocketProtocols': websocketProtocols,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmLiveWebSocketConfig(useWebsocket: $useWebsocket, websocketProtocols: $websocketProtocols)';

  @override
  bool operator ==(covariant IsmLiveWebSocketConfig other) {
    if (identical(this, other)) return true;

    return other.useWebsocket == useWebsocket &&
        listEquals(other.websocketProtocols, websocketProtocols);
  }

  @override
  int get hashCode => useWebsocket.hashCode ^ websocketProtocols.hashCode;
}
