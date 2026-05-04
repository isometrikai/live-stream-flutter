import 'dart:convert';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';

class IsmLiveViewerModel {
  IsmLiveViewerModel({
    this.imageUrl,
    required this.userName,
    required this.identifier,
    required this.userId,
    this.startTime,
    this.metaData,
    required this.messageNotificationEmail,
    this.emailNotifications,
    this.clubEmailNotifications,
  });

  factory IsmLiveViewerModel.fromMap(Map<String, dynamic> map) =>
      IsmLiveViewerModel(
        imageUrl: map['userProfileImageUrl'] as String? ??
            map['userProfilePic'] as String? ??
            map['viewerProfilePic'] as String?,
        userName: map['userName'] as String? ??
            map['viewerName'] as String? ??
            map['memberName'] as String? ??
            '',
        identifier: map['userIdentifier'] as String? ??
            map['viewerIdentifier'] as String? ??
            map['memberIdentifier'] as String? ??
            '',
        userId: map['userId'] as String? ??
            map['viewerId'] as String? ??
            map['memberId'] as String? ??
            '',
        startTime: map['sessionStartTime'] as int? ?? map['timestamp'] as int?,
        metaData: map['metaData'] != null
            ? IsmLiveMetaData.fromMap(map['metaData'] as Map<String, dynamic>)
            : null,
        messageNotificationEmail: map['messageNotificationEmail'] as dynamic,
        emailNotifications: map['emailNotifications'] as bool?,
        clubEmailNotifications: map['clubEmailNotifications'] as bool?,
      );

  factory IsmLiveViewerModel.fromJson(String source) =>
      IsmLiveViewerModel.fromMap(json.decode(source) as Map<String, dynamic>);

  final String? imageUrl;
  final String userName;
  final String identifier;
  final String userId;
  final int? startTime;
  final IsmLiveMetaData? metaData;
  final dynamic messageNotificationEmail;
  final bool? emailNotifications;
  final bool? clubEmailNotifications;

  /// Display full name: metadata first/last name when either is non-empty,
  /// otherwise root `userName` (legacy API shape).
  String get fullName {
    final first = metaData?.firstName?.trim() ?? '';
    final last = metaData?.lastName?.trim() ?? '';
    if (first.isNotEmpty || last.isNotEmpty) {
      return [first, last].where((s) => s.isNotEmpty).join(' ');
    }
    return userName;
  }

  /// Login / handle for UI: metadata `userName` when set, otherwise root `userName`.
  String get displayUserName {
    final meta = metaData?.userName?.trim() ?? '';
    if (meta.isNotEmpty) return meta;
    return userName;
  }

  /// Same as [fullName]. Kept for call sites that use a single display name.
  String get name => fullName;

  /// Two-letter uppercase initials: [fullName] then [displayUserName].
  String get profileInitials => IsmLiveInitials.fromNames(
        primary: fullName,
        secondary: displayUserName,
      );
  String? get profile => metaData?.profilePic ?? imageUrl;

  IsmLiveViewerModel copyWith({
    String? imageUrl,
    String? userName,
    String? identifier,
    String? userId,
    int? startTime,
    IsmLiveMetaData? metaData,
    dynamic messageNotificationEmail,
    bool? emailNotifications,
    bool? clubEmailNotifications,
  }) =>
      IsmLiveViewerModel(
        imageUrl: imageUrl ?? this.imageUrl,
        userName: userName ?? this.userName,
        identifier: identifier ?? this.identifier,
        userId: userId ?? this.userId,
        startTime: startTime ?? this.startTime,
        metaData: metaData ?? this.metaData,
        messageNotificationEmail:
            messageNotificationEmail ?? this.messageNotificationEmail,
        emailNotifications: emailNotifications ?? this.emailNotifications,
        clubEmailNotifications:
            clubEmailNotifications ?? this.clubEmailNotifications,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'userProfileImageUrl': imageUrl,
        'userName': userName,
        'userIdentifier': identifier,
        'userId': userId,
        'sessionStartTime': startTime,
        'metaData': metaData?.toMap(),
        'messageNotificationEmail': messageNotificationEmail,
        'emailNotifications': emailNotifications,
        'clubEmailNotifications': clubEmailNotifications,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmLiveViewerModel(userProfileImageUrl: $imageUrl, userName: $userName, userIdentifier: $identifier, userId: $userId, sessionStartTime: $startTime, metaData: $metaData, messageNotificationEmail: $messageNotificationEmail, emailNotifications: $emailNotifications, clubEmailNotifications: $clubEmailNotifications)';

  @override
  bool operator ==(covariant IsmLiveViewerModel other) {
    if (identical(this, other)) return true;

    return other.userId == userId;
  }

  @override
  int get hashCode => userId.hashCode;
}
