import 'package:livekit_client/livekit_client.dart';

class IsmLiveParticipantTrack {
  IsmLiveParticipantTrack({
    required this.videoTrack,
    required this.participant,
    this.isScreenShare = false,
  });

  final VideoTrack? videoTrack;
  final Participant participant;
  final bool isScreenShare;

  IsmLiveParticipantTrack copyWith({
    VideoTrack? videoTrack,
    Participant? participant,
    bool? isScreenShare,
  }) =>
      IsmLiveParticipantTrack(
        videoTrack: videoTrack ?? this.videoTrack,
        participant: participant ?? this.participant,
        isScreenShare: isScreenShare ?? this.isScreenShare,
      );

  @override
  String toString() =>
      'IsmLiveParticipantTrack(videoTrack: $videoTrack, participant: $participant, isScreenShare: $isScreenShare)';

  @override
  bool operator ==(covariant IsmLiveParticipantTrack other) {
    if (identical(this, other)) return true;

    return other.videoTrack == videoTrack &&
        other.participant == participant &&
        other.isScreenShare == isScreenShare;
  }

  @override
  int get hashCode =>
      videoTrack.hashCode ^ participant.hashCode ^ isScreenShare.hashCode;
}
