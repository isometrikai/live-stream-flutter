import 'dart:convert';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/foundation.dart';

class IsmLivePkInvitationModel {
  IsmLivePkInvitationModel({
    this.userProfileImageUrl,
    this.userName,
    this.userMetaData,
    this.userIdentifier,
    this.userId,
    this.sentAt,
    this.searchableTags,
    this.metaData,
    this.messageType,
    this.messageId,
    this.deviceId,
    this.customType,
    this.body,
    this.action,
  });

  factory IsmLivePkInvitationModel.fromMap(Map<String, dynamic> map) =>
      IsmLivePkInvitationModel(
        userProfileImageUrl: map['userProfileImageUrl'] != null
            ? map['userProfileImageUrl'] as String
            : null,
        userName: map['userName'] != null ? map['userName'] as String : null,
        userMetaData: map['userMetaData'] != null
            ? IsmLiveMetaData.fromMap(
                map['userMetaData'] as Map<String, dynamic>)
            : null,
        userIdentifier: map['userIdentifier'] != null
            ? map['userIdentifier'] as String
            : null,
        userId: map['userId'] != null ? map['userId'] as String : null,
        sentAt: map['sentAt'] != null ? map['sentAt'] as int : null,
        searchableTags: map['searchableTags'] != null
            ? List<dynamic>.from(map['searchableTags'] as List<dynamic>)
            : null,
        metaData: map['metaData'] != null
            ? IsmLivePkMetaData.fromMap(map['metaData'] as Map<String, dynamic>)
            : null,
        messageType:
            map['messageType'] != null ? map['messageType'] as int : null,
        messageId: map['messageId'] != null ? map['messageId'] as String : null,
        deviceId: map['deviceId'] != null ? map['deviceId'] as String : null,
        customType:
            map['customType'] != null ? map['customType'] as String : null,
        body: map['body'] != null ? map['body'] as String : null,
        action: map['action'] != null ? map['action'] as String : null,
      );

  factory IsmLivePkInvitationModel.fromJson(String source) =>
      IsmLivePkInvitationModel.fromMap(
          json.decode(source) as Map<String, dynamic>);
  final String? userProfileImageUrl;
  final String? userName;
  final IsmLiveMetaData? userMetaData;
  final String? userIdentifier;
  final String? userId;
  final int? sentAt;
  final List<dynamic>? searchableTags;
  final IsmLivePkMetaData? metaData;
  final int? messageType;
  final String? messageId;
  final String? deviceId;
  final String? customType;
  final String? body;
  final String? action;

  IsmLivePkInvitationModel copyWith({
    String? userProfileImageUrl,
    String? userName,
    IsmLiveMetaData? userMetaData,
    String? userIdentifier,
    String? userId,
    int? sentAt,
    List<dynamic>? searchableTags,
    IsmLivePkMetaData? metaData,
    int? messageType,
    String? messageId,
    String? deviceId,
    String? customType,
    String? body,
    String? action,
  }) =>
      IsmLivePkInvitationModel(
        userProfileImageUrl: userProfileImageUrl ?? this.userProfileImageUrl,
        userName: userName ?? this.userName,
        userMetaData: userMetaData ?? this.userMetaData,
        userIdentifier: userIdentifier ?? this.userIdentifier,
        userId: userId ?? this.userId,
        sentAt: sentAt ?? this.sentAt,
        searchableTags: searchableTags ?? this.searchableTags,
        metaData: metaData ?? this.metaData,
        messageType: messageType ?? this.messageType,
        messageId: messageId ?? this.messageId,
        deviceId: deviceId ?? this.deviceId,
        customType: customType ?? this.customType,
        body: body ?? this.body,
        action: action ?? this.action,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'userProfileImageUrl': userProfileImageUrl,
        'userName': userName,
        'userMetaData': userMetaData?.toMap(),
        'userIdentifier': userIdentifier,
        'userId': userId,
        'sentAt': sentAt,
        'searchableTags': searchableTags,
        'metaData': metaData?.toMap(),
        'messageType': messageType,
        'messageId': messageId,
        'deviceId': deviceId,
        'customType': customType,
        'body': body,
        'action': action,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmLivePkInvitationModel(userProfileImageUrl: $userProfileImageUrl, userName: $userName, userMetaData: $userMetaData, userIdentifier: $userIdentifier, userId: $userId, sentAt: $sentAt, searchableTags: $searchableTags, metaData: $metaData, messageType: $messageType, messageId: $messageId, deviceId: $deviceId, customType: $customType, body: $body, action: $action)';

  @override
  bool operator ==(covariant IsmLivePkInvitationModel other) {
    if (identical(this, other)) return true;

    return other.userProfileImageUrl == userProfileImageUrl &&
        other.userName == userName &&
        other.userMetaData == userMetaData &&
        other.userIdentifier == userIdentifier &&
        other.userId == userId &&
        other.sentAt == sentAt &&
        listEquals(other.searchableTags, searchableTags) &&
        other.metaData == metaData &&
        other.messageType == messageType &&
        other.messageId == messageId &&
        other.deviceId == deviceId &&
        other.customType == customType &&
        other.body == body &&
        other.action == action;
  }

  @override
  int get hashCode =>
      userProfileImageUrl.hashCode ^
      userName.hashCode ^
      userMetaData.hashCode ^
      userIdentifier.hashCode ^
      userId.hashCode ^
      sentAt.hashCode ^
      searchableTags.hashCode ^
      metaData.hashCode ^
      messageType.hashCode ^
      messageId.hashCode ^
      deviceId.hashCode ^
      customType.hashCode ^
      body.hashCode ^
      action.hashCode;
}

class IsmLivePkMetaData {
  IsmLivePkMetaData({
    this.userName,
    this.status,
    this.userMetaData,
    this.userId,
    this.streamId,
    this.profilepic,
    this.lastName,
    this.isStar,
    this.inviteId,
    this.firstName,
  });

  factory IsmLivePkMetaData.fromMap(Map<String, dynamic> map) =>
      IsmLivePkMetaData(
        userName: map['userName'] != null ? map['userName'] as String : null,
        userMetaData:
            map['userMetaData'] != null ? map['userMetaData'] as String : null,
        userId: map['userId'] != null ? map['userId'] as String : null,
        streamId: map['streamId'] != null ? map['streamId'] as String : null,
        profilepic:
            map['profilepic'] != null ? map['profilepic'] as String : null,
        lastName: map['lastName'] != null ? map['lastName'] as String : null,
        status: map['status'] != null ? map['status'] as String : null,
        isStar: map['isStar'] != null ? map['isStar'] as bool : null,
        inviteId: map['inviteId'] != null ? map['inviteId'] as String : null,
        firstName: map['firstName'] != null ? map['firstName'] as String : null,
      );

  factory IsmLivePkMetaData.fromJson(String source) =>
      IsmLivePkMetaData.fromMap(json.decode(source) as Map<String, dynamic>);
  final String? userName;
  final String? userMetaData;
  final String? userId;
  final String? streamId;
  final String? profilepic;
  final String? lastName;
  final String? status;
  final bool? isStar;
  final String? inviteId;
  final String? firstName;

  IsmLivePkMetaData copyWith({
    String? userName,
    String? userMetaData,
    String? userId,
    String? streamId,
    String? profilepic,
    String? lastName,
    String? status,
    bool? isStar,
    String? inviteId,
    String? firstName,
  }) =>
      IsmLivePkMetaData(
        userName: userName ?? this.userName,
        userMetaData: userMetaData ?? this.userMetaData,
        userId: userId ?? this.userId,
        streamId: streamId ?? this.streamId,
        profilepic: profilepic ?? this.profilepic,
        lastName: lastName ?? this.lastName,
        status: lastName ?? this.status,
        isStar: isStar ?? this.isStar,
        inviteId: inviteId ?? this.inviteId,
        firstName: firstName ?? this.firstName,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'userName': userName,
        'userMetaData': userMetaData,
        'userId': userId,
        'streamId': streamId,
        'profilepic': profilepic,
        'lastName': lastName,
        'status': status,
        'isStar': isStar,
        'inviteId': inviteId,
        'firstName': firstName,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmLivePkMetaData(userName: $userName, userMetaData: $userMetaData, userId: $userId, streamId: $streamId, profilepic: $profilepic, lastName: $lastName, status: $status, isStar: $isStar, inviteId: $inviteId, firstName: $firstName)';

  @override
  bool operator ==(covariant IsmLivePkMetaData other) {
    if (identical(this, other)) return true;

    return other.userName == userName &&
        other.userMetaData == userMetaData &&
        other.userId == userId &&
        other.streamId == streamId &&
        other.profilepic == profilepic &&
        other.lastName == lastName &&
        other.status == status &&
        other.isStar == isStar &&
        other.inviteId == inviteId &&
        other.firstName == firstName;
  }

  @override
  int get hashCode =>
      userName.hashCode ^
      userMetaData.hashCode ^
      userId.hashCode ^
      streamId.hashCode ^
      profilepic.hashCode ^
      lastName.hashCode ^
      status.hashCode ^
      isStar.hashCode ^
      inviteId.hashCode ^
      firstName.hashCode;
}
