import 'dart:convert';

import 'package:appscrip_live_stream_component/src/models/models.dart';
import 'package:flutter/foundation.dart';

class IsmLiveStreamModel {
  const IsmLiveStreamModel({
    this.viewersCount,
    this.streamImage,
    this.streamId,
    this.streamDescription,
    this.startTime,
    this.selfHosted,
    this.searchableTags,
    this.rtmpIngest,
    this.restreamChannelsCount,
    this.restream,
    this.productsLinked,
    this.productsCount,
    this.persistRtmpIngestEndpoint,
    this.multiLive,
    this.moderatorsCount,
    this.metaData,
    this.membersPublishingCount,
    this.membersCount,
    this.lowLatencyMode,
    this.isPublic,
    this.initiatorName,
    this.initiatorImage,
    this.initiatorIdentifier,
    this.hdBroadcast,
    this.featuringProduct,
    this.enableRecording,
    this.customType,
    this.createdBy,
    this.copublishRequestsCount,
    this.canPublish,
    this.audioOnly,
    this.members,
  });

  factory IsmLiveStreamModel.fromMap(Map<String, dynamic> map) => IsmLiveStreamModel(
        viewersCount: map['viewersCount'] as int? ?? 0,
        streamImage: map['streamImage'] as String? ?? '',
        streamId: map['streamId'] as String? ?? '',
        streamDescription: map['streamDescription'] as String? ?? '',
        startTime: DateTime.fromMillisecondsSinceEpoch(
          map['startTime'] as int? ?? map['timestamp'] as int? ?? 0,
        ),
        members: (map['members'] as List? ?? [])
            .map(
              (e) => IsmLiveMemberModel.fromMap(e as Map<String, dynamic>),
            )
            .toList(),
        selfHosted: map['selfHosted'] as bool? ?? false,
        searchableTags: map['searchableTags'] as List? ?? [],
        rtmpIngest: map['rtmpIngest'] as bool? ?? false,
        restreamChannelsCount: map['restreamChannelsCount'] as int? ?? 0,
        restream: map['restream'] as bool? ?? false,
        productsLinked: map['productsLinked'] as bool? ?? false,
        productsCount: map['productsCount'] as int? ?? 0,
        persistRtmpIngestEndpoint: map['persistRtmpIngestEndpoint'] as bool? ?? false,
        multiLive: map['multiLive'] as bool? ?? false,
        moderatorsCount: map['moderatorsCount'] as int? ?? 0,
        metaData: IsmLiveMetaData.fromMap(map['metaData'] as Map<String, dynamic>? ?? {}),
        membersPublishingCount: map['membersPublishingCount'] as int? ?? 0,
        membersCount: map['membersCount'] as int? ?? 0,
        lowLatencyMode: map['lowLatencyMode'] as bool? ?? false,
        isPublic: map['isPublic'] as bool? ?? false,
        initiatorName: map['initiatorName'] as String? ?? '',
        initiatorImage: map['initiatorImage'] as String? ?? '',
        initiatorIdentifier: map['initiatorIdentifier'] as String? ?? '',
        hdBroadcast: map['hdBroadcast'] as bool? ?? false,
        featuringProduct: map['featuringProduct'] as dynamic,
        enableRecording: map['enableRecording'] as bool? ?? false,
        customType: map['customType'] as dynamic,
        createdBy: map['createdBy'] as String? ?? map['initiatorId'] as String? ?? '',
        copublishRequestsCount: map['copublishRequestsCount'] as int? ?? 0,
        canPublish: map['canPublish'] as bool? ?? false,
        audioOnly: map['audioOnly'] as bool? ?? false,
      );

  factory IsmLiveStreamModel.fromJson(String source) => IsmLiveStreamModel.fromMap(json.decode(source) as Map<String, dynamic>);

  final int? viewersCount;
  final String? streamImage;
  final String? streamId;
  final String? streamDescription;
  final DateTime? startTime;
  final bool? selfHosted;
  final List? searchableTags;
  final bool? rtmpIngest;
  final int? restreamChannelsCount;
  final bool? restream;
  final bool? productsLinked;
  final int? productsCount;
  final bool? persistRtmpIngestEndpoint;
  final bool? multiLive;
  final int? moderatorsCount;
  final IsmLiveMetaData? metaData;
  final int? membersPublishingCount;
  final int? membersCount;
  final bool? lowLatencyMode;
  final bool? isPublic;
  final String? initiatorName;
  final String? initiatorImage;
  final String? initiatorIdentifier;
  final bool? hdBroadcast;
  final dynamic featuringProduct;
  final bool? enableRecording;
  final dynamic customType;
  final String? createdBy;
  final int? copublishRequestsCount;
  final bool? canPublish;
  final bool? audioOnly;
  final List<IsmLiveMemberModel>? members;

  IsmLiveStreamModel copyWith({
    int? viewersCount,
    String? streamImage,
    String? streamId,
    String? streamDescription,
    DateTime? startTime,
    bool? selfHosted,
    List? searchableTags,
    bool? rtmpIngest,
    int? restreamChannelsCount,
    bool? restream,
    bool? productsLinked,
    int? productsCount,
    bool? persistRtmpIngestEndpoint,
    bool? multiLive,
    int? moderatorsCount,
    IsmLiveMetaData? metaData,
    int? membersPublishingCount,
    int? membersCount,
    bool? lowLatencyMode,
    bool? isPublic,
    String? initiatorName,
    String? initiatorImage,
    String? initiatorIdentifier,
    bool? hdBroadcast,
    dynamic featuringProduct,
    bool? enableRecording,
    dynamic customType,
    String? createdBy,
    int? copublishRequestsCount,
    bool? canPublish,
    bool? audioOnly,
  }) =>
      IsmLiveStreamModel(
        viewersCount: viewersCount ?? this.viewersCount,
        streamImage: streamImage ?? this.streamImage,
        streamId: streamId ?? this.streamId,
        streamDescription: streamDescription ?? this.streamDescription,
        startTime: startTime ?? this.startTime,
        selfHosted: selfHosted ?? this.selfHosted,
        searchableTags: searchableTags ?? this.searchableTags,
        rtmpIngest: rtmpIngest ?? this.rtmpIngest,
        restreamChannelsCount: restreamChannelsCount ?? this.restreamChannelsCount,
        restream: restream ?? this.restream,
        productsLinked: productsLinked ?? this.productsLinked,
        productsCount: productsCount ?? this.productsCount,
        persistRtmpIngestEndpoint: persistRtmpIngestEndpoint ?? this.persistRtmpIngestEndpoint,
        multiLive: multiLive ?? this.multiLive,
        moderatorsCount: moderatorsCount ?? this.moderatorsCount,
        metaData: metaData ?? this.metaData,
        membersPublishingCount: membersPublishingCount ?? this.membersPublishingCount,
        membersCount: membersCount ?? this.membersCount,
        lowLatencyMode: lowLatencyMode ?? this.lowLatencyMode,
        isPublic: isPublic ?? this.isPublic,
        initiatorName: initiatorName ?? this.initiatorName,
        initiatorImage: initiatorImage ?? this.initiatorImage,
        initiatorIdentifier: initiatorIdentifier ?? this.initiatorIdentifier,
        hdBroadcast: hdBroadcast ?? this.hdBroadcast,
        featuringProduct: featuringProduct ?? this.featuringProduct,
        enableRecording: enableRecording ?? this.enableRecording,
        customType: customType ?? this.customType,
        createdBy: createdBy ?? this.createdBy,
        copublishRequestsCount: copublishRequestsCount ?? this.copublishRequestsCount,
        canPublish: canPublish ?? this.canPublish,
        audioOnly: audioOnly ?? this.audioOnly,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'viewersCount': viewersCount,
        'streamImage': streamImage,
        'streamId': streamId,
        'streamDescription': streamDescription,
        'startTime': startTime?.millisecondsSinceEpoch,
        'selfHosted': selfHosted,
        'searchableTags': searchableTags,
        'rtmpIngest': rtmpIngest,
        'restreamChannelsCount': restreamChannelsCount,
        'restream': restream,
        'productsLinked': productsLinked,
        'productsCount': productsCount,
        'persistRtmpIngestEndpoint': persistRtmpIngestEndpoint,
        'multiLive': multiLive,
        'moderatorsCount': moderatorsCount,
        'metaData': metaData?.toMap(),
        'membersPublishingCount': membersPublishingCount,
        'membersCount': membersCount,
        'lowLatencyMode': lowLatencyMode,
        'isPublic': isPublic,
        'initiatorName': initiatorName,
        'initiatorImage': initiatorImage,
        'initiatorIdentifier': initiatorIdentifier,
        'hdBroadcast': hdBroadcast,
        'featuringProduct': featuringProduct,
        'enableRecording': enableRecording,
        'customType': customType,
        'createdBy': createdBy,
        'copublishRequestsCount': copublishRequestsCount,
        'canPublish': canPublish,
        'audioOnly': audioOnly,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'StreamModel(viewersCount: $viewersCount, streamImage: $streamImage, streamId: $streamId, streamDescription: $streamDescription, startTime: $startTime, selfHosted: $selfHosted, searchableTags: $searchableTags, rtmpIngest: $rtmpIngest, restreamChannelsCount: $restreamChannelsCount, restream: $restream, productsLinked: $productsLinked, productsCount: $productsCount, persistRtmpIngestEndpoint: $persistRtmpIngestEndpoint, multiLive: $multiLive, moderatorsCount: $moderatorsCount, metaData: $metaData, membersPublishingCount: $membersPublishingCount, membersCount: $membersCount, lowLatencyMode: $lowLatencyMode, isPublic: $isPublic, initiatorName: $initiatorName, initiatorImage: $initiatorImage, initiatorIdentifier: $initiatorIdentifier, hdBroadcast: $hdBroadcast, featuringProduct: $featuringProduct, enableRecording: $enableRecording, customType: $customType, createdBy: $createdBy, copublishRequestsCount: $copublishRequestsCount, canPublish: $canPublish, audioOnly: $audioOnly)';

  @override
  bool operator ==(covariant IsmLiveStreamModel other) {
    if (identical(this, other)) return true;

    return other.viewersCount == viewersCount &&
        other.streamImage == streamImage &&
        other.streamId == streamId &&
        other.streamDescription == streamDescription &&
        other.startTime == startTime &&
        other.selfHosted == selfHosted &&
        listEquals(other.searchableTags, searchableTags) &&
        other.rtmpIngest == rtmpIngest &&
        other.restreamChannelsCount == restreamChannelsCount &&
        other.restream == restream &&
        other.productsLinked == productsLinked &&
        other.productsCount == productsCount &&
        other.persistRtmpIngestEndpoint == persistRtmpIngestEndpoint &&
        other.multiLive == multiLive &&
        other.moderatorsCount == moderatorsCount &&
        other.metaData == metaData &&
        other.membersPublishingCount == membersPublishingCount &&
        other.membersCount == membersCount &&
        other.lowLatencyMode == lowLatencyMode &&
        other.isPublic == isPublic &&
        other.initiatorName == initiatorName &&
        other.initiatorImage == initiatorImage &&
        other.initiatorIdentifier == initiatorIdentifier &&
        other.hdBroadcast == hdBroadcast &&
        other.featuringProduct == featuringProduct &&
        other.enableRecording == enableRecording &&
        other.customType == customType &&
        other.createdBy == createdBy &&
        other.copublishRequestsCount == copublishRequestsCount &&
        other.canPublish == canPublish &&
        other.audioOnly == audioOnly;
  }

  @override
  int get hashCode =>
      viewersCount.hashCode ^
      streamImage.hashCode ^
      streamId.hashCode ^
      streamDescription.hashCode ^
      startTime.hashCode ^
      selfHosted.hashCode ^
      searchableTags.hashCode ^
      rtmpIngest.hashCode ^
      restreamChannelsCount.hashCode ^
      restream.hashCode ^
      productsLinked.hashCode ^
      productsCount.hashCode ^
      persistRtmpIngestEndpoint.hashCode ^
      multiLive.hashCode ^
      moderatorsCount.hashCode ^
      metaData.hashCode ^
      membersPublishingCount.hashCode ^
      membersCount.hashCode ^
      lowLatencyMode.hashCode ^
      isPublic.hashCode ^
      initiatorName.hashCode ^
      initiatorImage.hashCode ^
      initiatorIdentifier.hashCode ^
      hdBroadcast.hashCode ^
      featuringProduct.hashCode ^
      enableRecording.hashCode ^
      customType.hashCode ^
      createdBy.hashCode ^
      copublishRequestsCount.hashCode ^
      canPublish.hashCode ^
      audioOnly.hashCode;
}
