import 'dart:convert';
import 'dart:ui' as ui;

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
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
    bool isbattleFinish = false,
    bool isWinner = false,
    bool isViewer = false,
    bool isFirstIndex = false,
  }) {
    if (participantTrack.participant is LocalParticipant) {
      return LocalParticipantWidget(
        participantTrack.participant as LocalParticipant,
        participantTrack.videoTrack,
        participantTrack.isScreenShare,
        showStatsLayer,
        isHost,
        isbattleFinish,
        isWinner,
        isViewer,
        isFirstIndex,
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
        isbattleFinish,
        isWinner,
        isViewer,
        isFirstIndex,
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
  abstract final bool isbattleFinish;
  abstract final bool isWinner;
  abstract final bool isViewer;
  abstract final bool isFirstIndex;

  final VideoQuality quality;
}

class LocalParticipantWidget extends ParticipantWidget {
  const LocalParticipantWidget(
    this.participant,
    this.videoTrack,
    this.isScreenShare,
    this.showStatsLayer,
    this.isHost,
    this.isbattleFinish,
    this.isWinner,
    this.isViewer,
    this.isFirstIndex, {
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
  final bool isbattleFinish;
  @override
  final bool isWinner;
  @override
  final bool isViewer;
  @override
  final bool isFirstIndex;

  @override
  State<StatefulWidget> createState() => _LocalParticipantWidgetState();
}

class RemoteParticipantWidget extends ParticipantWidget {
  const RemoteParticipantWidget(
    this.participant,
    this.videoTrack,
    this.isScreenShare,
    this.showStatsLayer,
    this.isHost,
    this.isbattleFinish,
    this.isWinner,
    this.isViewer,
    this.isFirstIndex, {
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
  final bool isbattleFinish;
  @override
  final bool isWinner;
  @override
  final bool isViewer;
  @override
  final bool isFirstIndex;

  @override
  State<StatefulWidget> createState() => _RemoteParticipantWidgetState();
}

abstract class _ParticipantWidgetState<T extends ParticipantWidget>
    extends State<T> {
  VideoTrack? get activeVideoTrack;
  TrackPublication? get videoPublication;
  TrackPublication? get firstAudioPublication;
  var pkController = Get.find<IsmLivePkController>();

  bool get isAudioMuted {
    final publication = firstAudioPublication;
    if (publication == null) {
      return true;
    }

    final track = publication.track;
    if (track != null) {
      return track.muted;
    }

    return publication.muted;
  }

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

  /// Local preview mirror mode; [VideoViewMirrorMode.auto] for remote participants.
  VideoViewMirrorMode get videoPreviewMirrorMode => VideoViewMirrorMode.auto;

  Widget buildVideoRenderer() => VideoTrackRenderer(
        activeVideoTrack!,
        fit: widget.showFullVideo ? VideoViewFit.contain : VideoViewFit.cover,
        mirrorMode: videoPreviewMirrorMode,
      );

  @override
  Widget build(BuildContext ctx) {
    final uiData = _participantUiData(widget.participant, widget.imageUrl);
    final canShowMakeHostAction =
        widget.showStatsLayer && widget.isViewer && !widget.isFirstIndex;

    return Container(
        // Blue border removed - was causing unwanted border around stream view
        foregroundDecoration: null,
        decoration: BoxDecoration(
          color: context.liveTheme?.streamBackgroundColor ??
              Theme.of(ctx).cardColor.withAlpha(80),
        ),
        child: Stack(
          children: [
            activeVideoTrack != null && !activeVideoTrack!.muted
                ? buildVideoRenderer()
                : NoVideoWidget(
                    name: uiData.displayName,
                    imageUrl: uiData.imageUrl,
                    initials: IsmLiveInitials.extract(uiData.displayName),
                  ),
            if (widget.isbattleFinish)
              widget.isWinner
                  ? const Align(
                      alignment: Alignment.center,
                      child: IsmLiveImage.svg(IsmLiveAssetConstants.winner),
                    )
                  : const Align(
                      alignment: Alignment.center,
                      child: IsmLiveImage.svg(IsmLiveAssetConstants.loser),
                    ),
            if (widget.showStatsLayer)
              Align(
                alignment: Alignment.topCenter,
                child: ParticipantInfoWidget(
                  imageUrl: uiData.imageUrl,
                  name: uiData.displayName,
                  isHost: widget.isHost,
                  isFirstIndex: widget.isFirstIndex,
                  title: uiData.displayName,
                  hostCoins: pkController.pkHostValue.toInt(),
                  battleStart:
                      pkController.streamController.pkStages?.isPkStart ??
                          false,
                  gustCoins: pkController.pkGustValue.toInt(),
                  hostper: pkController.pkBarHostPersentage,
                  gustper: pkController.pkBarGustPersentage,
                ),
              ),
            if (canShowMakeHostAction)
              Align(
                alignment: Alignment.bottomRight,
                child: IsmLiveTapHandler(
                  onTap: () {
                    pkController.pkChangeHostSheet(
                      userId: widget.participant.identity,
                      name: uiData.displayName,
                      image: uiData.imageUrl,
                    );
                  },
                  child: Container(
                    padding: IsmLiveDimens.edgeInsets5,
                    margin: const EdgeInsets.only(right: 10, bottom: 72),
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
            if (isAudioMuted)
              Align(
                alignment: Alignment.center,
                child: IgnorePointer(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const IsmLiveImage.svg(
                      IsmLiveAssetConstants.micro_phone_off,
                      color: Colors.white,
                      width: 20,
                      height: 20,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
  }
}

class _LocalParticipantWidgetState
    extends _ParticipantWidgetState<LocalParticipantWidget> {
  /// Prefers app [IsmLiveStreamController.position] over WebRTC `facingMode`,
  /// which can stay `user` after a fast camera switch so the rear preview looks mirrored.
  @override
  VideoViewMirrorMode get videoPreviewMirrorMode {
    if (widget.isScreenShare ||
        activeVideoTrack?.source == TrackSource.screenShareVideo) {
      return VideoViewMirrorMode.off;
    }
    if (!Get.isRegistered<IsmLiveStreamController>()) {
      return VideoViewMirrorMode.auto;
    }
    final controller = Get.find<IsmLiveStreamController>();
    return controller.position == CameraPosition.front
        ? VideoViewMirrorMode.mirror
        : VideoViewMirrorMode.off;
  }

  @override
  Widget buildVideoRenderer() {
    if (!Get.isRegistered<IsmLiveStreamController>()) {
      return super.buildVideoRenderer();
    }
    // Rebuilds local preview immediately when camera position toggles, and
    // overlays a brief blur while [IsmLiveStreamController.isCameraSwitching]
    // is true so the native camera swap glitch is not visible.
    return GetBuilder<IsmLiveStreamController>(
      builder: (controller) => Stack(
        fit: StackFit.expand,
        children: [
          super.buildVideoRenderer(),
          IgnorePointer(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 140),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeIn,
              child: controller.isCameraSwitching
                  ? BackdropFilter(
                      key: const ValueKey('camera-switch-blur'),
                      filter: ui.ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                      child: const ColoredBox(color: Color(0x33000000)),
                    )
                  : const SizedBox.shrink(
                      key: ValueKey('camera-switch-idle'),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  LocalTrackPublication<LocalVideoTrack>? get videoPublication =>
      widget.participant.videoTrackPublications
          .where((element) => element.sid == widget.videoTrack?.sid)
          .firstOrNull;

  @override
  LocalTrackPublication<LocalAudioTrack>? get firstAudioPublication =>
      widget.participant.audioTrackPublications.firstOrNull;

  @override
  VideoTrack? get activeVideoTrack => widget.videoTrack;
}

class _RemoteParticipantWidgetState
    extends _ParticipantWidgetState<RemoteParticipantWidget> {
  @override
  RemoteTrackPublication<RemoteVideoTrack>? get videoPublication =>
      widget.participant.videoTrackPublications
          .where((element) => element.sid == widget.videoTrack?.sid)
          .firstOrNull;

  @override
  RemoteTrackPublication<RemoteAudioTrack>? get firstAudioPublication =>
      widget.participant.audioTrackPublications.firstOrNull;

  @override
  VideoTrack? get activeVideoTrack => widget.videoTrack;
}

class _ParticipantUiData {
  const _ParticipantUiData({
    required this.displayName,
    required this.imageUrl,
  });

  final String displayName;
  final String imageUrl;
}

_ParticipantUiData _participantUiData(
  Participant participant,
  String? fallbackImageUrl,
) {
  final fallbackName = participant.name.isNotEmpty
      ? participant.name
      : participant.identity;
  final fallbackImg = fallbackImageUrl ?? '';

  final map = _tryDecodeParticipantMetadata(participant.metadata);
  if (map == null) {
    return _ParticipantUiData(
      displayName: fallbackName,
      imageUrl: fallbackImg,
    );
  }

  final metaName = _displayNameFromMetadataMap(map);
  final metaImg = _profileImageFromMetadataMap(map);

  return _ParticipantUiData(
    displayName: (metaName != null && metaName.isNotEmpty)
        ? metaName
        : fallbackName,
    imageUrl:
        (metaImg != null && metaImg.isNotEmpty) ? metaImg : fallbackImg,
  );
}

Map<String, dynamic>? _tryDecodeParticipantMetadata(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return null;
  }
  try {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      return null;
    }
    return Map<String, dynamic>.from(decoded);
  } catch (_) {}
  return null;
}

String? _displayNameFromMetadataMap(Map<String, dynamic> map) {
  final first = map['firstName'];
  final last = map['lastName'];
  final firstStr = first is String ? first.trim() : '';
  final lastStr = last is String ? last.trim() : '';
  final fullName =
      [firstStr, lastStr].where((s) => s.isNotEmpty).join(' ');
  if (fullName.isNotEmpty) {
    return fullName;
  }
  final username = map['username'];
  if (username is String && username.trim().isNotEmpty) {
    return username.trim();
  }
  return null;
}

String? _profileImageFromMetadataMap(Map<String, dynamic> map) {
  final url = map['profileImage'];
  if (url is String && url.trim().isNotEmpty) {
    return url.trim();
  }
  return null;
}
