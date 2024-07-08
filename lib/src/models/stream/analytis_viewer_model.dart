// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/foundation.dart';

class IsmLiveAnalyticViewerModel {
  final String? isometrikUserId;
  final String? appUserId;
  final String? firstName;
  final IsmLiveMetaData? userMetaData;
  final String? lastName;
  final num? timestamp;
  final String? profilePic;
  final String? userName;
  final List<IsmLiveStatusLogs>? statusLogs;
  IsmLiveAnalyticViewerModel({
    this.isometrikUserId,
    this.appUserId,
    this.firstName,
    this.userMetaData,
    this.lastName,
    this.timestamp,
    this.profilePic,
    this.userName,
    this.statusLogs,
  });

  IsmLiveAnalyticViewerModel copyWith({
    String? isometrikUserId,
    String? appUserId,
    String? firstName,
    IsmLiveMetaData? userMetaData,
    String? lastName,
    num? timestamp,
    String? profilePic,
    String? userName,
    List<IsmLiveStatusLogs>? statusLogs,
  }) =>
      IsmLiveAnalyticViewerModel(
        isometrikUserId: isometrikUserId ?? this.isometrikUserId,
        appUserId: appUserId ?? this.appUserId,
        firstName: firstName ?? this.firstName,
        userMetaData: userMetaData ?? this.userMetaData,
        lastName: lastName ?? this.lastName,
        timestamp: timestamp ?? this.timestamp,
        profilePic: profilePic ?? this.profilePic,
        userName: userName ?? this.userName,
        statusLogs: statusLogs ?? this.statusLogs,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'isometrikUserId': isometrikUserId,
        'appUserId': appUserId,
        'firstName': firstName,
        'userMetaData': userMetaData?.toMap(),
        'lastName': lastName,
        'timestamp': timestamp,
        'profilePic': profilePic,
        'userName': userName,
        'statusLogs': statusLogs?.map((x) => x.toMap()).toList(),
      };

  factory IsmLiveAnalyticViewerModel.fromMap(Map<String, dynamic> map) =>
      IsmLiveAnalyticViewerModel(
        isometrikUserId: map['isometrikUserId'] != null
            ? map['isometrikUserId'] as String
            : null,
        appUserId: map['appUserId'] != null ? map['appUserId'] as String : null,
        firstName: map['firstName'] != null ? map['firstName'] as String : null,
        userMetaData: map['userMetaData'] != null
            ? IsmLiveMetaData.fromMap(
                map['userMetaData'] as Map<String, dynamic>)
            : null,
        lastName: map['lastName'] != null ? map['lastName'] as String : null,
        timestamp: map['timestamp'] != null ? map['timestamp'] as num : null,
        profilePic:
            map['profilePic'] != null ? map['profilePic'] as String : null,
        userName: map['userName'] != null ? map['userName'] as String : null,
        statusLogs: map['statusLogs'] != null
            ? List<IsmLiveStatusLogs>.from(
                (map['statusLogs'] as List<dynamic>).map<IsmLiveStatusLogs?>(
                  (x) => IsmLiveStatusLogs.fromMap(x as Map<String, dynamic>),
                ),
              )
            : null,
      );

  String toJson() => json.encode(toMap());

  factory IsmLiveAnalyticViewerModel.fromJson(String source) =>
      IsmLiveAnalyticViewerModel.fromMap(
          json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'IsmLiveAnalyticViewerModel(isometrikUserId: $isometrikUserId, appUserId: $appUserId, firstName: $firstName, userMetaData: $userMetaData, lastName: $lastName, timestamp: $timestamp, profilePic: $profilePic, userName: $userName, statusLogs: $statusLogs)';

  @override
  bool operator ==(covariant IsmLiveAnalyticViewerModel other) {
    if (identical(this, other)) return true;

    return other.isometrikUserId == isometrikUserId &&
        other.appUserId == appUserId &&
        other.firstName == firstName &&
        other.userMetaData == userMetaData &&
        other.lastName == lastName &&
        other.timestamp == timestamp &&
        other.profilePic == profilePic &&
        other.userName == userName &&
        listEquals(other.statusLogs, statusLogs);
  }

  @override
  int get hashCode =>
      isometrikUserId.hashCode ^
      appUserId.hashCode ^
      firstName.hashCode ^
      userMetaData.hashCode ^
      lastName.hashCode ^
      timestamp.hashCode ^
      profilePic.hashCode ^
      userName.hashCode ^
      statusLogs.hashCode;
}

class IsmLiveStatusLogs {
  final int? timestamp;
  final String? status;
  IsmLiveStatusLogs({
    this.timestamp,
    this.status,
  });

  IsmLiveStatusLogs copyWith({
    int? timestamp,
    String? status,
  }) =>
      IsmLiveStatusLogs(
        timestamp: timestamp ?? this.timestamp,
        status: status ?? this.status,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'timestamp': timestamp,
        'status': status,
      };

  factory IsmLiveStatusLogs.fromMap(Map<String, dynamic> map) =>
      IsmLiveStatusLogs(
        timestamp: map['timestamp'] != null ? map['timestamp'] as int : null,
        status: map['status'] != null ? map['status'] as String : null,
      );

  String toJson() => json.encode(toMap());

  factory IsmLiveStatusLogs.fromJson(String source) =>
      IsmLiveStatusLogs.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'IsmLiveStatusLogs(timestamp: $timestamp, status: $status)';

  @override
  bool operator ==(covariant IsmLiveStatusLogs other) {
    if (identical(this, other)) return true;

    return other.timestamp == timestamp && other.status == status;
  }

  @override
  int get hashCode => timestamp.hashCode ^ status.hashCode;
}
