import 'dart:convert';

import 'package:appscrip_live_stream_component/src/models/meta_data.dart';

class UserDetails {
  factory UserDetails.fromJson(String source) =>
      UserDetails.fromMap(json.decode(source) as Map<String, dynamic>);

  factory UserDetails.fromMap(Map<String, dynamic> map) => UserDetails(
        userProfileImageUrl: map['userProfileImageUrl'] as String? ?? '',
        userName: map['userName'] as String? ?? '',
        userIdentifier: map['userIdentifier'] as String? ?? '',
        userId: map['userId'] as String? ?? '',
        metaData: map['metaData'] == null
            ? const IsmLiveMetaData()
            : IsmLiveMetaData.fromMap(map['metaData'] as Map<String, dynamic>),
        createdAt: map['createdAt'] as int? ?? 0,
        notification:
            map['notification'] != null ? map['notification'] as bool : false,
        isAdmin: map['isAdmin'] != null ? map['isAdmin'] as bool : false,
      );

  UserDetails({
    required this.userProfileImageUrl,
    required this.userName,
    required this.userIdentifier,
    required this.userId,
    this.metaData,
    this.notification,
    this.isAdmin,
    this.createdAt,
  });

  final String userProfileImageUrl;
  final String userName;
  final String userIdentifier;
  final String userId;
  final IsmLiveMetaData? metaData;
  final bool? notification;
  final bool? isAdmin;
  final int? createdAt;

  String get profileUrl => metaData?.profilePic ?? userProfileImageUrl;

  UserDetails copyWith({
    String? userProfileImageUrl,
    String? userName,
    String? userIdentifier,
    String? userId,
    IsmLiveMetaData? metaData,
    bool? notification,
    bool? isAdmin,
  }) =>
      UserDetails(
        userProfileImageUrl: userProfileImageUrl ?? this.userProfileImageUrl,
        userName: userName ?? this.userName,
        userIdentifier: userIdentifier ?? this.userIdentifier,
        userId: userId ?? this.userId,
        metaData: metaData ?? this.metaData,
        notification: notification ?? this.notification,
        isAdmin: isAdmin ?? this.isAdmin,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'userProfileImageUrl': userProfileImageUrl,
        'userName': userName,
        'userIdentifier': userIdentifier,
        'userId': userId,
        'metaData': metaData?.toMap(),
        'notification': notification,
        'isAdmin': isAdmin,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'UserDetails(userProfileImageUrl: $userProfileImageUrl, userName: $userName, userIdentifier: $userIdentifier, userId: $userId,notification: $notification,isAdmin: $isAdmin,metaData : $metaData)';

  @override
  bool operator ==(covariant UserDetails other) {
    if (identical(this, other)) return true;

    return other.userProfileImageUrl == userProfileImageUrl &&
        other.userName == userName &&
        other.userIdentifier == userIdentifier &&
        other.userId == userId &&
        other.metaData == metaData &&
        other.isAdmin == isAdmin &&
        other.notification == notification;
  }

  @override
  int get hashCode =>
      userProfileImageUrl.hashCode ^
      userName.hashCode ^
      userIdentifier.hashCode ^
      userId.hashCode ^
      metaData.hashCode ^
      isAdmin.hashCode ^
      notification.hashCode;
}
