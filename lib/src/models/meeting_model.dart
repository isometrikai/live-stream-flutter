import 'dart:convert';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/foundation.dart';

class MeetingModel {
  const MeetingModel({
    required this.selfHosted,
    required this.pushNotifications,
    required this.metaData,
    required this.members,
    required this.meetingImageUrl,
    required this.meetingDescription,
    required this.hdMeeting,
    required this.enableRecording,
    required this.deviceId,
    required this.customType,
    required this.meetingType,
    required this.autoTerminate,
    required this.audioOnly,
  });

  factory MeetingModel.fromMap(Map<String, dynamic> map) => MeetingModel(
        selfHosted: map['selfHosted'] as bool,
        pushNotifications: map['pushNotifications'] as bool,
        metaData: IsmLiveMetaData.fromMap(map['metaData'] as Map<String, dynamic>),
        members: List<String>.from(map['members'] as List<dynamic>),
        meetingImageUrl: map['meetingImageUrl'] as String,
        meetingDescription: map['meetingDescription'] as String,
        hdMeeting: map['hdMeeting'] as bool,
        enableRecording: map['enableRecording'] as bool,
        deviceId: map['deviceId'] as String,
        customType: IsmLiveCallType.fromValue(map['customType'] as String),
        meetingType: IsmLiveMeetingType.fromValue(map['meetingType'] as int),
        autoTerminate: map['autoTerminate'] as bool,
        audioOnly: map['audioOnly'] as bool,
      );

  factory MeetingModel.fromJson(String source) => MeetingModel.fromMap(json.decode(source) as Map<String, dynamic>);

  final bool selfHosted;
  final bool pushNotifications;
  final IsmLiveMetaData metaData;
  final List<String> members;
  final String meetingImageUrl;
  final String meetingDescription;
  final bool hdMeeting;
  final bool enableRecording;
  final String deviceId;
  final IsmLiveCallType customType;
  final IsmLiveMeetingType meetingType;
  final bool autoTerminate;
  final bool audioOnly;

  MeetingModel copyWith({
    bool? selfHosted,
    bool? pushNotifications,
    IsmLiveMetaData? metaData,
    List<String>? members,
    String? meetingImageUrl,
    String? meetingDescription,
    bool? hdMeeting,
    bool? enableRecording,
    String? deviceId,
    IsmLiveCallType? customType,
    IsmLiveMeetingType? meetingType,
    bool? autoTerminate,
    bool? audioOnly,
  }) =>
      MeetingModel(
        selfHosted: selfHosted ?? this.selfHosted,
        pushNotifications: pushNotifications ?? this.pushNotifications,
        metaData: metaData ?? this.metaData,
        members: members ?? this.members,
        meetingImageUrl: meetingImageUrl ?? this.meetingImageUrl,
        meetingDescription: meetingDescription ?? this.meetingDescription,
        hdMeeting: hdMeeting ?? this.hdMeeting,
        enableRecording: enableRecording ?? this.enableRecording,
        deviceId: deviceId ?? this.deviceId,
        customType: customType ?? this.customType,
        meetingType: meetingType ?? this.meetingType,
        autoTerminate: autoTerminate ?? this.autoTerminate,
        audioOnly: audioOnly ?? this.audioOnly,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'selfHosted': selfHosted,
        'pushNotifications': pushNotifications,
        'metaData': metaData.toMap(),
        'members': members,
        'meetingImageUrl': meetingImageUrl,
        'meetingDescription': meetingDescription,
        'hdMeeting': hdMeeting,
        'enableRecording': enableRecording,
        'deviceId': deviceId,
        'customType': customType.value,
        'meetingType': meetingType.value,
        'autoTerminate': autoTerminate,
        'audioOnly': audioOnly,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'MeetingModel(selfHosted: $selfHosted, pushNotifications: $pushNotifications, metaData: $metaData, members: $members, meetingImageUrl: $meetingImageUrl, meetingDescription: $meetingDescription, hdMeeting: $hdMeeting, enableRecording: $enableRecording, deviceId: $deviceId, customType: $customType, meetingType: $meetingType, autoTerminate: $autoTerminate, audioOnly: $audioOnly)';

  @override
  bool operator ==(covariant MeetingModel other) {
    if (identical(this, other)) return true;

    return other.selfHosted == selfHosted &&
        other.pushNotifications == pushNotifications &&
        other.metaData == metaData &&
        listEquals(other.members, members) &&
        other.meetingImageUrl == meetingImageUrl &&
        other.meetingDescription == meetingDescription &&
        other.hdMeeting == hdMeeting &&
        other.enableRecording == enableRecording &&
        other.deviceId == deviceId &&
        other.customType == customType &&
        other.meetingType == meetingType &&
        other.autoTerminate == autoTerminate &&
        other.audioOnly == audioOnly;
  }

  @override
  int get hashCode =>
      selfHosted.hashCode ^
      pushNotifications.hashCode ^
      metaData.hashCode ^
      members.hashCode ^
      meetingImageUrl.hashCode ^
      meetingDescription.hashCode ^
      hdMeeting.hashCode ^
      enableRecording.hashCode ^
      deviceId.hashCode ^
      customType.hashCode ^
      meetingType.hashCode ^
      autoTerminate.hashCode ^
      audioOnly.hashCode;
}
