// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/foundation.dart';

class IsmLiveMessageModel {
  final num sentAt;
  final String? senderProfileImageUrl;
  final String senderName;
  final String senderIdentifier;
  final String senderId;
  final List<dynamic>? searchableTags;
  final num repliesCount;
  final IsmLiveMetaData? metaData;
  final int messageType;
  final String messageId;
  final String? deviceId;
  final String? customType;
  final String body;
  IsmLiveMessageModel({
    required this.sentAt,
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

  IsmLiveMessageModel copyWith({
    num? sentAt,
    String? senderProfileImageUrl,
    String? senderName,
    String? senderIdentifier,
    String? senderId,
    List<dynamic>? searchableTags,
    num? repliesCount,
    IsmLiveMetaData? metaData,
    int? messageType,
    String? messageId,
    String? deviceId,
    String? customType,
    String? body,
  }) =>
      IsmLiveMessageModel(
        sentAt: sentAt ?? this.sentAt,
        senderProfileImageUrl:
            senderProfileImageUrl ?? this.senderProfileImageUrl,
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

  factory IsmLiveMessageModel.fromMap(Map<String, dynamic> map) =>
      IsmLiveMessageModel(
        sentAt: map['sentAt'] as num,
        senderProfileImageUrl: map['senderProfileImageUrl'] != null
            ? map['senderProfileImageUrl'] as String
            : null,
        senderName: map['senderName'] as String,
        senderIdentifier: map['senderIdentifier'] as String,
        senderId: map['senderId'] as String,
        searchableTags: map['searchableTags'] != null
            ? List<dynamic>.from(map['searchableTags'] as List<dynamic>)
            : null,
        repliesCount: map['repliesCount'] as num,
        metaData: map['metaData'] != null
            ? IsmLiveMetaData.fromMap(map['metaData'] as Map<String, dynamic>)
            : null,
        messageType: map['messageType'] as int,
        messageId: map['messageId'] as String,
        deviceId: map['deviceId'] != null ? map['deviceId'] as String : null,
        customType:
            map['customType'] != null ? map['customType'] as String : null,
        body: map['body'] as String,
      );

  String toJson() => json.encode(toMap());

  factory IsmLiveMessageModel.fromJson(String source) =>
      IsmLiveMessageModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'IsmLiveMessageModel(sentAt: $sentAt, senderProfileImageUrl: $senderProfileImageUrl, senderName: $senderName, senderIdentifier: $senderIdentifier, senderId: $senderId, searchableTags: $searchableTags, repliesCount: $repliesCount, metaData: $metaData, messageType: $messageType, messageId: $messageId, deviceId: $deviceId, customType: $customType, body: $body)';

  @override
  bool operator ==(covariant IsmLiveMessageModel other) {
    if (identical(this, other)) return true;

    return other.sentAt == sentAt &&
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
