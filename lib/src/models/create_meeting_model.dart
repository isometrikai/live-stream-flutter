// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class CreateMeetingModel {
  final num uid;
  final String rtcToken;
  final String msg;
  final String meetingId;
  final num creationTime;
  CreateMeetingModel({
    required this.uid,
    required this.rtcToken,
    required this.msg,
    required this.meetingId,
    required this.creationTime,
  });

  CreateMeetingModel copyWith({
    num? uid,
    String? rtcToken,
    String? msg,
    String? meetingId,
    num? creationTime,
  }) =>
      CreateMeetingModel(
        uid: uid ?? this.uid,
        rtcToken: rtcToken ?? this.rtcToken,
        msg: msg ?? this.msg,
        meetingId: meetingId ?? this.meetingId,
        creationTime: creationTime ?? this.creationTime,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'uid': uid,
        'rtcToken': rtcToken,
        'msg': msg,
        'meetingId': meetingId,
        'creationTime': creationTime,
      };

  factory CreateMeetingModel.fromMap(Map<String, dynamic> map) =>
      CreateMeetingModel(
        uid: map['uid'] as num,
        rtcToken: map['rtcToken'] as String,
        msg: map['msg'] as String,
        meetingId: map['meetingId'] as String,
        creationTime: map['creationTime'] as num,
      );

  String toJson() => json.encode(toMap());

  factory CreateMeetingModel.fromJson(String source) =>
      CreateMeetingModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'CreateMeetingModel(uid: $uid, rtcToken: $rtcToken, msg: $msg, meetingId: $meetingId, creationTime: $creationTime)';

  @override
  bool operator ==(covariant CreateMeetingModel other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.rtcToken == rtcToken &&
        other.msg == msg &&
        other.meetingId == meetingId &&
        other.creationTime == creationTime;
  }

  @override
  int get hashCode =>
      uid.hashCode ^
      rtcToken.hashCode ^
      msg.hashCode ^
      meetingId.hashCode ^
      creationTime.hashCode;
}
