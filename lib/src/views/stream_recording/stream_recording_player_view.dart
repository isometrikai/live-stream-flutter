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

  void _onClose() {
    Navigator.of(context).maybePop();
  }

  @override
  void dispose() {
    _cacheManager.clearAll();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _preloadAround(int index) async {
    if (widget.recordings.isEmpty) return;
    final urls = <String>[];

    void addUrlFor(int i) {
      if (i < 0 || i >= widget.recordings.length) return;
      final recording = widget.recordings[i];
      final recorded = recording.recordedUrls;
      if (recorded.isNotEmpty) {
        urls.add(recorded.first);
      }
    }

    addUrlFor(index);
    addUrlFor(index + 1);
    addUrlFor(index - 1);

    await _cacheManager.precacheMedia(urls);
    await _cacheManager.clearOutsideRange(urls);
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
                      videoController: _controllers[index],
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
  Widget build(BuildContext context) => Stack(
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
            child: config.bottomControlsBuilder?.call(
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
                ),
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
                  ),
            ),
          ),
          // Center play icon should only be visible when video is NOT playing.
          // Use the VideoPlayerController as animation source so this stays in sync.
          if (videoController == null)
            Center(
              child: GestureDetector(
                onTap: onPlayPause,
                child: const IsmLiveStreamRecordingCenterPlayButton(
                  isPlaying: false,
                ),
              ),
            )
          else
            AnimatedBuilder(
              animation: videoController!,
              builder: (context, _) {
                final isPlaying = videoController!.value.isPlaying;
                if (isPlaying) {
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
                onControllerReady: onControllerReady,
                onCompleted:
                    autoMoveToNextOnCompletion ? onVideoCompleted : null,
              )
            : const ColoredBox(color: Colors.black),
      );
}
