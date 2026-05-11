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

  /// Display full name: metadata first/last when either is non-empty,
  /// otherwise root [firstName]/[lastName], otherwise [userName].
  String get fullName {
    final mf = userMetaData?.firstName?.trim() ?? '';
    final ml = userMetaData?.lastName?.trim() ?? '';
    if (mf.isNotEmpty || ml.isNotEmpty) {
      return [mf, ml].where((s) => s.isNotEmpty).join(' ');
    }
    final rf = firstName?.trim() ?? '';
    final rl = lastName?.trim() ?? '';
    if (rf.isNotEmpty || rl.isNotEmpty) {
      return [rf, rl].where((s) => s.isNotEmpty).join(' ');
    }
    return userName ?? '';
  }

  /// Login / handle for UI: metadata `userName` when set, otherwise root [userName].
  String get displayUserName {
    final meta = userMetaData?.userName?.trim() ?? '';
    if (meta.isNotEmpty) return meta;
    return userName ?? '';
  }

  /// Same as [fullName]. Kept for call sites that use a single display name.
  String get name => fullName;

  /// Two-letter uppercase initials: [fullName] then [displayUserName].
  String get profileInitials => IsmLiveInitials.fromNames(
        primary: fullName,
        secondary: displayUserName,
      );

  /// Profile image URL: metadata first, then root [profilePic].
  String? get displayProfilePic => userMetaData?.profilePic ?? profilePic;

  factory IsmLiveAnalyticViewerModel.fromMap(Map<String, dynamic> map) {
    final rawMeta = map['userMetaData'] ?? map['metaData'];
    IsmLiveMetaData? userMetaData;
    if (rawMeta != null && rawMeta is Map) {
      userMetaData =
          IsmLiveMetaData.fromMap(Map<String, dynamic>.from(rawMeta));
    }

    String? preferMetaString(String? meta, dynamic root) {
      final fromMeta = meta?.trim();
      if (fromMeta != null && fromMeta.isNotEmpty) return fromMeta;
      return root != null ? root as String? : null;
    }

    return IsmLiveAnalyticViewerModel(
        isometrikUserId: map['isometrikUserId'] != null
            ? map['isometrikUserId'] as String
            : null,
        appUserId: map['appUserId'] != null ? map['appUserId'] as String : null,
        firstName:
            preferMetaString(userMetaData?.firstName, map['firstName']),
        userMetaData: userMetaData,
        lastName: preferMetaString(userMetaData?.lastName, map['lastName']),
        timestamp: map['timestamp'] != null ? map['timestamp'] as num : null,
        profilePic: userMetaData?.profilePic ??
            (map['profilePic'] != null ? map['profilePic'] as String : null),
        userName: preferMetaString(userMetaData?.userName, map['userName']),
        statusLogs: map['statusLogs'] != null
            ? List<IsmLiveStatusLogs>.from(
                (map['statusLogs'] as List<dynamic>).map<IsmLiveStatusLogs?>(
                  (x) => IsmLiveStatusLogs.fromMap(x as Map<String, dynamic>),
                ),
              )
            : null,
      );
  }

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
