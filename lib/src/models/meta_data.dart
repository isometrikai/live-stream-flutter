import 'dart:convert';

import 'package:flutter/foundation.dart';

class IsmLiveMetaData {
  const IsmLiveMetaData({
    this.country = 'India',
    this.openMeeting = false,
    this.openStream = false,
    this.secretMessage = false,
    this.isPk = false,
    this.profilePic,
    this.firstName,
    this.lastName,
    this.userName,
    this.parentMessageBody,
    /// When `true`, [toMap] returns only a copy of [rawJson] (e.g. batched
    /// likes with a single `likeCounts` key). Default `false` preserves
    /// existing message metadata shape.
    this.emitSparseMeta = false,
    this.rawJson,
  });

  factory IsmLiveMetaData.fromMap(Map<String, dynamic> map) => IsmLiveMetaData(
        country: map['country'] as String? ?? '',
        openMeeting: map['open meeting'] as bool? ?? false,
        profilePic: map['profilePic'] as String?,
        firstName: map['firstName'] as String?,
        lastName: map['lastName'] as String?,
        userName: map['userName'] as String?,
        openStream: map['open stream'] as bool? ?? false,
        secretMessage: map['secretMessage'] as bool? ?? false,
        isPk: map['isPk'] as bool? ?? false,
        parentMessageBody: map['parentMessageBody'] as String?,
        emitSparseMeta: false,
        rawJson: map,
      );

  factory IsmLiveMetaData.fromJson(String source) =>
      IsmLiveMetaData.fromMap(json.decode(source) as Map<String, dynamic>);

  final String country;
  final bool openMeeting;
  final String? profilePic;
  final String? firstName;
  final String? lastName;
  final String? userName;
  final bool openStream;
  final bool secretMessage;
  final bool isPk;
  final String? parentMessageBody;
  final bool emitSparseMeta;
  final Map<String, dynamic>? rawJson;

  IsmLiveMetaData copyWith({
    String? country,
    bool? openMeeting,
    String? profilePic,
    String? firstName,
    String? lastName,
    String? userName,
    bool? openStream,
    bool? secretMessage,
    bool? isPk,
    String? parentMessageBody,
    bool? emitSparseMeta,
    Map<String, dynamic>? rawJson,
  }) =>
      IsmLiveMetaData(
        country: country ?? this.country,
        openMeeting: openMeeting ?? this.openMeeting,
        profilePic: profilePic ?? this.profilePic,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        userName: userName ?? this.userName,
        openStream: openStream ?? this.openStream,
        secretMessage: secretMessage ?? this.secretMessage,
        isPk: isPk ?? this.isPk,
        parentMessageBody: parentMessageBody ?? this.parentMessageBody,
        emitSparseMeta: emitSparseMeta ?? this.emitSparseMeta,
        rawJson: rawJson ?? this.rawJson,
      );

  Map<String, dynamic> toMap() {
    if (emitSparseMeta) {
      if (rawJson == null || rawJson!.isEmpty) {
        return <String, dynamic>{};
      }
      return Map<String, dynamic>.from(rawJson!);
    }
    return <String, dynamic>{
      'country': country,
      'openMeeting': openMeeting,
      'profilePic': profilePic,
      'firstName': firstName,
      'lastName': lastName,
      'userName': userName,
      'openStream': openStream,
      'secretMessage': secretMessage,
      'isPk': isPk,
      'parentMessageBody': parentMessageBody,
      ...?rawJson,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmLiveMetaData(country: $country, openMeeting: $openMeeting, profilePic: $profilePic, firstName: $firstName, lastName: $lastName, userName: $userName, openStream: $openStream, secretMessage: $secretMessage, isPk: $isPk, parentMessageBody: $parentMessageBody, emitSparseMeta: $emitSparseMeta, rawJson: $rawJson)';

  @override
  bool operator ==(covariant IsmLiveMetaData other) {
    if (identical(this, other)) return true;

    return other.country == country &&
        other.openMeeting == openMeeting &&
        other.profilePic == profilePic &&
        other.firstName == firstName &&
        other.lastName == lastName &&
        other.userName == userName &&
        other.openStream == openStream &&
        other.secretMessage == secretMessage &&
        other.isPk == isPk &&
        parentMessageBody == other.parentMessageBody &&
        other.emitSparseMeta == emitSparseMeta &&
        mapEquals(other.rawJson, rawJson);
  }

  @override
  int get hashCode =>
      country.hashCode ^
      openMeeting.hashCode ^
      profilePic.hashCode ^
      firstName.hashCode ^
      lastName.hashCode ^
      userName.hashCode ^
      openStream.hashCode ^
      secretMessage.hashCode ^
      isPk.hashCode ^
      parentMessageBody.hashCode ^
      emitSparseMeta.hashCode ^
      rawJson.hashCode;
}
