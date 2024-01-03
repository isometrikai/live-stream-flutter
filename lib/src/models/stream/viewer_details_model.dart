import 'dart:convert';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';

class IsmLiveViewerModel {
  IsmLiveViewerModel({
    this.userProfileImageUrl,
    required this.userName,
    required this.userIdentifier,
    required this.userId,
    this.sessionStartTime,
    this.metaData,
    required this.messageNotificationEmail,
    this.emailNotifications,
    this.clubEmailNotifications,
  });

  factory IsmLiveViewerModel.fromMap(Map<String, dynamic> map) => IsmLiveViewerModel(
        userProfileImageUrl: map['userProfileImageUrl'] != null ? map['userProfileImageUrl'] as String : null,
        userName: map['userName'] as String,
        userIdentifier: map['userIdentifier'] as String,
        userId: map['userId'] as String,
        sessionStartTime: map['sessionStartTime'] != null ? map['sessionStartTime'] as int : null,
        metaData: map['metaData'] != null ? IsmLiveMetaData.fromMap(map['metaData'] as Map<String, dynamic>) : null,
        messageNotificationEmail: map['messageNotificationEmail'] as dynamic,
        emailNotifications: map['emailNotifications'] != null ? map['emailNotifications'] as bool : null,
        clubEmailNotifications: map['clubEmailNotifications'] != null ? map['clubEmailNotifications'] as bool : null,
      );

  factory IsmLiveViewerModel.fromJson(String source) => IsmLiveViewerModel.fromMap(json.decode(source) as Map<String, dynamic>);

  final String? userProfileImageUrl;
  final String userName;
  final String userIdentifier;
  final String userId;
  final int? sessionStartTime;
  final IsmLiveMetaData? metaData;
  final dynamic messageNotificationEmail;
  final bool? emailNotifications;
  final bool? clubEmailNotifications;

  IsmLiveViewerModel copyWith({
    String? userProfileImageUrl,
    String? userName,
    String? userIdentifier,
    String? userId,
    int? sessionStartTime,
    IsmLiveMetaData? metaData,
    dynamic messageNotificationEmail,
    bool? emailNotifications,
    bool? clubEmailNotifications,
  }) =>
      IsmLiveViewerModel(
        userProfileImageUrl: userProfileImageUrl ?? this.userProfileImageUrl,
        userName: userName ?? this.userName,
        userIdentifier: userIdentifier ?? this.userIdentifier,
        userId: userId ?? this.userId,
        sessionStartTime: sessionStartTime ?? this.sessionStartTime,
        metaData: metaData ?? this.metaData,
        messageNotificationEmail: messageNotificationEmail ?? this.messageNotificationEmail,
        emailNotifications: emailNotifications ?? this.emailNotifications,
        clubEmailNotifications: clubEmailNotifications ?? this.clubEmailNotifications,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'userProfileImageUrl': userProfileImageUrl,
        'userName': userName,
        'userIdentifier': userIdentifier,
        'userId': userId,
        'sessionStartTime': sessionStartTime,
        'metaData': metaData?.toMap(),
        'messageNotificationEmail': messageNotificationEmail,
        'emailNotifications': emailNotifications,
        'clubEmailNotifications': clubEmailNotifications,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmLiveViewerModel(userProfileImageUrl: $userProfileImageUrl, userName: $userName, userIdentifier: $userIdentifier, userId: $userId, sessionStartTime: $sessionStartTime, metaData: $metaData, messageNotificationEmail: $messageNotificationEmail, emailNotifications: $emailNotifications, clubEmailNotifications: $clubEmailNotifications)';

  @override
  bool operator ==(covariant IsmLiveViewerModel other) {
    if (identical(this, other)) return true;

    return other.userProfileImageUrl == userProfileImageUrl &&
        other.userName == userName &&
        other.userIdentifier == userIdentifier &&
        other.userId == userId &&
        other.sessionStartTime == sessionStartTime &&
        other.metaData == metaData &&
        other.messageNotificationEmail == messageNotificationEmail &&
        other.emailNotifications == emailNotifications &&
        other.clubEmailNotifications == clubEmailNotifications;
  }

  @override
  int get hashCode =>
      userProfileImageUrl.hashCode ^
      userName.hashCode ^
      userIdentifier.hashCode ^
      userId.hashCode ^
      sessionStartTime.hashCode ^
      metaData.hashCode ^
      messageNotificationEmail.hashCode ^
      emailNotifications.hashCode ^
      clubEmailNotifications.hashCode;
}
