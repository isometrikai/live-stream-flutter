import 'dart:convert';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';

class IsmLivePkStatusModel {
  IsmLivePkStatusModel({
    this.streamId,
    this.pkId,
    this.firstUserId,
    this.secoundUserId,
    this.firstUserDetails,
    this.secondUserDetails,
    this.firstUserCoins,
    this.secondUserCoins,
    this.creationTimestamp,
    this.timeRemain,
    this.percentageOfCoinsFirstUser,
    this.percentageOfCoinsSecondUser,
    this.battleTimeInMin,
    this.expireTimestamp,
  });

  factory IsmLivePkStatusModel.fromMap(Map<String, dynamic> map) =>
      IsmLivePkStatusModel(
        streamId: map['streamId'] != null ? map['streamId'] as String : null,
        pkId: map['pkId'] != null ? map['pkId'] as String : null,
        firstUserId:
            map['firstUserId'] != null ? map['firstUserId'] as String : null,
        secoundUserId: map['secoundUserId'] != null
            ? map['secoundUserId'] as String
            : null,
        firstUserDetails: map['firstUserDetails'] != null
            ? IsmLivePkUserDetails.fromMap(
                map['firstUserDetails'] as Map<String, dynamic>)
            : null,
        secondUserDetails: map['secondUserDetails'] != null
            ? IsmLivePkUserDetails.fromMap(
                map['secondUserDetails'] as Map<String, dynamic>)
            : null,
        firstUserCoins:
            map['firstUserCoins'] != null ? map['firstUserCoins'] as num : null,
        secondUserCoins: map['secondUserCoins'] != null
            ? map['secondUserCoins'] as num
            : null,
        creationTimestamp: map['creationTimestamp'] != null
            ? map['creationTimestamp'] as int
            : null,
        timeRemain: map['timeRemain'] != null ? map['timeRemain'] as int : null,
        percentageOfCoinsFirstUser: map['percentageOfCoinsFirstUser'] != null
            ? map['percentageOfCoinsFirstUser'] as num
            : null,
        percentageOfCoinsSecondUser: map['percentageOfCoinsSecondUser'] != null
            ? map['percentageOfCoinsSecondUser'] as num
            : null,
        battleTimeInMin: map['battleTimeInMin'] != null
            ? map['battleTimeInMin'] as int
            : null,
        expireTimestamp: map['expireTimestamp'] != null
            ? map['expireTimestamp'] as int
            : null,
      );

  factory IsmLivePkStatusModel.fromJson(String source) =>
      IsmLivePkStatusModel.fromMap(json.decode(source) as Map<String, dynamic>);
  final String? streamId;
  final String? pkId;
  final String? firstUserId;
  final String? secoundUserId;
  final IsmLivePkUserDetails? firstUserDetails;
  final IsmLivePkUserDetails? secondUserDetails;
  final num? firstUserCoins;
  final num? secondUserCoins;
  final int? creationTimestamp;
  final int? timeRemain;
  final num? percentageOfCoinsFirstUser;
  final num? percentageOfCoinsSecondUser;
  final int? battleTimeInMin;
  final int? expireTimestamp;

  IsmLivePkStatusModel copyWith({
    String? streamId,
    String? pkId,
    String? firstUserId,
    String? secoundUserId,
    IsmLivePkUserDetails? firstUserDetails,
    IsmLivePkUserDetails? secondUserDetails,
    num? firstUserCoins,
    num? secondUserCoins,
    int? creationTimestamp,
    int? timeRemain,
    num? percentageOfCoinsFirstUser,
    num? percentageOfCoinsSecondUser,
    int? battleTimeInMin,
    int? expireTimestamp,
  }) =>
      IsmLivePkStatusModel(
        streamId: streamId ?? this.streamId,
        pkId: pkId ?? this.pkId,
        firstUserId: firstUserId ?? this.firstUserId,
        secoundUserId: secoundUserId ?? this.secoundUserId,
        firstUserDetails: firstUserDetails ?? this.firstUserDetails,
        secondUserDetails: secondUserDetails ?? this.secondUserDetails,
        firstUserCoins: firstUserCoins ?? this.firstUserCoins,
        secondUserCoins: secondUserCoins ?? this.secondUserCoins,
        creationTimestamp: creationTimestamp ?? this.creationTimestamp,
        timeRemain: timeRemain ?? this.timeRemain,
        percentageOfCoinsFirstUser:
            percentageOfCoinsFirstUser ?? this.percentageOfCoinsFirstUser,
        percentageOfCoinsSecondUser:
            percentageOfCoinsSecondUser ?? this.percentageOfCoinsSecondUser,
        battleTimeInMin: battleTimeInMin ?? this.battleTimeInMin,
        expireTimestamp: expireTimestamp ?? this.expireTimestamp,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'streamId': streamId,
        'pkId': pkId,
        'firstUserId': firstUserId,
        'secoundUserId': secoundUserId,
        'firstUserDetails': firstUserDetails?.toMap(),
        'secondUserDetails': secondUserDetails?.toMap(),
        'firstUserCoins': firstUserCoins,
        'secondUserCoins': secondUserCoins,
        'creationTimestamp': creationTimestamp,
        'timeRemain': timeRemain,
        'percentageOfCoinsFirstUser': percentageOfCoinsFirstUser,
        'percentageOfCoinsSecondUser': percentageOfCoinsSecondUser,
        'battleTimeInMin': battleTimeInMin,
        'expireTimestamp': expireTimestamp,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmLivePkStatusModel(streamId: $streamId, pkId: $pkId, firstUserId: $firstUserId, secoundUserId: $secoundUserId, firstUserDetails: $firstUserDetails, secondUserDetails: $secondUserDetails, firstUserCoins: $firstUserCoins, secondUserCoins: $secondUserCoins, creationTimestamp: $creationTimestamp, timeRemain: $timeRemain, percentageOfCoinsFirstUser: $percentageOfCoinsFirstUser, percentageOfCoinsSecondUser: $percentageOfCoinsSecondUser, battleTimeInMin: $battleTimeInMin, expireTimestamp: $expireTimestamp)';

  @override
  bool operator ==(covariant IsmLivePkStatusModel other) {
    if (identical(this, other)) return true;

    return other.streamId == streamId &&
        other.pkId == pkId &&
        other.firstUserId == firstUserId &&
        other.secoundUserId == secoundUserId &&
        other.firstUserDetails == firstUserDetails &&
        other.secondUserDetails == secondUserDetails &&
        other.firstUserCoins == firstUserCoins &&
        other.secondUserCoins == secondUserCoins &&
        other.creationTimestamp == creationTimestamp &&
        other.timeRemain == timeRemain &&
        other.percentageOfCoinsFirstUser == percentageOfCoinsFirstUser &&
        other.percentageOfCoinsSecondUser == percentageOfCoinsSecondUser &&
        other.battleTimeInMin == battleTimeInMin &&
        other.expireTimestamp == expireTimestamp;
  }

  @override
  int get hashCode =>
      streamId.hashCode ^
      pkId.hashCode ^
      firstUserId.hashCode ^
      secoundUserId.hashCode ^
      firstUserDetails.hashCode ^
      secondUserDetails.hashCode ^
      firstUserCoins.hashCode ^
      secondUserCoins.hashCode ^
      creationTimestamp.hashCode ^
      timeRemain.hashCode ^
      percentageOfCoinsFirstUser.hashCode ^
      percentageOfCoinsSecondUser.hashCode ^
      battleTimeInMin.hashCode ^
      expireTimestamp.hashCode;
}
