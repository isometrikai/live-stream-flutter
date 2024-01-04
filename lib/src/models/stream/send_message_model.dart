// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';

class IsmLiveSendMessageModel {
  final String streamId;
  final String body;
  final dynamic searchableTags;
  final IsmLiveMetaData metaData;
  final String customType;
  final String deviceId;
  final int messageType;
  IsmLiveSendMessageModel({
    required this.streamId,
    required this.body,
    required this.searchableTags,
    required this.metaData,
    required this.customType,
    required this.deviceId,
    required this.messageType,
  });

  IsmLiveSendMessageModel copyWith({
    String? streamId,
    String? body,
    dynamic searchableTags,
    IsmLiveMetaData? metaData,
    String? customType,
    String? deviceId,
    int? messageType,
  }) =>
      IsmLiveSendMessageModel(
        streamId: streamId ?? this.streamId,
        body: body ?? this.body,
        searchableTags: searchableTags ?? this.searchableTags,
        metaData: metaData ?? this.metaData,
        customType: customType ?? this.customType,
        deviceId: deviceId ?? this.deviceId,
        messageType: messageType ?? this.messageType,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'streamId': streamId,
        'body': body,
        'searchableTags': searchableTags,
        'metaData': metaData.toMap(),
        'customType': customType,
        'deviceId': deviceId,
        'messageType': messageType,
      };

  factory IsmLiveSendMessageModel.fromMap(Map<String, dynamic> map) =>
      IsmLiveSendMessageModel(
        streamId: map['streamId'] as String,
        body: map['body'] as String,
        searchableTags: map['searchableTags'] as dynamic,
        metaData:
            IsmLiveMetaData.fromMap(map['metaData'] as Map<String, dynamic>),
        customType: map['customType'] as String,
        deviceId: map['deviceId'] as String,
        messageType: map['messageType'] as int,
      );

  String toJson() => json.encode(toMap());

  factory IsmLiveSendMessageModel.fromJson(String source) =>
      IsmLiveSendMessageModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'IsmLiveSendMessageModel(streamId: $streamId, body: $body, searchableTags: $searchableTags, metaData: $metaData, customType: $customType, deviceId: $deviceId, messageType: $messageType)';

  @override
  bool operator ==(covariant IsmLiveSendMessageModel other) {
    if (identical(this, other)) return true;

    return other.streamId == streamId &&
        other.body == body &&
        other.searchableTags == searchableTags &&
        other.metaData == metaData &&
        other.customType == customType &&
        other.deviceId == deviceId &&
        other.messageType == messageType;
  }

  @override
  int get hashCode =>
      streamId.hashCode ^
      body.hashCode ^
      searchableTags.hashCode ^
      metaData.hashCode ^
      customType.hashCode ^
      deviceId.hashCode ^
      messageType.hashCode;
}
