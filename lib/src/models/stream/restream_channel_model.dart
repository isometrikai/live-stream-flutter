// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class IsmLiveReStreamModel {
  final String? ingestUrl;
  final bool? enabled;
  final int? channelType;
  final String? channelName;
  final String? channelId;
  IsmLiveReStreamModel({
    this.ingestUrl,
    this.enabled,
    this.channelType,
    this.channelName,
    this.channelId,
  });

  IsmLiveReStreamModel copyWith({
    String? ingestUrl,
    bool? enabled,
    int? channelType,
    String? channelName,
    String? channelId,
  }) =>
      IsmLiveReStreamModel(
        ingestUrl: ingestUrl ?? this.ingestUrl,
        enabled: enabled ?? this.enabled,
        channelType: channelType ?? this.channelType,
        channelName: channelName ?? this.channelName,
        channelId: channelId ?? this.channelId,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'ingestUrl': ingestUrl,
        'enabled': enabled,
        'channelType': channelType,
        'channelName': channelName,
        'channelId': channelId,
      };

  factory IsmLiveReStreamModel.fromMap(Map<String, dynamic> map) =>
      IsmLiveReStreamModel(
        ingestUrl: map['ingestUrl'] != null ? map['ingestUrl'] as String : null,
        enabled: map['enabled'] != null ? map['enabled'] as bool : null,
        channelType:
            map['channelType'] != null ? map['channelType'] as int : null,
        channelName:
            map['channelName'] != null ? map['channelName'] as String : null,
        channelId: map['channelId'] != null ? map['channelId'] as String : null,
      );

  String toJson() => json.encode(toMap());

  factory IsmLiveReStreamModel.fromJson(String source) =>
      IsmLiveReStreamModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'IsmLiveReStreamModel(ingestUrl: $ingestUrl, enabled: $enabled, channelType: $channelType, channelName: $channelName, channelId: $channelId)';

  @override
  bool operator ==(covariant IsmLiveReStreamModel other) {
    if (identical(this, other)) return true;

    return other.ingestUrl == ingestUrl &&
        other.enabled == enabled &&
        other.channelType == channelType &&
        other.channelName == channelName &&
        other.channelId == channelId;
  }

  @override
  int get hashCode =>
      ingestUrl.hashCode ^
      enabled.hashCode ^
      channelType.hashCode ^
      channelName.hashCode ^
      channelId.hashCode;
}
