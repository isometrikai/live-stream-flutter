import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:livekit_client/livekit_client.dart';

abstract class ParticipantWidget extends StatefulWidget {
  const ParticipantWidget({
    this.quality = VideoQuality.MEDIUM,
    super.key,
  });

  static ParticipantWidget widgetFor(
    ParticipantTrack participantTrack, {
    String? imageUrl,
    bool showStatsLayer = false,
  }) {
    if (participantTrack.participant is LocalParticipant) {
      return LocalParticipantWidget(
        participantTrack.participant as LocalParticipant,
        participantTrack.videoTrack,
        participantTrack.isScreenShare,
        showStatsLayer,
        imageUrl: imageUrl,
      );
    } else if (participantTrack.participant is RemoteParticipant) {
      return RemoteParticipantWidget(
        participantTrack.participant as RemoteParticipant,
        participantTrack.videoTrack,
        participantTrack.isScreenShare,
        showStatsLayer,
        imageUrl: imageUrl,
      );
    }
    throw UnimplementedError('Unknown participant type');
  }

  // Must be implemented by child class
  abstract final Participant participant;
  abstract final String? imageUrl;
  abstract final VideoTrack? videoTrack;
  abstract final bool isScreenShare;
  abstract final bool showStatsLayer;
  final VideoQuality quality;
}

class LocalParticipantWidget extends ParticipantWidget {
  const LocalParticipantWidget(
    this.participant,
    this.videoTrack,
    this.isScreenShare,
    this.showStatsLayer, {
    this.imageUrl,
    super.key,
  });
  @override
  final LocalParticipant participant;
  @override
  final String? imageUrl;
  @override
  final VideoTrack? videoTrack;
  @override
  final bool isScreenShare;
  @override
  final bool showStatsLayer;

  @override
  State<StatefulWidget> createState() => _LocalParticipantWidgetState();
}

class RemoteParticipantWidget extends ParticipantWidget {
  const RemoteParticipantWidget(
    this.participant,
    this.videoTrack,
    this.isScreenShare,
    this.showStatsLayer, {
    this.imageUrl,
    super.key,
  });
  @override
  final RemoteParticipant participant;
  @override
  final String? imageUrl;
  @override
  final VideoTrack? videoTrack;
  @override
  final bool isScreenShare;
  @override
  final bool showStatsLayer;

  @override
  State<StatefulWidget> createState() => _RemoteParticipantWidgetState();
}

abstract class _ParticipantWidgetState<T extends ParticipantWidget> extends State<T> {
  VideoTrack? get activeVideoTrack;
  TrackPublication? get videoPublication;
  TrackPublication? get firstAudioPublication;

  @override
  void initState() {
    super.initState();
    widget.participant.addListener(_onParticipantChanged);
    _onParticipantChanged();
  }

  @override
  void dispose() {
    widget.participant.removeListener(_onParticipantChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant T oldWidget) {
    oldWidget.participant.removeListener(_onParticipantChanged);
    widget.participant.addListener(_onParticipantChanged);
    _onParticipantChanged();
    super.didUpdateWidget(oldWidget);
  }

  void _onParticipantChanged() => setState(() {});

  List<Widget> extraWidgets(bool isScreenShare) => [];

  @override
  Widget build(BuildContext ctx) => Container(
        foregroundDecoration: BoxDecoration(
          border: widget.participant.isSpeaking
              ? Border.all(
                  width: IsmLiveDimens.one,
                  color: Colors.blue,
                )
              : null,
        ),
        decoration: BoxDecoration(
          color: Theme.of(ctx).cardColor,
        ),
        child: Stack(
          children: [
            activeVideoTrack != null && !activeVideoTrack!.muted
                ? VideoTrackRenderer(
                    activeVideoTrack!,
                    fit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  )
                : NoVideoWidget(
                    name: widget.participant.name,
                    imageUrl: widget.imageUrl ?? '',
                  ),
            if (widget.showStatsLayer)
              Align(
                alignment: Alignment.bottomCenter,
                child: ParticipantInfoWidget(
                  isMute: widget.participant.isMuted,
                  title: widget.participant.name.isNotEmpty ? widget.participant.name : widget.participant.identity,
                ),
              ),
          ],
        ),
      );
}

class _LocalParticipantWidgetState extends _ParticipantWidgetState<LocalParticipantWidget> {
  @override
  LocalTrackPublication<LocalVideoTrack>? get videoPublication =>
      widget.participant.videoTracks.where((element) => element.sid == widget.videoTrack?.sid).firstOrNull;

  @override
  LocalTrackPublication<LocalAudioTrack>? get firstAudioPublication => widget.participant.audioTracks.firstOrNull;

  @override
  VideoTrack? get activeVideoTrack => widget.videoTrack;
}

class _RemoteParticipantWidgetState extends _ParticipantWidgetState<RemoteParticipantWidget> {
  @override
  RemoteTrackPublication<RemoteVideoTrack>? get videoPublication =>
      widget.participant.videoTracks.where((element) => element.sid == widget.videoTrack?.sid).firstOrNull;

  @override
  RemoteTrackPublication<RemoteAudioTrack>? get firstAudioPublication => widget.participant.audioTracks.firstOrNull;

  @override
  VideoTrack? get activeVideoTrack => widget.videoTrack;
}
