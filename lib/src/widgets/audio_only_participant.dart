import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/widgets/audio_visualizer.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

/// Widget for displaying audio-only participants with visualizer
class IsmLiveAudioOnlyParticipant extends StatelessWidget {
  const IsmLiveAudioOnlyParticipant({
    super.key,
    required this.participant,
    required this.imageUrl,
    required this.name,
    this.size = 120,
    this.onTap,
  });

  final lk.Participant participant;
  final String imageUrl;
  final String name;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Profile image
                    ClipOval(
                      child: IsmLiveImage.network(
                        IsmLiveDelegate.getUserProfileUrl?.call(imageUrl) ??
                            imageUrl,
                        name: name,
                        isProfileImage: true,
                        height: size,
                        width: size,
                        showError: false,
                      ),
                    ),
                    // Audio visualizer overlay (self-updating via participant listener)
                    IsmLiveAudioVisualizer(
                      participant: participant,
                      size: size * 0.8,
                    ),
                    // Mic status icon (top-right)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: _MicStatusIcon(participant: participant),
                    ),
                  ],
                ),
              ),
            ),
          ),
          IsmLiveDimens.boxHeight8,
          SizedBox(
            width: size,
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: IsmLiveStyles.white12.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      );
}

/// Grid view for audio-only participants
class IsmLiveAudioOnlyGrid extends StatelessWidget {
  const IsmLiveAudioOnlyGrid({
    super.key,
    required this.participantTracks,
    required this.streamMembersList,
    this.onParticipantTap,
  });

  final List<IsmLiveParticipantTrack> participantTracks;
  final List<IsmLiveMemberDetailsModel> streamMembersList;
  final void Function(lk.Participant participant, String displayName)?
      onParticipantTap;

  @override
  Widget build(BuildContext context) {
    if (participantTracks.isEmpty) {
      return const SizedBox.shrink();
    }

    final crossAxisCount = participantTracks.length <= 2 ? 2 : 3;
    final spacing = IsmLiveDimens.eight;

    return Padding(
      padding: EdgeInsets.only(
        top: IsmLiveDimens.hundred,
        left: IsmLiveDimens.sixteen,
        right: IsmLiveDimens.sixteen,
        bottom: IsmLiveDimens.sixteen,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: 0.8,
        ),
        itemCount: participantTracks.length,
        itemBuilder: (context, index) {
          final track = participantTracks[index];
          final participant = track.participant;

          // Find member details
          var imageUrl = '';
          var name = participant.name.isNotEmpty ? participant.name : 'User';

          for (var member in streamMembersList) {
            if (member.userId == participant.identity) {
              imageUrl = member.userProfileImageUrl.isNotEmpty
                  ? member.userProfileImageUrl
                  : (member.image.isNotEmpty ? member.image : '');
              name = member.userName.isNotEmpty
                  ? member.userName
                  : (member.name.isNotEmpty ? member.name : name);
              break;
            }
          }

          return IsmLiveAudioOnlyParticipant(
            participant: participant,
            imageUrl: imageUrl,
            name: name,
            size: 100,
            onTap: onParticipantTap == null
                ? null
                : () => onParticipantTap!(participant, name),
          );
        },
      ),
    );
  }
}

class _MicStatusIcon extends StatelessWidget {
  const _MicStatusIcon({required this.participant});
  final lk.Participant participant;

  bool get _isMutedForLocal {
    try {
      // Consider muted if no subscribed audio tracks or all muted
      final pubs = participant.audioTrackPublications;
      if (pubs.isEmpty) return true;
      var anySubscribed = false;
      for (final p in pubs) {
        final dynamic rp = p;
        final subscribed = (rp.subscribed == true);
        anySubscribed = anySubscribed || subscribed;
        if (subscribed && !p.muted) {
          return false; // actively received and unmuted
        }
      }
      return true; // none actively received
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(2),
        child: Icon(
          _isMutedForLocal ? Icons.mic_off : Icons.mic,
          size: 16,
          color: Colors.white,
        ),
      );
}
