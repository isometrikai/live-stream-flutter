import 'dart:convert';

import 'package:flutter/foundation.dart';

class IsmLiveGetMessageModel {
  const IsmLiveGetMessageModel({
    required this.streamId,
    this.sort,
    this.skip,
    this.limit,
    this.senderIdsExclusive,
    this.searchTag,
    this.ids,
    this.senderIds,
    this.lastMessageTimestamp,
    this.customType,
    this.messageType,
  });

  factory IsmLiveGetMessageModel.fromMap(Map<String, dynamic> map) =>
      IsmLiveGetMessageModel(
        streamId: map['streamId'] as String,
        sort: map['sort'] as int,
        skip: map['skip'] as int,
        limit: map['limit'] as int,
        senderIdsExclusive: map['senderIdsExclusive'] as bool,
        searchTag: map['searchTag'] as String?,
        ids: (map['ids'] as List<dynamic>? ?? []).cast<String>(),
        senderIds: (map['senderIds'] as List<dynamic>? ?? []).cast<String>(),
        lastMessageTimestamp: map['lastMessageTimestamp'] as int?,
        customType: (map['customType'] as List<dynamic>? ?? []).cast<String>(),
        messageType: (map['messageType'] as List<dynamic>? ?? []).cast<int>(),
      );

  factory IsmLiveGetMessageModel.fromJson(String source) =>
      IsmLiveGetMessageModel.fromMap(
          json.decode(source) as Map<String, dynamic>);
  final String streamId;
  final int? sort;
  final int? skip;
  final int? limit;
  final bool? senderIdsExclusive;
  final String? searchTag;
  final List<String>? ids;
  final List<String>? senderIds;
  final int? lastMessageTimestamp;
  final List<String>? customType;
  final List<int>? messageType;

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
        'searchTag': searchTag,
        'ids': ids,
        'senderIds': senderIds,
        'lastMessageTimestamp': lastMessageTimestamp,
        'customType': customType,
        'messageType': messageType,
      };

  String toJson() => json.encode(toMap());

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
