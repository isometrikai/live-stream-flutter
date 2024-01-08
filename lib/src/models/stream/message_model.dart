import 'dart:convert';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/foundation.dart';

class IsmLiveMessageModel {
  const IsmLiveMessageModel({
    required this.sentAt,
    required this.streamId,
    this.senderProfileImageUrl,
    required this.senderName,
    required this.senderIdentifier,
    required this.senderId,
    this.searchableTags,
    required this.repliesCount,
    this.metaData,
    required this.messageType,
    required this.messageId,
    this.deviceId,
    this.customType,
    required this.body,
  });

  factory IsmLiveMessageModel.fromMap(Map<String, dynamic> map) => IsmLiveMessageModel(
        sentAt: map['sentAt'] as int,
        streamId: map['streamId'] as String,
        senderProfileImageUrl: map['senderProfileImageUrl'] as String?,
        senderName: map['senderName'] as String,
        senderIdentifier: map['senderIdentifier'] as String,
        senderId: map['senderId'] as String,
        searchableTags: (map['searchableTags'] as List<dynamic>? ?? []).cast<String>(),
        repliesCount: map['repliesCount'] as int,
        metaData: map['metaData'] != null ? IsmLiveMetaData.fromMap(map['metaData'] as Map<String, dynamic>) : null,
        messageType: map['messageType'] as int,
        messageId: map['messageId'] as String,
        deviceId: map['deviceId'] as String?,
        customType: map['customType'] as String?,
        body: map['body'] as String,
      );

  factory IsmLiveMessageModel.fromJson(String source) => IsmLiveMessageModel.fromMap(json.decode(source) as Map<String, dynamic>);

  final int sentAt;
  final String streamId;
  final String? senderProfileImageUrl;
  final String senderName;
  final String senderIdentifier;
  final String senderId;
  final List<dynamic>? searchableTags;
  final int repliesCount;
  final IsmLiveMetaData? metaData;
  final int messageType;
  final String messageId;
  final String? deviceId;
  final String? customType;
  final String body;

  IsmLiveMessageModel copyWith({
    int? sentAt,
    String? streamId,
    String? senderProfileImageUrl,
    String? senderName,
    String? senderIdentifier,
    String? senderId,
    List<dynamic>? searchableTags,
    int? repliesCount,
    IsmLiveMetaData? metaData,
    int? messageType,
    String? messageId,
    String? deviceId,
    String? customType,
    String? body,
  }) =>
      IsmLiveMessageModel(
        sentAt: sentAt ?? this.sentAt,
        streamId: streamId ?? this.streamId,
        senderProfileImageUrl: senderProfileImageUrl ?? this.senderProfileImageUrl,
        senderName: senderName ?? this.senderName,
        senderIdentifier: senderIdentifier ?? this.senderIdentifier,
        senderId: senderId ?? this.senderId,
        searchableTags: searchableTags ?? this.searchableTags,
        repliesCount: repliesCount ?? this.repliesCount,
        metaData: metaData ?? this.metaData,
        messageType: messageType ?? this.messageType,
        messageId: messageId ?? this.messageId,
        deviceId: deviceId ?? this.deviceId,
        customType: customType ?? this.customType,
        body: body ?? this.body,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'sentAt': sentAt,
        'streamId': streamId,
        'senderProfileImageUrl': senderProfileImageUrl,
        'senderName': senderName,
        'senderIdentifier': senderIdentifier,
        'senderId': senderId,
        'searchableTags': searchableTags,
        'repliesCount': repliesCount,
        'metaData': metaData?.toMap(),
        'messageType': messageType,
        'messageId': messageId,
        'deviceId': deviceId,
        'customType': customType,
        'body': body,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmLiveMessageModel(sentAt: $sentAt, streamId: $streamId, senderProfileImageUrl: $senderProfileImageUrl, senderName: $senderName, senderIdentifier: $senderIdentifier, senderId: $senderId, searchableTags: $searchableTags, repliesCount: $repliesCount, metaData: $metaData, messageType: $messageType, messageId: $messageId, deviceId: $deviceId, customType: $customType, body: $body)';

  @override
  bool operator ==(covariant IsmLiveMessageModel other) {
    if (identical(this, other)) return true;

    return other.sentAt == sentAt &&
        other.streamId == streamId &&
        other.senderProfileImageUrl == senderProfileImageUrl &&
        other.senderName == senderName &&
        other.senderIdentifier == senderIdentifier &&
        other.senderId == senderId &&
        listEquals(other.searchableTags, searchableTags) &&
        other.repliesCount == repliesCount &&
        other.metaData == metaData &&
        other.messageType == messageType &&
        other.messageId == messageId &&
        other.deviceId == deviceId &&
        other.customType == customType &&
        other.body == body;
  }

  @override
  int get hashCode =>
      sentAt.hashCode ^
      streamId.hashCode ^
      senderProfileImageUrl.hashCode ^
      senderName.hashCode ^
      senderIdentifier.hashCode ^
      senderId.hashCode ^
      searchableTags.hashCode ^
      repliesCount.hashCode ^
      metaData.hashCode ^
      messageType.hashCode ^
      messageId.hashCode ^
      deviceId.hashCode ^
      customType.hashCode ^
      body.hashCode;
}
