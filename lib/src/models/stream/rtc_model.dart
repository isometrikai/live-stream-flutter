import 'dart:convert';

class IsmLiveRTCModel {
  const IsmLiveRTCModel({
    required this.uid,
    this.streamKey,
    this.streamId,
    this.startTime,
    required this.rtcToken,
    this.playbackUrl,
    this.numberOfViewers,
    this.isModerator,
    this.restreamEndpoints,
    this.ingestEndpoint,
  });

  factory IsmLiveRTCModel.fromMap(Map<String, dynamic> map) => IsmLiveRTCModel(
        uid: map['uid'] as int? ?? 0,
        streamKey: map['streamKey'] as String?,
        streamId: map['streamId'] as String?,
        startTime: map['startTime'] != null
            ? DateTime.fromMillisecondsSinceEpoch(map['startTime'] as int)
            : null,
        rtcToken: map['rtcToken'] as String? ?? '',
        playbackUrl: map['playbackUrl'] as String?,
        numberOfViewers: map['numberOfViewers'] as int?,
        isModerator: map['isModerator'] as bool?,
        restreamEndpoints:
            (map['restreamEndpoints'] as List<dynamic>?)?.cast<String>(),
        ingestEndpoint: map['ingestEndpoint'] as String?,
      );

  factory IsmLiveRTCModel.fromJson(String source) =>
      IsmLiveRTCModel.fromMap(json.decode(source) as Map<String, dynamic>);

  final int uid;
  final String? streamKey;
  final String? streamId;
  final DateTime? startTime;
  final String rtcToken;
  final String? playbackUrl;
  final int? numberOfViewers;
  final bool? isModerator;
  final List<String>? restreamEndpoints;
  final String? ingestEndpoint;

  IsmLiveRTCModel copyWith({
    int? uid,
    String? streamKey,
    String? streamId,
    DateTime? startTime,
    String? rtcToken,
    String? playbackUrl,
    int? numberOfViewers,
    bool? isModerator,
    String? ingestEndpoint,
  }) =>
      IsmLiveRTCModel(
        uid: uid ?? this.uid,
        streamKey: streamKey ?? this.streamKey,
        streamId: streamId ?? this.streamId,
        startTime: startTime ?? this.startTime,
        rtcToken: rtcToken ?? this.rtcToken,
        playbackUrl: playbackUrl ?? this.playbackUrl,
        numberOfViewers: numberOfViewers ?? this.numberOfViewers,
        isModerator: isModerator ?? this.isModerator,
        ingestEndpoint: ingestEndpoint ?? this.ingestEndpoint,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'uid': uid,
        'streamKey': streamKey,
        'streamId': streamId,
        'startTime': startTime,
        'rtcToken': rtcToken,
        'playbackUrl': playbackUrl,
        'numberOfViewers': numberOfViewers,
        'isModerator': isModerator,
        'ingestEndpoint': ingestEndpoint,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmLiveRTCModel(uid: $uid, streamKey: $streamKey, streamId: $streamId, startTime: $startTime, rtcToken: $rtcToken, playbackUrl: $playbackUrl, numberOfViewers: $numberOfViewers, isModerator: $isModerator, ingestEndpoint: $ingestEndpoint)';

  @override
  bool operator ==(covariant IsmLiveRTCModel other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.streamKey == streamKey &&
        other.streamId == streamId &&
        other.startTime == startTime &&
        other.rtcToken == rtcToken &&
        other.playbackUrl == playbackUrl &&
        other.numberOfViewers == numberOfViewers &&
        other.isModerator == isModerator &&
        other.ingestEndpoint == ingestEndpoint;
  }

  @override
  int get hashCode =>
      uid.hashCode ^
      streamKey.hashCode ^
      streamId.hashCode ^
      startTime.hashCode ^
      rtcToken.hashCode ^
      playbackUrl.hashCode ^
      numberOfViewers.hashCode ^
      isModerator.hashCode ^
      ingestEndpoint.hashCode;
}
