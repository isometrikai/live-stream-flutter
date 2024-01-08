// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

class IsmLiveGetMessageModel {
  final String streamId;
  final int sort;
  final int skip;
  final int limit;
  final bool senderIdsExclusive;
  final String? searchTag;
  final List<String>? ids;
  final List<String>? senderIds;
  final int? lastMessageTimestamp;
  final List<String>? customType;
  final List<int>? messageType;
  IsmLiveGetMessageModel({
    required this.streamId,
    required this.sort,
    required this.skip,
    required this.limit,
    required this.senderIdsExclusive,
    this.searchTag,
    this.ids,
    this.senderIds,
    this.lastMessageTimestamp,
    this.customType,
    this.messageType,
  });

  IsmLiveGetMessageModel copyWith({
    String? streamId,
    int? sort,
    int? skip,
    int? limit,
    bool? senderIdsExclusive,
    String? searchTag,
    List<String>? ids,
    List<String>? senderIds,
    int? lastMessageTimestamp,
    List<String>? customType,
    List<int>? messageType,
  }) =>
      IsmLiveGetMessageModel(
        streamId: streamId ?? this.streamId,
        sort: sort ?? this.sort,
        skip: skip ?? this.skip,
        limit: limit ?? this.limit,
        senderIdsExclusive: senderIdsExclusive ?? this.senderIdsExclusive,
        searchTag: searchTag ?? this.searchTag,
        ids: ids ?? this.ids,
        senderIds: senderIds ?? this.senderIds,
        lastMessageTimestamp: lastMessageTimestamp ?? this.lastMessageTimestamp,
        customType: customType ?? this.customType,
        messageType: messageType ?? this.messageType,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'streamId': streamId,
        'sort': sort,
        'skip': skip,
        'limit': limit,
        'senderIdsExclusive': senderIdsExclusive,
        if (searchTag != null) 'searchTag': searchTag,
        if (ids != null) 'ids': ids,
        if (senderIds != null) 'senderIds': senderIds,
        if (lastMessageTimestamp != null)
          'lastMessageTimestamp': lastMessageTimestamp,
        if (customType != null) 'customType': customType,
        if (messageType != null) 'messageType': messageType,
      };

  factory IsmLiveGetMessageModel.fromMap(Map<String, dynamic> map) =>
      IsmLiveGetMessageModel(
        streamId: map['streamId'] as String,
        sort: map['sort'] as int,
        skip: map['skip'] as int,
        limit: map['limit'] as int,
        senderIdsExclusive: map['senderIdsExclusive'] as bool,
        searchTag: map['searchTag'] != null ? map['searchTag'] as String : null,
        ids: map['ids'] != null
            ? List<String>.from(map['ids'] as List<String>)
            : null,
        senderIds: map['senderIds'] != null
            ? List<String>.from(map['senderIds'] as List<String>)
            : null,
        lastMessageTimestamp: map['lastMessageTimestamp'] != null
            ? map['lastMessageTimestamp'] as int
            : null,
        customType: map['customType'] != null
            ? List<String>.from(map['customType'] as List<String>)
            : null,
        messageType: map['messageType'] != null
            ? List<int>.from(map['messageType'] as List<int>)
            : null,
      );

  String toJson() => json.encode(toMap());

  factory IsmLiveGetMessageModel.fromJson(String source) =>
      IsmLiveGetMessageModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'IsmLiveGetMessageModel(streamId: $streamId, sort: $sort, skip: $skip, limit: $limit, senderIdsExclusive: $senderIdsExclusive, searchTag: $searchTag, ids: $ids, senderIds: $senderIds, lastMessageTimestamp: $lastMessageTimestamp, customType: $customType, messageType: $messageType)';

  @override
  bool operator ==(covariant IsmLiveGetMessageModel other) {
    if (identical(this, other)) return true;

    return other.streamId == streamId &&
        other.sort == sort &&
        other.skip == skip &&
        other.limit == limit &&
        other.senderIdsExclusive == senderIdsExclusive &&
        other.searchTag == searchTag &&
        listEquals(other.ids, ids) &&
        listEquals(other.senderIds, senderIds) &&
        other.lastMessageTimestamp == lastMessageTimestamp &&
        listEquals(other.customType, customType) &&
        listEquals(other.messageType, messageType);
  }

  @override
  int get hashCode =>
      streamId.hashCode ^
      sort.hashCode ^
      skip.hashCode ^
      limit.hashCode ^
      senderIdsExclusive.hashCode ^
      searchTag.hashCode ^
      ids.hashCode ^
      senderIds.hashCode ^
      lastMessageTimestamp.hashCode ^
      customType.hashCode ^
      messageType.hashCode;
}
