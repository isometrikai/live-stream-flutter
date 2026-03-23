import 'dart:async';

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
    this.isMuted = false,
    this.onProgress,
    this.onCompleted,
    this.onControllerReady,
  });

  final String url;
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
  Timer? _stuckTimer;
  int _recoveryAttempts = 0;
  static const int _maxRecoveryAttempts = 5;

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
    _initializeIfNeeded();
  }

  @override
  void didUpdateWidget(IsmLiveRecordingAutoVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) {
      _initializeIfNeeded();
    }
    if (oldWidget.isMuted != widget.isMuted &&
        _controller != null &&
        _controller!.value.isInitialized) {
      _controller!.setVolume(widget.isMuted ? 0.0 : 1.0);
    }
  }

  Future<void> _initializeIfNeeded() async {
    if (_isInitializing || widget.url.isEmpty) return;
    _isInitializing = true;
    setState(() {});
    try {
      final controller = await _cache.getOrCreate(widget.url);
      if (_isDisposed) {
        await controller.dispose();
        return;
      }
      _attachController(controller);
      if (mounted) {
        setState(() {});
      }
      if (_isVisible && !_isManuallyPaused) {
        _playInternal();
      }
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
    final position = _controller!.value.position;
    final total = _controller!.value.duration;

    if (now - _lastProgressMillis >= 200) {
      _lastProgressMillis = now;
      widget.onProgress?.call(total, position);
    }

    // Detect completion with a small threshold.
    if (total.inMilliseconds > 0 &&
        (total.inMilliseconds - position.inMilliseconds).abs() <= 300) {
      widget.onCompleted?.call();
    }
  }

  void _onVisibilityChanged(VisibilityInfo info) {
    if (_isDisposed) return;
    final wasVisible = _isVisible;
    _isVisible = info.visibleFraction > 0.5;

    if (wasVisible == _isVisible) return;

    if (_controller == null || !_controller!.value.isInitialized) {
      if (_isVisible) {
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
    if (_isVisible) {
      _playInternal();
    }
  }

  Future<void> seekTo(Duration position) async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    await _controller!.seekTo(position);
  }

  void _playInternal() {
    if (_controller == null || !_controller!.value.isInitialized) return;
    _controller!.setVolume(widget.isMuted ? 0.0 : 1.0);
    _controller!.play();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _stopStuckDetection();
    _cache.markNotVisible(widget.url);
    _controller?.removeListener(_handleProgress);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final isReady = controller != null && controller.value.isInitialized;

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
            else
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
          ],
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
}
