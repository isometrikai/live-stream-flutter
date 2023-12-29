// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';

class IsmLiveMemberDetailsModel {
  final String userProfileImageUrl;
  final String userName;
  final String userIdentifier;
  final String userId;
  final IsmLiveMetaData metaData;
  final num joinTime;
  final bool isPublishing;
  final bool isAdmin;
  IsmLiveMemberDetailsModel({
    required this.userProfileImageUrl,
    required this.userName,
    required this.userIdentifier,
    required this.userId,
    required this.metaData,
    required this.joinTime,
    required this.isPublishing,
    required this.isAdmin,
  });

  IsmLiveMemberDetailsModel copyWith({
    String? userProfileImageUrl,
    String? userName,
    String? userIdentifier,
    String? userId,
    IsmLiveMetaData? metaData,
    num? joinTime,
    bool? isPublishing,
    bool? isAdmin,
  }) =>
      IsmLiveMemberDetailsModel(
        userProfileImageUrl: userProfileImageUrl ?? this.userProfileImageUrl,
        userName: userName ?? this.userName,
        userIdentifier: userIdentifier ?? this.userIdentifier,
        userId: userId ?? this.userId,
        metaData: metaData ?? this.metaData,
        joinTime: joinTime ?? this.joinTime,
        isPublishing: isPublishing ?? this.isPublishing,
        isAdmin: isAdmin ?? this.isAdmin,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'userProfileImageUrl': userProfileImageUrl,
        'userName': userName,
        'userIdentifier': userIdentifier,
        'userId': userId,
        'metaData': metaData,
        'joinTime': joinTime,
        'isPublishing': isPublishing,
        'isAdmin': isAdmin,
      };

  factory IsmLiveMemberDetailsModel.fromMap(Map<String, dynamic> map) =>
      IsmLiveMemberDetailsModel(
        userProfileImageUrl: map['userProfileImageUrl'] as String,
        userName: map['userName'] as String,
        userIdentifier: map['userIdentifier'] as String,
        userId: map['userId'] as String,
        metaData:
            IsmLiveMetaData.fromMap(map['metaData'] as Map<String, dynamic>),
        joinTime: map['joinTime'] as num,
        isPublishing: map['isPublishing'] as bool,
        isAdmin: map['isAdmin'] as bool,
      );

  String toJson() => json.encode(toMap());

  factory IsmLiveMemberDetailsModel.fromJson(String source) =>
      IsmLiveMemberDetailsModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'MembersDetailsResponce(userProfileImageUrl: $userProfileImageUrl, userName: $userName, userIdentifier: $userIdentifier, userId: $userId, metaData: $metaData, joinTime: $joinTime, isPublishing: $isPublishing, isAdmin: $isAdmin)';

  @override
  bool operator ==(covariant IsmLiveMemberDetailsModel other) {
    if (identical(this, other)) return true;

    return other.userProfileImageUrl == userProfileImageUrl &&
        other.userName == userName &&
        other.userIdentifier == userIdentifier &&
        other.userId == userId &&
        other.metaData == metaData &&
        other.joinTime == joinTime &&
        other.isPublishing == isPublishing &&
        other.isAdmin == isAdmin;
  }

  @override
  int get hashCode =>
      userProfileImageUrl.hashCode ^
      userName.hashCode ^
      userIdentifier.hashCode ^
      userId.hashCode ^
      metaData.hashCode ^
      joinTime.hashCode ^
      isPublishing.hashCode ^
      isAdmin.hashCode;
}
