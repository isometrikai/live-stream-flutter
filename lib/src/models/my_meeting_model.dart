import 'dart:convert';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/foundation.dart';

class MyMeetingModel {
  MyMeetingModel({
    required this.selfHosted,
    required this.searchableTags,
    required this.metaData,
    required this.membersPublishingCount,
    required this.membersCount,
    required this.meetingType,
    required this.meetingImageUrl,
    required this.meetingId,
    required this.meetingDescription,
    required this.initiatorName,
    required this.initiatorImageUrl,
    required this.initiatorIdentifier,
    required this.hdMeeting,
    required this.enableRecording,
    required this.customType,
    required this.creationTime,
    required this.createdBy,
    required this.conversationId,
    required this.config,
    required this.autoTerminate,
    required this.audioOnly,
    required this.adminCount,
    required this.privateOneToOne,
  });

  factory MyMeetingModel.fromMap(Map<String, dynamic> map) => MyMeetingModel(
        selfHosted: map['selfHosted'] as bool,
        searchableTags: List.from(map['searchableTags']),
        metaData:
            IsmLiveMetaData.fromMap(map['metaData'] as Map<String, dynamic>),
        membersPublishingCount: map['membersPublishingCount'] as int,
        membersCount: map['membersCount'] as int,
        meetingType: IsmLiveMeetingType.fromValue(map['meetingType'] as int),
        meetingImageUrl: map['meetingImageUrl'] as String,
        meetingId: map['meetingId'] as String,
        meetingDescription: map['meetingDescription'] as String,
        initiatorName: map['initiatorName'] as String,
        initiatorImageUrl: map['initiatorImageUrl'] as String,
        initiatorIdentifier: map['initiatorIdentifier'] as String,
        hdMeeting: map['hdMeeting'] as bool,
        enableRecording: map['enableRecording'] as bool,
        customType: map['customType'] as String,
        creationTime: map['creationTime'] as int,
        createdBy: map['createdBy'] as String,
        conversationId: map['conversationId'] as String? ?? '',
        config:
            IsmLiveMeetingConfig.fromMap(map['config'] as Map<String, dynamic>),
        autoTerminate: map['autoTerminate'] as bool,
        audioOnly: map['audioOnly'] as bool,
        adminCount: map['adminCount'] as int,
        privateOneToOne: map['privateOneToOne'] as dynamic,
      );

  factory MyMeetingModel.fromJson(String source) =>
      MyMeetingModel.fromMap(json.decode(source) as Map<String, dynamic>);
  final bool selfHosted;
  final List searchableTags;
  final IsmLiveMetaData metaData;
  final int membersPublishingCount;
  final int membersCount;
  final IsmLiveMeetingType meetingType;
  final String meetingImageUrl;
  final String meetingId;
  final String meetingDescription;
  final String initiatorName;
  final String initiatorImageUrl;
  final String initiatorIdentifier;
  final bool hdMeeting;
  final bool enableRecording;
  final String customType;
  final int creationTime;
  final String createdBy;
  final String conversationId;
  final IsmLiveMeetingConfig config;
  final bool autoTerminate;
  final bool audioOnly;
  final int adminCount;
  final dynamic privateOneToOne;

  MyMeetingModel copyWith({
    bool? selfHosted,
    List? searchableTags,
    IsmLiveMetaData? metaData,
    int? membersPublishingCount,
    int? membersCount,
    IsmLiveMeetingType? meetingType,
    String? meetingImageUrl,
    String? meetingId,
    String? meetingDescription,
    String? initiatorName,
    String? initiatorImageUrl,
    String? initiatorIdentifier,
    bool? hdMeeting,
    bool? enableRecording,
    String? customType,
    int? creationTime,
    String? createdBy,
    String? conversationId,
    IsmLiveMeetingConfig? config,
    bool? autoTerminate,
    bool? audioOnly,
    int? adminCount,
    dynamic privateOneToOne,
  }) =>
      MyMeetingModel(
        selfHosted: selfHosted ?? this.selfHosted,
        searchableTags: searchableTags ?? this.searchableTags,
        metaData: metaData ?? this.metaData,
        membersPublishingCount:
            membersPublishingCount ?? this.membersPublishingCount,
        membersCount: membersCount ?? this.membersCount,
        meetingType: meetingType ?? this.meetingType,
        meetingImageUrl: meetingImageUrl ?? this.meetingImageUrl,
        meetingId: meetingId ?? this.meetingId,
        meetingDescription: meetingDescription ?? this.meetingDescription,
        initiatorName: initiatorName ?? this.initiatorName,
        initiatorImageUrl: initiatorImageUrl ?? this.initiatorImageUrl,
        initiatorIdentifier: initiatorIdentifier ?? this.initiatorIdentifier,
        hdMeeting: hdMeeting ?? this.hdMeeting,
        enableRecording: enableRecording ?? this.enableRecording,
        customType: customType ?? this.customType,
        creationTime: creationTime ?? this.creationTime,
        createdBy: createdBy ?? this.createdBy,
        conversationId: conversationId ?? this.conversationId,
        config: config ?? this.config,
        autoTerminate: autoTerminate ?? this.autoTerminate,
        audioOnly: audioOnly ?? this.audioOnly,
        adminCount: adminCount ?? this.adminCount,
        privateOneToOne: privateOneToOne ?? this.privateOneToOne,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'selfHosted': selfHosted,
        'searchableTags': searchableTags,
        'metaData': metaData.toMap(),
        'membersPublishingCount': membersPublishingCount,
        'membersCount': membersCount,
        'meetingType': meetingType,
        'meetingImageUrl': meetingImageUrl,
        'meetingId': meetingId,
        'meetingDescription': meetingDescription,
        'initiatorName': initiatorName,
        'initiatorImageUrl': initiatorImageUrl,
        'initiatorIdentifier': initiatorIdentifier,
        'hdMeeting': hdMeeting,
        'enableRecording': enableRecording,
        'customType': customType,
        'creationTime': creationTime,
        'createdBy': createdBy,
        'conversationId': conversationId,
        'config': config.toMap(),
        'autoTerminate': autoTerminate,
        'audioOnly': audioOnly,
        'adminCount': adminCount,
        'privateOneToOne': privateOneToOne,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'MyMeetingModel(selfHosted: $selfHosted, searchableTags: $searchableTags, metaData: $metaData, membersPublishingCount: $membersPublishingCount, membersCount: $membersCount, meetingType: $meetingType, meetingImageUrl: $meetingImageUrl, meetingId: $meetingId, meetingDescription: $meetingDescription, initiatorName: $initiatorName, initiatorImageUrl: $initiatorImageUrl, initiatorIdentifier: $initiatorIdentifier, hdMeeting: $hdMeeting, enableRecording: $enableRecording, customType: $customType, creationTime: $creationTime, createdBy: $createdBy, conversationId: $conversationId, config: $config, autoTerminate: $autoTerminate, audioOnly: $audioOnly, adminCount: $adminCount, privateOneToOne: $privateOneToOne)';

  @override
  bool operator ==(covariant MyMeetingModel other) {
    if (identical(this, other)) return true;

    return other.selfHosted == selfHosted &&
        listEquals(other.searchableTags, searchableTags) &&
        other.metaData == metaData &&
        other.membersPublishingCount == membersPublishingCount &&
        other.membersCount == membersCount &&
        other.meetingType == meetingType &&
        other.meetingImageUrl == meetingImageUrl &&
        other.meetingId == meetingId &&
        other.meetingDescription == meetingDescription &&
        other.initiatorName == initiatorName &&
        other.initiatorImageUrl == initiatorImageUrl &&
        other.initiatorIdentifier == initiatorIdentifier &&
        other.hdMeeting == hdMeeting &&
        other.enableRecording == enableRecording &&
        other.customType == customType &&
        other.creationTime == creationTime &&
        other.createdBy == createdBy &&
        other.conversationId == conversationId &&
        other.config == config &&
        other.autoTerminate == autoTerminate &&
        other.audioOnly == audioOnly &&
        other.adminCount == adminCount &&
        other.privateOneToOne == privateOneToOne;
  }

  @override
  int get hashCode =>
      selfHosted.hashCode ^
      searchableTags.hashCode ^
      metaData.hashCode ^
      membersPublishingCount.hashCode ^
      membersCount.hashCode ^
      meetingType.hashCode ^
      meetingImageUrl.hashCode ^
      meetingId.hashCode ^
      meetingDescription.hashCode ^
      initiatorName.hashCode ^
      initiatorImageUrl.hashCode ^
      initiatorIdentifier.hashCode ^
      hdMeeting.hashCode ^
      enableRecording.hashCode ^
      customType.hashCode ^
      creationTime.hashCode ^
      createdBy.hashCode ^
      conversationId.hashCode ^
      config.hashCode ^
      autoTerminate.hashCode ^
      audioOnly.hashCode ^
      adminCount.hashCode ^
      privateOneToOne.hashCode;
}
