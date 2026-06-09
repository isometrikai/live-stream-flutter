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

  /// Bumped on every page change so in-flight [_preloadAround] work from a
  /// previous index can bail out instead of precaching neighbors / clearing
  /// the cache for a window the user has already scrolled past.
  int _preloadGeneration = 0;

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
      final generation = _preloadGeneration;
      final keepUrls = _urlsAroundIndex(_currentIndex);
      unawaited(_cacheManager.abandonOutside(keepUrls));
      final activeUrl = _urlAtIndex(_currentIndex);
      if (activeUrl != null) {
        unawaited(_cacheManager.warmup(activeUrl));
      }
      unawaited(_preloadAround(_currentIndex, generation));
      _config.onLoaded?.call(context, _currentRecording);
    });
  }

  /// URLs for [index] and its immediate neighbors (the retention window).
  Set<String> _urlsAroundIndex(int index) {
    final urls = <String>{};
    final active = _urlAtIndex(index);
    if (active != null) urls.add(active);
    final next = _urlAtIndex(index + 1);
    if (next != null) urls.add(next);
    final previous = _urlAtIndex(index - 1);
    if (previous != null) urls.add(previous);
    return urls;
  }

  String? _urlAtIndex(int index) {
    if (index < 0 || index >= widget.recordings.length) return null;
    final recorded = widget.recordings[index].recordedUrls;
    if (recorded.isEmpty) return null;
    return recorded.first;
  }

  void _onPageChanged(int index) {
    if (index == _currentIndex) return;
    final generation = ++_preloadGeneration;
    setState(() => _currentIndex = index);

    final keepUrls = _urlsAroundIndex(index);
    final activeUrl = _urlAtIndex(index);

    // Stop downloads / decoder work for URLs outside the new window right
    // away. Without this, stale [_preloadAround] calls from rapid scrolling
    // keep HTTP sessions open and routinely push the *active* video past the
    // initialize timeout (user sees "failed to load"; manual retry works once
    // the stale sessions finish).
    unawaited(_cacheManager.abandonOutside(keepUrls));

    // Start loading the visible recording before the player widget mounts so
    // we don't lose a frame (or minutes, if the preload chain was blocked).
    if (activeUrl != null) {
      unawaited(_cacheManager.warmup(activeUrl));
    }

    unawaited(_preloadAround(index, generation));

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

  Future<void> _preloadAround(int index, int generation) async {
    if (widget.recordings.isEmpty) return;
    if (generation != _preloadGeneration) return;

    // Scroll-down first: users overwhelmingly swipe to the next recording.
    final neighborUrls = <String>[];
    final next = _urlAtIndex(index + 1);
    if (next != null) neighborUrls.add(next);
    final previous = _urlAtIndex(index - 1);
    if (previous != null) neighborUrls.add(previous);

    // Neighbor warm-up is best-effort and must not block the UI isolate.
    // Active URL loading is kicked off from [_onPageChanged] via [warmup].
    await _cacheManager.precacheMedia(neighborUrls);
    if (!mounted || generation != _preloadGeneration) return;

    await _cacheManager.clearOutsideRange(_urlsAroundIndex(index).toList());
  }

  @override
  Widget build(BuildContext context) {
    final config = _config;
    if (widget.recordings.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: ismLiveBuildBackButton(context),
          title: const Text(IsmLiveStrings.recording),
        ),
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
                      isActive: isActive,
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
    required this.isActive,
    required this.playerKey,
    required this.videoController,
    required this.config,
    required this.onClose,
    required this.onPlayPause,
  });

  final IsmLiveStreamRecordingItem recording;
  final bool isActive;
  final GlobalKey playerKey;
  final VideoPlayerController? videoController;
  final IsmLiveStreamRecordingPlayerConfig config;
  final VoidCallback onClose;
  final VoidCallback onPlayPause;

  @override
  Widget build(BuildContext context) {
    final isVideoReady = videoController?.value.isInitialized ?? false;
    final currentUserId = config.getCurrentUserId?.call();
    final streamerUserId = recording.userId;
    final isHost = currentUserId != null &&
        currentUserId.isNotEmpty &&
        streamerUserId != null &&
        streamerUserId.isNotEmpty &&
        currentUserId == streamerUserId;
    final gradientOverlay = IsmLiveDelegate
        .streamScreenConfigure
        .streamGradientOverlayBuilder
        ?.call(
      context,
      recording.streamId,
      isHost,
      false,
    );
    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradients overlay video content behind recording controls.
        ...(gradientOverlay != null
            ? [gradientOverlay]
            : const [
                _RecordingTopDarkGradient(),
                _RecordingBottomDarkGradient(),
              ]),
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
          if (config.showChatReplay)
            IsmLiveRecordingChatOverlay(
              recording: recording,
              config: config,
              videoController: videoController,
              isActive: isActive,
            ),
          // Center overlay: hide while actively playing; show a loader while the
          // player is buffering (e.g. after a seek); show play only when paused.
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
                if (v.isBuffering) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
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

class _RecordingTopDarkGradient extends StatelessWidget {
  const _RecordingTopDarkGradient();

  @override
  Widget build(BuildContext context) => Positioned(
        top: 0,
        left: 0,
        right: 0,
        height: MediaQuery.of(context).size.height * 0.3,
        child: const IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black38,
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      );
}

class _RecordingBottomDarkGradient extends StatelessWidget {
  const _RecordingBottomDarkGradient();

  @override
  Widget build(BuildContext context) => Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        height: MediaQuery.of(context).size.height * 0.3,
        child: const IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black38,
                ],
              ),
            ),
          ),
        ),
      );
}
