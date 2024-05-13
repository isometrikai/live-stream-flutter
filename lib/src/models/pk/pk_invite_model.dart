import 'dart:convert';

import 'package:appscrip_live_stream_component/src/models/models.dart';

class IsmLivePkInviteModel {
  IsmLivePkInviteModel({
    required this.streamId,
    required this.isometrikUserId,
    this.firstName,
    this.userMetaData,
    this.lastName,
    this.userName,
    required this.userId,
    required this.viewerCount,
    required this.streamPic,
    this.profilePic,
  });

  factory IsmLivePkInviteModel.fromMap(Map<String, dynamic> map) =>
      IsmLivePkInviteModel(
        streamId: map['streamId'] as String,
        isometrikUserId: map['isometrikUserId'] as String,
        firstName: map['firstName'] != null ? map['firstName'] as String : null,
        userMetaData: map['userMetaData'] != null
            ? IsmLiveMetaData.fromMap(
                map['userMetaData'] as Map<String, dynamic>)
            : null,
        lastName: map['lastName'] != null ? map['lastName'] as String : null,
        userName: map['userName'] != null ? map['userName'] as String : null,
        userId: map['userId'] as String,
        viewerCount: map['viewerCount'] as int,
        streamPic: map['streamPic'] as String,
        profilePic:
            map['profilePic'] != null ? map['profilePic'] as String : null,
      );

  factory IsmLivePkInviteModel.fromJson(String source) =>
      IsmLivePkInviteModel.fromMap(json.decode(source) as Map<String, dynamic>);
  final String streamId;
  final String isometrikUserId;
  final String? firstName;
  final IsmLiveMetaData? userMetaData;
  final String? lastName;
  final String? userName;
  final String userId;
  final int viewerCount;
  final String streamPic;
  final String? profilePic;

  IsmLivePkInviteModel copyWith({
    String? streamId,
    String? isometrikUserId,
    String? firstName,
    IsmLiveMetaData? userMetaData,
    String? lastName,
    String? userName,
    String? userId,
    int? viewerCount,
    String? streamPic,
    String? profilePic,
  }) =>
      IsmLivePkInviteModel(
        streamId: streamId ?? this.streamId,
        isometrikUserId: isometrikUserId ?? this.isometrikUserId,
        firstName: firstName ?? this.firstName,
        userMetaData: userMetaData ?? this.userMetaData,
        lastName: lastName ?? this.lastName,
        userName: userName ?? this.userName,
        userId: userId ?? this.userId,
        viewerCount: viewerCount ?? this.viewerCount,
        streamPic: streamPic ?? this.streamPic,
        profilePic: profilePic ?? this.profilePic,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'streamId': streamId,
        'isometrikUserId': isometrikUserId,
        'firstName': firstName,
        'userMetaData': userMetaData?.toMap(),
        'lastName': lastName,
        'userName': userName,
        'userId': userId,
        'viewerCount': viewerCount,
        'streamPic': streamPic,
        'profilePic': profilePic,
      };

  String get name {
    if (userMetaData?.firstName?.isNotEmpty ?? false) {
      return '${userMetaData?.firstName} ${userMetaData?.lastName ?? ''}';
    }
    return userName ?? '';
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmLivePkInviteModel(streamId: $streamId, isometrikUserId: $isometrikUserId, firstName: $firstName, userMetaData: $userMetaData, lastName: $lastName, userName: $userName, userId: $userId, viewerCount: $viewerCount, streamPic: $streamPic, profilePic: $profilePic)';

  @override
  bool operator ==(covariant IsmLivePkInviteModel other) {
    if (identical(this, other)) return true;

    return other.streamId == streamId &&
        other.isometrikUserId == isometrikUserId &&
        other.firstName == firstName &&
        other.userMetaData == userMetaData &&
        other.lastName == lastName &&
        other.userName == userName &&
        other.userId == userId &&
        other.viewerCount == viewerCount &&
        other.streamPic == streamPic &&
        other.profilePic == profilePic;
  }

  @override
  int get hashCode =>
      streamId.hashCode ^
      isometrikUserId.hashCode ^
      firstName.hashCode ^
      userMetaData.hashCode ^
      lastName.hashCode ^
      userName.hashCode ^
      userId.hashCode ^
      viewerCount.hashCode ^
      streamPic.hashCode ^
      profilePic.hashCode;
}
