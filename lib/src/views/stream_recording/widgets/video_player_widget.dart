import 'dart:async';

import 'package:appscrip_live_stream_component/src/live_delegate.dart';
import 'package:appscrip_live_stream_component/src/views/stream_recording/recording_video_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Auto-playing, visibility-aware video player for recordings.
///
/// This widget owns its [VideoPlayerController] via [RecordingVideoCacheManager]
/// and exposes basic playback controls to the parent through its [State].
class IsmLiveRecordingAutoVideoPlayer extends StatefulWidget {
  const IsmLiveRecordingAutoVideoPlayer({
    super.key,
    required this.url,
    this.thumbnailUrl,
    this.isMuted = false,
    this.onProgress,
    this.onCompleted,
    this.onControllerReady,
  });

  final String url;

  /// Optional poster image shown behind the spinner while the controller is
  /// still initializing (especially helpful for long videos on slow networks
  /// where the user would otherwise stare at a black frame). When null or on
  /// load failure the background falls back to black.
  final String? thumbnailUrl;
  final bool isMuted;
  final void Function(Duration total, Duration position)? onProgress;
  final VoidCallback? onCompleted;
  // Notifies when a controller is first attached (for overlays).
  final void Function(VideoPlayerController controller)? onControllerReady;

  /// Access the state from a [GlobalKey].
  static _IsmLiveRecordingAutoVideoPlayerState? of(GlobalKey key) =>
      key.currentState as _IsmLiveRecordingAutoVideoPlayerState?;

  @override
  State<IsmLiveRecordingAutoVideoPlayer> createState() =>
      _IsmLiveRecordingAutoVideoPlayerState();
}

class _IsmLiveRecordingAutoVideoPlayerState
    extends State<IsmLiveRecordingAutoVideoPlayer> {
  final RecordingVideoCacheManager _cache = RecordingVideoCacheManager.instance;
  VideoPlayerController? _controller;
  bool _isInitializing = false;
  bool _isVisible = false;
  bool _isManuallyPaused = false;
  bool _isDisposed = false;
  int _lastProgressMillis = 0;
  bool _wasBuffering = false;
  Timer? _stuckTimer;
  int _recoveryAttempts = 0;
  static const int _maxRecoveryAttempts = 5;
  String? _lastTrackedControllerError;
  String? _loadFailureMessage;

  /// Wall-clock timestamp of the first transition into `isPlaying`.
  /// Used to switch the buffering UI from cold-init mode (always visible) to
  /// mid-playback rebuffer mode (suppressed for a short grace window).
  int? _firstPlayMillis;

  /// Wall-clock timestamp of the most recent transition into `isBuffering`.
  /// Used together with [_bufferingFlashGraceMs] to hide the rebuffer overlay
  /// for very short rebuffers (which would otherwise just look like a flash).
  int? _bufferingStartMillis;

  /// Last time we rebuilt the widget specifically to advance the cold-init
  /// progress bar. Throttled so the controller listener doesn't redraw the
  /// whole subtree more than ~2.5x per second.
  int _lastBufferingRebuildMillis = 0;

  static const int _bufferingFlashGraceMs = 700;
  static const int _bufferingRebuildIntervalMs = 400;

  bool get isPlaying =>
      _controller != null && _controller!.value.isPlaying == true;

  Duration? get duration =>
      _controller != null && _controller!.value.isInitialized
          ? _controller!.value.duration
          : null;

  /// Exposes the underlying controller for overlays (e.g. bottom bar seek/progress).
  VideoPlayerController? get controller => _controller;

  @override
  void initState() {
    super.initState();
    if (_consumeKnownFailureIfAny()) return;
    _initializeIfNeeded();
  }

  @override
  void didUpdateWidget(IsmLiveRecordingAutoVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _loadFailureMessage = null;
      _lastTrackedControllerError = null;
      _firstPlayMillis = null;
      _bufferingStartMillis = null;
      _lastBufferingRebuildMillis = 0;
      if (_consumeKnownFailureIfAny()) return;
      _initializeIfNeeded();
    }
    if (oldWidget.isMuted != widget.isMuted &&
        _controller != null &&
        _controller!.value.isInitialized) {
      _controller!.setVolume(widget.isMuted ? 0.0 : 1.0);
    }
  }

  /// If the cache manager has already seen [widget.url] fail with a
  /// permanent (e.g. 403) error this session, surface the retry UI on the
  /// very first build instead of paying the cost of a fresh HTTP round-trip
  /// just to discover the same failure. Returns true when a known failure
  /// was consumed (caller should NOT call [_initializeIfNeeded]).
  bool _consumeKnownFailureIfAny() {
    if (widget.url.isEmpty) return false;
    final message = _cache.getKnownFailure(widget.url);
    if (message == null) return false;
    _loadFailureMessage = message;
    _lastTrackedControllerError = message;
    return true;
  }

  Future<void> _initializeIfNeeded() async {
    if (_isInitializing || widget.url.isEmpty) return;
    _loadFailureMessage = null;
    _isInitializing = true;
    setState(() {});
    try {
      final controller = await _cache.getOrCreate(widget.url);
      if (_isDisposed) {
        // Controller is shared in [RecordingVideoCacheManager]; never dispose it here.
        return;
      }
      _attachController(controller);
      if (mounted) {
        setState(() {});
      }
      if (!_isManuallyPaused) {
        _playInternal();
      }
    } catch (e, st) {
      _loadFailureMessage = e.toString();
      _trackVideoLoadFailure(
        stage: 'initialize',
        error: e,
        stackTrace: st,
      );
    } finally {
      _isInitializing = false;
      if (mounted) {
        setState(() {});
      }
    }
  }

  void _attachController(VideoPlayerController controller) {
    _controller?.removeListener(_handleProgress);
    _controller = controller;
    _controller!.addListener(_handleProgress);
    _controller!.setLooping(true);
    _controller!.setVolume(widget.isMuted ? 0.0 : 1.0);
    // A cached controller that previously played all the way through (e.g.
    // auto-advance from `onCompleted`) is parked at `position == duration`.
    // `setLooping(true)` only loops while actively playing, so a plain
    // `play()` from that state surfaces no frames - the user sees the
    // frozen last frame and assumes the video is broken. Rewind first so
    // playback restarts cleanly when the user scrolls back to it.
    final value = _controller!.value;
    final durationMs = value.duration.inMilliseconds;
    if (durationMs > 0 &&
        durationMs - value.position.inMilliseconds <= 300) {
      unawaited(_controller!.seekTo(Duration.zero));
    }
    // Inform parent that a usable controller is now available.
    widget.onControllerReady?.call(_controller!);
  }

  void _handleProgress() {
    if (_isDisposed ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;
    final value = _controller!.value;
    final position = value.position;
    final total = value.duration;
    _trackControllerValueErrorIfAny(value);

    // Stop the stuck-detection / buffering→play recovery loop once the
    // controller is in an error state - retry is now a user action.
    if (value.hasError) {
      _stopStuckDetection();
      return;
    }

    // First transition into playback: remember the timestamp and force one
    // rebuild so the cold-init buffered progress bar disappears at the
    // moment playback actually starts.
    if (_firstPlayMillis == null && value.isPlaying) {
      _firstPlayMillis = now;
      _bufferingStartMillis = null;
      if (mounted) {
        scheduleMicrotask(() {
          if (mounted) setState(() {});
        });
      }
    }

    // Track the start of each new buffering window for the post-play
    // rebuffer-flash grace period.
    if (value.isBuffering && !_wasBuffering) {
      _bufferingStartMillis = now;
    } else if (!value.isBuffering && _wasBuffering) {
      _bufferingStartMillis = null;
    }

    if (_wasBuffering &&
        !value.isBuffering &&
        _isVisible &&
        !_isManuallyPaused &&
        !value.isPlaying) {
      _playInternal();
    }
    _wasBuffering = value.isBuffering;

    if (now - _lastProgressMillis >= 200) {
      _lastProgressMillis = now;
      widget.onProgress?.call(total, position);
    }

    // Detect completion with a small threshold.
    if (total.inMilliseconds > 0 &&
        (total.inMilliseconds - position.inMilliseconds).abs() <= 300) {
      widget.onCompleted?.call();
    }

    // Throttled rebuild so the cold-init buffered progress bar updates as
    // the player downloads more of the file. We only redraw when the bar
    // would actually be visible to avoid wasted work during normal playback.
    if (_shouldShowBufferingBar(value) &&
        now - _lastBufferingRebuildMillis >= _bufferingRebuildIntervalMs) {
      _lastBufferingRebuildMillis = now;
      if (mounted) {
        scheduleMicrotask(() {
          if (mounted) setState(() {});
        });
      }
    }
  }

  /// Whether the cold-init / rebuffer progress bar should currently be drawn.
  ///
  /// - Before the first play: visible whenever playback hasn't started yet.
  ///   This is the long-video first-frame wait we want to make legible.
  /// - After the first play: visible only after [_bufferingFlashGraceMs] of
  ///   continuous buffering so short rebuffers don't flash UI.
  bool _shouldShowBufferingBar(VideoPlayerValue value) {
    if (!value.isInitialized) return false;
    if (value.hasError) return false;
    if (_firstPlayMillis == null) {
      return !value.isPlaying;
    }
    if (!value.isBuffering) return false;
    final bufferingStart = _bufferingStartMillis;
    if (bufferingStart == null) return false;
    return DateTime.now().millisecondsSinceEpoch - bufferingStart >
        _bufferingFlashGraceMs;
  }

  void _trackControllerValueErrorIfAny(VideoPlayerValue value) {
    if (!value.hasError) return;
    final rawError = value.errorDescription;
    final normalizedError =
        (rawError == null || rawError.isEmpty) ? 'unknown' : rawError;
    final isFirstReport = _lastTrackedControllerError != normalizedError;
    _loadFailureMessage = normalizedError;
    if (isFirstReport) {
      _lastTrackedControllerError = normalizedError;
      _trackVideoLoadFailure(
        stage: 'controller',
        error: normalizedError,
      );
    }
    // The controller listener doesn't trigger a rebuild on its own, so a
    // post-initialization error (e.g. mid-stream HTTP 403 / source error)
    // would otherwise leave the user staring at a blank/loading frame.
    // Schedule a rebuild so the retry UI surfaces immediately.
    if (isFirstReport && mounted) {
      scheduleMicrotask(() {
        if (mounted) setState(() {});
      });
    }
  }

  void _trackVideoLoadFailure({
    required String stage,
    Object? error,
    StackTrace? stackTrace,
  }) {
    IsmLiveDelegate.trackEvent(
      IsmLiveAnalyticsEvent.recordingVideoLoadFailure,
      properties: [
        {
          'video_url': widget.url,
          'stage': stage,
          'error': error?.toString() ?? 'unknown',
          'is_visible': _isVisible,
          'recovery_attempts': _recoveryAttempts,
          if (stackTrace != null) 'stack_trace': stackTrace.toString(),
        },
      ],
    );
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (_isDisposed) return;
    final wasVisible = _isVisible;
    _isVisible = info.visibleFraction > 0.5;

    if (wasVisible == _isVisible) return;

    if (_controller == null || !_controller!.value.isInitialized) {
      // If we've already recorded a load failure for this URL, don't silently
      // re-trigger init on every visibility flip - that just thrashes the
      // spinner and hides the retry CTA from the user. Fresh widget mounts
      // (PageView re-entry / URL change) still go through [initState] /
      // [didUpdateWidget] which clear the failure state.
      if (_isVisible && _loadFailureMessage == null) {
        _initializeIfNeeded();
      }
      return;
    }

    if (_isVisible && !_isManuallyPaused) {
      _cache.markVisible(widget.url);
      _playInternal();
      _startStuckDetection();
    } else {
      _cache.markNotVisible(widget.url);
      _controller!.pause();
      _stopStuckDetection();
    }
  }

  void _startStuckDetection() {
    _stuckTimer?.cancel();
    _recoveryAttempts = 0;
    _stuckTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _checkStuck();
    });
  }

  void _stopStuckDetection() {
    _stuckTimer?.cancel();
    _stuckTimer = null;
  }

  Future<void> _checkStuck() async {
    if (_isDisposed || !_isVisible || _isManuallyPaused) {
      _stopStuckDetection();
      return;
    }
    if (_controller == null || !_controller!.value.isInitialized) {
      return;
    }
    if (_controller!.value.isBuffering) {
      return;
    }
    if (_controller!.value.isPlaying) {
      _stopStuckDetection();
      return;
    }

    _recoveryAttempts++;
    _playInternal();
    if (_recoveryAttempts >= _maxRecoveryAttempts) {
      _stopStuckDetection();
      await _cache.clear(widget.url);
      _controller = null;
      await _initializeIfNeeded();
    }
  }

  void pause() {
    if (_controller == null || !_controller!.value.isInitialized) return;
    _isManuallyPaused = true;
    _controller!.pause();
  }

  void play() {
    _isManuallyPaused = false;
    _playInternal();
  }

  Future<void> seekTo(Duration position) async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    await _controller!.seekTo(position);
  }

  void _playInternal() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    // Don't try to drive playback on an errored controller; doing so would
    // either no-op silently or thrash auto-recovery and keep the spinner up.
    if (controller.value.hasError) return;
    controller.setVolume(widget.isMuted ? 0.0 : 1.0);
    controller.play();
  }

  Future<void> _retryLoad() async {
    if (_isInitializing) return;
    await _cache.clear(widget.url);
    // The user explicitly asked for another attempt - drop the cached
    // failure marker so [_initializeIfNeeded] is allowed to take a fresh
    // swing at the network (otherwise it would short-circuit straight
    // back to the retry UI via [_consumeKnownFailureIfAny]).
    _cache.forgetKnownFailure(widget.url);
    _controller?.removeListener(_handleProgress);
    _controller = null;
    _loadFailureMessage = null;
    _lastTrackedControllerError = null;
    _firstPlayMillis = null;
    _bufferingStartMillis = null;
    _lastBufferingRebuildMillis = 0;
    if (mounted) {
      setState(() {});
    }
    await _initializeIfNeeded();
  }

  void _stopPlayback({bool mute = true}) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (mute) {
      controller.setVolume(0.0);
    }
    unawaited(controller.pause());
  }

  @override
  void dispose() {
    _isDisposed = true;
    _stopStuckDetection();
    _cache.markNotVisible(widget.url);
    _stopPlayback();
    _controller?.removeListener(_handleProgress);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final hasControllerError = controller?.value.hasError == true;
    // Treat an initialized-but-errored controller as "not ready" so we render
    // the retry UI instead of mounting [VideoPlayer] on a broken controller
    // (which would show as an endless blank/loading frame on some devices).
    final isReady = controller != null &&
        controller.value.isInitialized &&
        !hasControllerError;
    final errorMessage = hasControllerError
        ? (controller?.value.errorDescription ?? 'Failed to load video')
        : _loadFailureMessage;
    final hasLoadError = errorMessage != null && errorMessage.isNotEmpty;
    final showBufferingBar =
        isReady && _shouldShowBufferingBar(controller.value);

    return VisibilityDetector(
      key: Key('recording_video_${widget.url}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: ColoredBox(
        color: Colors.black,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (isReady)
              _buildVideoContent(controller)
            else if (hasLoadError)
              _buildRetryUi()
            else
              _buildLoadingUi(),
            if (showBufferingBar) _buildBufferingBar(controller.value),
          ],
        ),
      ),
    );
  }

  /// Loading state shown while the controller is still initializing.
  ///
  /// Uses `widget.thumbnailUrl` as a poster behind a translucent scrim and the
  /// existing spinner so long-video first-frame waits don't look like a stuck
  /// black screen. Falls back to plain black on missing / broken thumbnail.
  Widget _buildLoadingUi() {
    final thumbnailUrl = widget.thumbnailUrl;
    final hasThumbnail = thumbnailUrl != null && thumbnailUrl.isNotEmpty;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (hasThumbnail)
          Image.network(
            thumbnailUrl,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (_, __, ___) =>
                const ColoredBox(color: Colors.black),
            loadingBuilder: (_, child, progress) =>
                progress == null ? child : const ColoredBox(color: Colors.black),
          ),
        // Translucent scrim keeps the spinner / progress bar legible even on
        // very bright thumbnails.
        const ColoredBox(color: Color(0x66000000)),
        const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ],
    );
  }

  /// Thin progress bar pinned to the bottom showing how much of the file has
  /// been buffered, expressed as a fraction of total duration. Indeterminate
  /// (null value) when we don't have enough info yet.
  Widget _buildBufferingBar(VideoPlayerValue value) {
    final totalMs = value.duration.inMilliseconds;
    double? progress;
    if (totalMs > 0 && value.buffered.isNotEmpty) {
      var maxEndMs = 0;
      for (final range in value.buffered) {
        final endMs = range.end.inMilliseconds;
        if (endMs > maxEndMs) maxEndMs = endMs;
      }
      progress = (maxEndMs / totalMs).clamp(0.0, 1.0);
    }
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SizedBox(
        height: 2,
        child: LinearProgressIndicator(
          value: progress,
          backgroundColor: Colors.white24,
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  Widget _buildVideoContent(VideoPlayerController controller) {
    final size = controller.value.size;
    final hasValidSize = size.width > 0 && size.height > 0;

    if (!hasValidSize) {
      return FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: size.width == 0 ? 1 : size.width,
          height: size.height == 0 ? 1 : size.height,
          child: VideoPlayer(controller),
        ),
      );
    }

    final isPortrait = size.height > size.width;
    final fit = isPortrait ? BoxFit.cover : BoxFit.contain;

    return FittedBox(
      fit: fit,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: VideoPlayer(controller),
      ),
    );
  }

  Widget _buildRetryUi() => Center(
      child: GestureDetector(
        onTap: _retryLoad,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.refresh,
                color: Colors.white,
                size: 32,
              ),
              SizedBox(height: 10),
              Text(
                'Video failed to load',
                style: TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Tap to retry',
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
}
