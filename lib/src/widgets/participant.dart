import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

abstract class ParticipantWidget extends StatefulWidget {
  const ParticipantWidget({
    this.quality = VideoQuality.MEDIUM,
    super.key,
  });

  static ParticipantWidget widgetFor(
    IsmLiveParticipantTrack participantTrack, {
    String? imageUrl,
    bool showStatsLayer = false,
    bool showFullVideo = false,
    bool isHost = false,
  }) {
    if (participantTrack.participant is LocalParticipant) {
      return LocalParticipantWidget(
        participantTrack.participant as LocalParticipant,
        participantTrack.videoTrack,
        participantTrack.isScreenShare,
        showStatsLayer,
        isHost,
        imageUrl: imageUrl,
        showFullVideo: showFullVideo,
      );
    } else if (participantTrack.participant is RemoteParticipant) {
      return RemoteParticipantWidget(
        participantTrack.participant as RemoteParticipant,
        participantTrack.videoTrack,
        participantTrack.isScreenShare,
        showStatsLayer,
        isHost,
        imageUrl: imageUrl,
        showFullVideo: showFullVideo,
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
  abstract final bool showFullVideo;
  abstract final bool isHost;

  final VideoQuality quality;
}

class LocalParticipantWidget extends ParticipantWidget {
  const LocalParticipantWidget(
    this.participant,
    this.videoTrack,
    this.isScreenShare,
    this.showStatsLayer,
    this.isHost, {
    this.imageUrl,
    this.showFullVideo = false,
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
  final bool showFullVideo;
  @override
  final bool isHost;

  @override
  State<StatefulWidget> createState() => _LocalParticipantWidgetState();
}

class RemoteParticipantWidget extends ParticipantWidget {
  const RemoteParticipantWidget(
    this.participant,
    this.videoTrack,
    this.isScreenShare,
    this.showStatsLayer,
    this.isHost, {
    this.imageUrl,
    this.showFullVideo = false,
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
  final bool showFullVideo;
  @override
  final bool isHost;

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
          color: context.liveTheme?.streamBackgroundColor ?? Theme.of(ctx).cardColor,
        ),
        child: Stack(
          children: [
            activeVideoTrack != null && !activeVideoTrack!.muted
                ? VideoTrackRenderer(
                    activeVideoTrack!,
                    fit: widget.showFullVideo ? RTCVideoViewObjectFit.RTCVideoViewObjectFitContain : RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                  )
                : NoVideoWidget(
                    name: widget.participant.name,
                    imageUrl: widget.imageUrl ?? '',
                  ),
            if (widget.showStatsLayer)
              const Align(
                alignment: Alignment.center,
                child: IsmLiveImage.svg(IsmLiveAssetConstants.winner),
              ),
            if (widget.showStatsLayer)
              Align(
                alignment: Alignment.bottomCenter,
                child: ParticipantInfoWidget(
                  imageUrl: widget.imageUrl ?? '',
                  name: widget.participant.name.isNotEmpty
                      ? widget.participant.name
                      : widget.participant.identity,
                  isHost: widget.isHost,
                  title: widget.participant.name.isNotEmpty ? widget.participant.name : widget.participant.identity,
                ),
              ),
            if (widget.showStatsLayer && !widget.isHost)
              Align(
                alignment: Alignment.topLeft,
                child: IsmLiveTapHandler(
                  onTap: () {
                    Get.find<IsmLiveStreamController>().pkChangeHostSheet();
                  },
                  child: Container(
                    padding: IsmLiveDimens.edgeInsets5,
                    margin: IsmLiveDimens.edgeInsets10,
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(
                        IsmLiveDimens.eight,
                      ),
                    ),
                    child: const Text(
                      'Make Host',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
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
