import 'dart:convert';

class IsmLiveRTCModel {
  const IsmLiveRTCModel({
    required this.uid,
    required this.rtcToken,
    this.playbackUrl,
    required this.numberOfViewers,
    required this.isModerator,
  });

  factory IsmLiveRTCModel.fromMap(Map<String, dynamic> map) => IsmLiveRTCModel(
        uid: map['uid'] as int? ?? 0,
        rtcToken: map['rtcToken'] as String? ?? '',
        playbackUrl: map['playbackUrl'] as String?,
        numberOfViewers: map['numberOfViewers'] as int? ?? 0,
        isModerator: map['isModerator'] as bool? ?? false,
      );

  factory IsmLiveRTCModel.fromJson(String source) => IsmLiveRTCModel.fromMap(json.decode(source) as Map<String, dynamic>);

  final int uid;
  final String rtcToken;
  final String? playbackUrl;
  final int numberOfViewers;
  final bool isModerator;

  IsmLiveRTCModel copyWith({
    int? uid,
    String? rtcToken,
    String? playbackUrl,
    int? numberOfViewers,
    bool? isModerator,
  }) =>
      IsmLiveRTCModel(
        uid: uid ?? this.uid,
        rtcToken: rtcToken ?? this.rtcToken,
        playbackUrl: playbackUrl ?? this.playbackUrl,
        numberOfViewers: numberOfViewers ?? this.numberOfViewers,
        isModerator: isModerator ?? this.isModerator,
      );

  Map<String, dynamic> toMap() => <String, dynamic>{
        'uid': uid,
        'rtcToken': rtcToken,
        'playbackUrl': playbackUrl,
        'numberOfViewers': numberOfViewers,
        'isModerator': isModerator,
      };

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'IsmLiveRTCModel(uid: $uid, rtcToken: $rtcToken, playbackUrl: $playbackUrl, numberOfViewers: $numberOfViewers, isModerator: $isModerator)';

  @override
  bool operator ==(covariant IsmLiveRTCModel other) {
    if (identical(this, other)) return true;

    return other.uid == uid &&
        other.rtcToken == rtcToken &&
        other.playbackUrl == playbackUrl &&
        other.numberOfViewers == numberOfViewers &&
        other.isModerator == isModerator;
  }

  @override
  int get hashCode => uid.hashCode ^ rtcToken.hashCode ^ playbackUrl.hashCode ^ numberOfViewers.hashCode ^ isModerator.hashCode;
}
