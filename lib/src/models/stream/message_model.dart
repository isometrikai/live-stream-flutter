import 'dart:convert';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/foundation.dart';

class IsmLiveMessageModel {
  const IsmLiveMessageModel({
    this.sentAt = 0,
    required this.streamId,
    this.senderProfileImageUrl,
    required this.senderName,
    required this.senderIdentifier,
    required this.senderId,
    this.searchableTags,
    this.replyMessage = false,
    this.repliesCount = 0,
    this.metaData,
    required this.messageType,
    required this.messageId,
    this.deviceId,
    this.customType,
    required this.body,
    this.isEvent = false,
    this.parentMessageId,
    this.parentMessageSenderId,
    this.isCopublisherRequest = false,
  });

  factory IsmLiveMessageModel.fromMap(Map<String, dynamic> map) =>
      IsmLiveMessageModel(
        sentAt: map['sentAt'] as int,
        streamId: map['streamId'] as String? ?? '',
        senderProfileImageUrl: map['senderProfileImageUrl'] as String?,
        senderName: map['senderName'] as String,
        senderIdentifier: map['senderIdentifier'] as String,
        senderId: map['senderId'] as String,
        searchableTags:
            (map['searchableTags'] as List<dynamic>? ?? []).cast<dynamic>(),
        replyMessage: map['replyMessage'] as bool? ?? false,
        repliesCount: map['repliesCount'] as int? ?? 0,
        metaData: map['metaData'] != null
            ? IsmLiveMetaData.fromMap(map['metaData'] as Map<String, dynamic>)
            : null,
        messageType: IsmLiveMessageType.fromValue(map['messageType'] as int),
        messageId: map['messageId'] as String,
        deviceId: map['deviceId'] as String?,
        customType: map['customType'] != null
            ? IsmLiveGifts.fromName(map['customType'].toString())
            : null,
        body: utf8.decode((map['body'] as String).runes.toList()),
        parentMessageId: map['parentMessageId'] as String?,
        parentMessageSenderId: map['parentMessageSenderId'] as String?,
      );

  factory IsmLiveMessageModel.fromJson(String source) =>
      IsmLiveMessageModel.fromMap(json.decode(source) as Map<String, dynamic>);

  final int sentAt;
  final String streamId;
  final String? senderProfileImageUrl;
  final String senderName;
  final String senderIdentifier;
  final String senderId;
  final List<dynamic>? searchableTags;
  final bool replyMessage;
  final int repliesCount;
  final IsmLiveMetaData? metaData;
  final IsmLiveMessageType messageType;
  final String messageId;
  final String? deviceId;
  final IsmLiveGifts? customType;
  final String body;
  final bool isEvent;
  final String? parentMessageId;
  final String? parentMessageSenderId;
  final bool isCopublisherRequest;

  IsmLiveMessageModel copyWith({
    int? sentAt,
    String? streamId,
    String? senderProfileImageUrl,
    String? senderName,
    String? senderIdentifier,
    String? senderId,
    List<dynamic>? searchableTags,
    bool? replyMessage,
    int? repliesCount,
    IsmLiveMetaData? metaData,
    IsmLiveMessageType? messageType,
    String? messageId,
    String? deviceId,
    IsmLiveGifts? customType,
    String? body,
    bool? isEvent,
    String? parentMessageId,
    String? parentMessageSenderId,
  }) =>
      IsmLiveMessageModel(
        sentAt: sentAt ?? this.sentAt,
        streamId: streamId ?? this.streamId,
        senderProfileImageUrl:
            senderProfileImageUrl ?? this.senderProfileImageUrl,
        senderName: senderName ?? this.senderName,
        senderIdentifier: senderIdentifier ?? this.senderIdentifier,
        senderId: senderId ?? this.senderId,
        searchableTags: searchableTags ?? this.searchableTags,
        replyMessage: replyMessage ?? this.replyMessage,
        repliesCount: repliesCount ?? this.repliesCount,
        metaData: metaData ?? this.metaData,
        messageType: messageType ?? this.messageType,
        messageId: messageId ?? this.messageId,
        deviceId: deviceId ?? this.deviceId,
        customType: customType ?? this.customType,
        body: body ?? this.body,
        isEvent: isEvent ?? this.isEvent,
        parentMessageId: parentMessageId ?? this.parentMessageId,
        parentMessageSenderId:
            parentMessageSenderId ?? this.parentMessageSenderId,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'sentAt': sentAt,
        'streamId': streamId,
        'senderProfileImageUrl': senderProfileImageUrl,
        'senderName': senderName,
        'senderIdentifier': senderIdentifier,
        'senderId': senderId,
        'searchableTags': searchableTags,
        'replyMessage': replyMessage,
        'repliesCount': repliesCount,
        'metaData': metaData?.toMap(),
        'messageType': messageType.value,
        'messageId': messageId,
        'deviceId': deviceId,
        'customType': customType?.name,
        'body': body,
        'isEvent': isEvent,
        'parentMessageId': parentMessageId,
        'parentMessageSenderId': parentMessageSenderId,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmLiveMessageModel(sentAt: $sentAt, streamId: $streamId, senderProfileImageUrl: $senderProfileImageUrl, senderName: $senderName, senderIdentifier: $senderIdentifier, senderId: $senderId, searchableTags: $searchableTags, replyMessage: $replyMessage, repliesCount: $repliesCount, metaData: $metaData, messageType: $messageType, messageId: $messageId, deviceId: $deviceId, customType: $customType, body: $body, isEvent: $isEvent, parentMessageId: $parentMessageId, parentMessageSenderId: $parentMessageSenderId)';

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
        other.replyMessage == replyMessage &&
        other.repliesCount == repliesCount &&
        other.metaData == metaData &&
        other.messageType == messageType &&
        other.messageId == messageId &&
        other.deviceId == deviceId &&
        other.customType == customType &&
        other.body == body &&
        other.isEvent == isEvent &&
        other.parentMessageId == parentMessageId &&
        other.parentMessageSenderId == parentMessageSenderId;
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
      replyMessage.hashCode ^
      repliesCount.hashCode ^
      metaData.hashCode ^
      messageType.hashCode ^
      messageId.hashCode ^
      deviceId.hashCode ^
      customType.hashCode ^
      body.hashCode ^
      isEvent.hashCode ^
      parentMessageId.hashCode ^
      parentMessageSenderId.hashCode;
}
