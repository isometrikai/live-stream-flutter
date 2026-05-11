import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/res/navigation/routes.dart';
import 'package:appscrip_live_stream_component/src/views/stream_recording/recording_video_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

/// Full-screen stream recording player with vertical swipe between recordings.
///
/// Uses [config] if provided, otherwise [IsmLiveDelegate.streamRecordingPlayerConfig].
/// Host app can open via [IsmLiveApp.openStreamRecordingPlayer] or
/// [IsmLiveRouteManagement.goToStreamRecordingPlayer].
///
/// Scrolling and play/pause behaviour follow the SDK pattern:
/// - [PageView.builder] with [AlwaysScrollableScrollPhysics] + [ClampingScrollPhysics].
/// - Optional [onLoadMore] when user reaches ~65% of the list or last item.
/// - When [autoMoveToNextOnCompletion] is true, video completion animates to the next page.
///
/// Host usage example with pagination:
/// ```dart
/// await IsmLiveApp.openStreamRecordingPlayer(
///   recordings: recordings,
///   initialIndex: 0,
///   onLoadMore: () async {
///     if (isLoadingMore || !hasMore) return;
///     isLoadingMore = true;
///     try {
///       final nextPage = await repository.getStreamRecordings(page: page + 1);
///       recordings.addAll(nextPage.items);
///       page++;
///       hasMore = nextPage.hasMore;
///     } finally {
///       isLoadingMore = false;
///     }
///   },
/// );
/// ```
class IsmLiveStreamRecordingPlayerView extends StatefulWidget {
  const IsmLiveStreamRecordingPlayerView({
    super.key,
    required this.recordings,
    this.initialIndex = 0,
    this.config,
    this.allowImplicitScrolling = true,
    this.autoMoveToNextOnCompletion = true,
    this.onLoadMore,
  });

  static const String route = IsmLiveRoutes.streamRecordingPlayer;

  /// List of recording items; [initialIndex] selects the first visible.
  final List<IsmLiveStreamRecordingItem> recordings;

  /// Initial page index.
  final int initialIndex;

  /// Optional config. If null, uses [IsmLiveDelegate.streamRecordingPlayerConfig].
  final IsmLiveStreamRecordingPlayerConfig? config;

  /// Whether the [PageView] keeps adjacent pages built (smoother scrolling). Default true.
  final bool allowImplicitScrolling;

  /// When true, completing a video animates to the next recording. Default true.
  final bool autoMoveToNextOnCompletion;

  /// Called when user scrolls to ~65% of the list or to the last item. Host can load more and update state.
  final Future<void> Function()? onLoadMore;

  @override
  State<IsmLiveStreamRecordingPlayerView> createState() =>
      _IsmLiveStreamRecordingPlayerViewState();
}

class _IsmLiveStreamRecordingPlayerViewState
    extends State<IsmLiveStreamRecordingPlayerView> {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _showOverlay = true;

  final RecordingVideoCacheManager _cacheManager =
      RecordingVideoCacheManager.instance;
  final Map<int, GlobalKey> _pageKeys = {};
  final Map<int, VideoPlayerController?> _controllers = {};

  IsmLiveStreamRecordingPlayerConfig get _config =>
      widget.config ??
      IsmLiveDelegate.streamRecordingPlayerConfig ??
      IsmLiveDelegate.defaultStreamRecordingPlayerConfig;

  IsmLiveStreamRecordingItem get _currentRecording =>
      widget.recordings[_currentIndex];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final targetPage = widget.initialIndex >= widget.recordings.length
          ? (widget.recordings.isEmpty ? 0 : widget.recordings.length - 1)
          : widget.initialIndex;
      if (targetPage > 0 && _pageController.hasClients) {
        _pageController.jumpToPage(targetPage);
      }
      _preloadAround(_currentIndex);
      _config.onLoaded?.call(context, _currentRecording);
    });
  }

  void _onPageChanged(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    _preloadAround(index);

    // Notify host every time a new recording becomes the visible one.
    final recording = widget.recordings[index];
    _config.onLoaded?.call(context, recording);

    // SDK-style: trigger onLoadMore when at ~65% of list or on last item
    final threshold = (widget.recordings.length * 0.65).floor();
    if (index >= threshold || index == widget.recordings.length - 1) {
      widget.onLoadMore?.call();
    }
  }

  /// SDK-style: on video completion, animate to next page or trigger load more at end
  void _handleVideoCompletion(int completedIndex) {
    if (!mounted || widget.recordings.isEmpty) return;
    if (completedIndex < widget.recordings.length - 1) {
      final nextIndex = completedIndex + 1;
      _pageController.animateToPage(
        nextIndex,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      widget.onLoadMore?.call();
    }
  }

  void _togglePlayPauseFor(GlobalKey? key) {
    if (key == null) return;
    final state = IsmLiveRecordingAutoVideoPlayer.of(key);
    if (state == null) return;
    if (state.isPlaying) {
      state.pause();
    } else {
      state.play();
    }
    setState(() {});
  }

  VideoPlayerController? _getCachedControllerForIndex(int index) {
    if (index < 0 || index >= widget.recordings.length) return null;
    final recorded = widget.recordings[index].recordedUrls;
    if (recorded.isEmpty) return null;
    return _cacheManager.getCachedController(recorded.first);
  }

  Future<void> _closeAndPop() async {
    // Stop all known players first so host app never hears background audio.
    for (final key in _pageKeys.values) {
      IsmLiveRecordingAutoVideoPlayer.of(key)?.pause();
    }
    for (var i = 0; i < widget.recordings.length; i++) {
      final controller = _getCachedControllerForIndex(i);
      if (controller == null) continue;
      await controller.pause();
      await controller.setVolume(0.0);
    }
    if (!mounted) return;
    await Navigator.of(context).maybePop();
  }

  void _onClose() {
    unawaited(_closeAndPop());
  }

  @override
  void dispose() {
    for (final key in _pageKeys.values) {
      IsmLiveRecordingAutoVideoPlayer.of(key)?.pause();
    }
    for (var i = 0; i < widget.recordings.length; i++) {
      final controller = _getCachedControllerForIndex(i);
      if (controller == null) continue;
      unawaited(controller.pause());
      unawaited(controller.setVolume(0.0));
    }
    _cacheManager.clearAll();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _preloadAround(int index) async {
    if (widget.recordings.isEmpty) return;
    final activeUrls = <String>[];
    final neighborUrls = <String>[];

    void collect(int i, List<String> bucket) {
      if (i < 0 || i >= widget.recordings.length) return;
      final recording = widget.recordings[i];
      final recorded = recording.recordedUrls;
      if (recorded.isNotEmpty) {
        bucket.add(recorded.first);
      }
    }

    collect(index, activeUrls);
    collect(index + 1, neighborUrls);
    collect(index - 1, neighborUrls);

    final keepUrls = <String>[...activeUrls, ...neighborUrls];

    // Speed up first-frame for the currently visible recording – especially
    // important for long videos and slow CDNs where parallel preloads were
    // splitting bandwidth/decoder budget three ways while the user stared at
    // the spinner. The widget for [index] joins this same future via the
    // cache manager's in-flight coalescing, so it doesn't double-fetch.
    await _cacheManager.precacheMedia(activeUrls);

    // Hold off neighbor preload until the active video is actually playing
    // (or a short safety cap elapses). For long videos on slow CDNs this
    // stops neighbor HTTP sessions from stealing bandwidth while the user is
    // still waiting on the first decodable frame of the active recording.
    if (activeUrls.isNotEmpty) {
      await _waitForActivePlaying(activeUrls.first);
    }

    // Then warm neighbors so swiping still feels instant. Awaited so that
    // [clearOutsideRange] below runs after preload (same invariant as before).
    await _cacheManager.precacheMedia(neighborUrls);

    await _cacheManager.clearOutsideRange(keepUrls);
  }

  /// Waits until the cached controller for [url] reports `isPlaying`, or
  /// until [maxWait] elapses - whichever comes first.
  ///
  /// Returns immediately if the controller is already playing or is unknown
  /// (e.g. evicted before this call). Always cleans up the temporary listener
  /// and safety timer so it can't leak across page changes.
  ///
  /// 10s rather than the original 4s: long recordings on slow networks can
  /// take several seconds beyond `initialize()` completion before they
  /// actually start playing, and we want to keep the full bandwidth pipe on
  /// the active video until then (otherwise neighbor preload starts stealing
  /// bytes and the active's first-frame stalls).
  Future<void> _waitForActivePlaying(
    String url, {
    Duration maxWait = const Duration(seconds: 10),
  }) async {
    final controller = _cacheManager.getCachedController(url);
    if (controller == null) return;
    if (controller.value.isPlaying) return;

    final completer = Completer<void>();
    Timer? safetyTimer;
    late VoidCallback listener;

    void finish() {
      if (completer.isCompleted) return;
      completer.complete();
    }

    listener = () {
      final value = controller.value;
      if (value.hasError || value.isPlaying) {
        finish();
      }
    };

    controller.addListener(listener);
    safetyTimer = Timer(maxWait, finish);

    try {
      await completer.future;
    } finally {
      safetyTimer.cancel();
      controller.removeListener(listener);
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _config;
    if (widget.recordings.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text(IsmLiveStrings.recording)),
        body: const Center(child: Text(IsmLiveStrings.noRecordings)),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: PageView.builder(
          controller: _pageController,
          scrollDirection: Axis.vertical,
          allowImplicitScrolling: widget.allowImplicitScrolling,
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
          itemCount: widget.recordings.length,
          onPageChanged: _onPageChanged,
          itemBuilder: (context, index) {
            final recording = widget.recordings[index];
            final isActive = index == _currentIndex;
            _pageKeys[index] ??= GlobalKey();
            final playerKey = _pageKeys[index]!;
            final playerState = IsmLiveRecordingAutoVideoPlayer.of(playerKey);
            final overlayController = isActive
                ? (playerState?.controller ?? _getCachedControllerForIndex(index))
                : null;
            return RepaintBoundary(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _RecordingPage(
                    recording: recording,
                    index: index,
                    isActive: isActive,
                    playerKey: playerKey,
                    autoMoveToNextOnCompletion:
                        widget.autoMoveToNextOnCompletion,
                    onVideoCompleted: () => _handleVideoCompletion(index),
                    onControllerReady: (controller) {
                      setState(() {
                        _controllers[index] = controller;
                      });
                    },
                    onTap: () {
                      setState(() => _showOverlay = !_showOverlay);
                    },
                    onLongPressPause: () {
                      IsmLiveRecordingAutoVideoPlayer.of(playerKey)?.pause();
                    },
                    onLongPressResume: () {
                      IsmLiveRecordingAutoVideoPlayer.of(playerKey)?.play();
                    },
                  ),
                  if (_showOverlay)
                    _RecordingOverlay(
                      recording: recording,
                      playerKey: playerKey,
                      videoController: overlayController,
                      config: config,
                      onClose: _onClose,
                      onPlayPause: () => _togglePlayPauseFor(playerKey),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Per-page overlay that scrolls with the page (reels SDK style).
class _RecordingOverlay extends StatelessWidget {
  const _RecordingOverlay({
    required this.recording,
    required this.playerKey,
    required this.videoController,
    required this.config,
    required this.onClose,
    required this.onPlayPause,
  });

  final IsmLiveStreamRecordingItem recording;
  final GlobalKey playerKey;
  final VideoPlayerController? videoController;
  final IsmLiveStreamRecordingPlayerConfig config;
  final VoidCallback onClose;
  final VoidCallback onPlayPause;

  @override
  Widget build(BuildContext context) {
    final isVideoReady = videoController?.value.isInitialized ?? false;
    return Stack(
      fit: StackFit.expand,
      children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: config.topControlsBuilder?.call(
                  context,
                  recording,
                  config,
                  onClose,
                ) ??
                IsmLiveStreamRecordingTopControls(
                  recording: recording,
                  config: config,
                  onClose: onClose,
                ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: isVideoReady
                ? config.bottomControlsBuilder?.call(
                      context,
                      recording,
                      config,
                      videoController,
                      onPlayPause,
                    ) ??
                    IsmLiveStreamRecordingBottomControls(
                      recording: recording,
                      config: config,
                      videoController: videoController,
                      onPlayPause: onPlayPause,
                    )
                : const SizedBox.shrink(),
          ),
          Positioned(
            right: 8,
            top: 0,
            bottom: 0,
            child: Center(
              child: config.rightControlsBuilder?.call(
                    context,
                    recording,
                    config,
                  ) ??
                  IsmLiveStreamRecordingRightControls(
                    config: config,
                    recording: recording,
                    onPausePlayback: () {
                      IsmLiveRecordingAutoVideoPlayer.of(playerKey)?.pause();
                    },
                    onResumePlayback: () {
                      IsmLiveRecordingAutoVideoPlayer.of(playerKey)?.play();
                    },
                  ),
            ),
          ),
          // Center play icon: hide only while actively playing (not while buffering).
          // During buffering, show play icon instead of a loading-style UX.
          if (!isVideoReady)
            const SizedBox.shrink()
          else
            AnimatedBuilder(
              animation: videoController!,
              builder: (context, _) {
                final v = videoController!.value;
                final showPlaying = v.isPlaying && !v.isBuffering;
                if (showPlaying) {
                  return const SizedBox.shrink();
                }
                return Center(
                  child: GestureDetector(
                    onTap: onPlayPause,
                    child: const IsmLiveStreamRecordingCenterPlayButton(
                      isPlaying: false,
                    ),
                  ),
                );
              },
            ),
      ],
    );
  }
}

class _RecordingPage extends StatelessWidget {
  const _RecordingPage({
    required this.recording,
    required this.index,
    required this.isActive,
    required this.playerKey,
    required this.autoMoveToNextOnCompletion,
    required this.onVideoCompleted,
    required this.onControllerReady,
    required this.onTap,
    required this.onLongPressPause,
    required this.onLongPressResume,
  });

  final IsmLiveStreamRecordingItem recording;
  final int index;
  final bool isActive;
  final GlobalKey playerKey;
  final bool autoMoveToNextOnCompletion;
  final VoidCallback? onVideoCompleted;
  final void Function(VideoPlayerController controller) onControllerReady;
  final VoidCallback onTap;
  final VoidCallback onLongPressPause;
  final VoidCallback onLongPressResume;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        onLongPressStart: (_) => onLongPressPause(),
        onLongPressEnd: (_) => onLongPressResume(),
        child: isActive && recording.recordedUrls.isNotEmpty
            ? IsmLiveRecordingAutoVideoPlayer(
                key: playerKey,
                url: recording.recordedUrls.first,
                thumbnailUrl: recording.thumbnailUrl,
                onControllerReady: onControllerReady,
                onCompleted:
                    autoMoveToNextOnCompletion ? onVideoCompleted : null,
              )
            : const ColoredBox(color: Colors.black),
      );
}
