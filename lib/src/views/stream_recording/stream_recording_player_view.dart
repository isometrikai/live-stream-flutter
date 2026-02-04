import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/res/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

/// Full-screen stream recording player with vertical swipe between recordings.
///
/// Uses [config] if provided, otherwise [IsmLiveDelegate.streamRecordingPlayerConfig].
/// Host app can open via [IsmLiveApp.openStreamRecordingPlayer] or
/// [IsmLiveRouteManagement.goToStreamRecordingPlayer].
class IsmLiveStreamRecordingPlayerView extends StatefulWidget {
  const IsmLiveStreamRecordingPlayerView({
    super.key,
    required this.recordings,
    this.initialIndex = 0,
    this.config,
  });

  static const String route = IsmLiveRoutes.streamRecordingPlayer;

  /// List of recording items; [initialIndex] selects the first visible.
  final List<IsmLiveStreamRecordingItem> recordings;

  /// Initial page index.
  final int initialIndex;

  /// Optional config. If null, uses [IsmLiveDelegate.streamRecordingPlayerConfig].
  final IsmLiveStreamRecordingPlayerConfig? config;

  @override
  State<IsmLiveStreamRecordingPlayerView> createState() =>
      _IsmLiveStreamRecordingPlayerViewState();
}

class _IsmLiveStreamRecordingPlayerViewState
    extends State<IsmLiveStreamRecordingPlayerView> {
  late PageController _pageController;
  VideoPlayerController? _videoController;
  final Map<int, VideoPlayerController> _preloadedControllers = {};
  int _currentIndex = 0;
  bool _showOverlay = true;

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _initCurrentPage());
  }

  Future<void> _initCurrentPage() async {
    if (widget.recordings.isEmpty) return;
    final recording = _currentRecording;
    final urls = recording.recordedUrls;
    if (urls.isEmpty) return;

    final url = urls.first;
    final oldController = _videoController;

    // Use preloaded controller if it matches current page to avoid any loading flash.
    final preloaded = _preloadedControllers[_currentIndex];
    if (preloaded != null &&
        preloaded.value.isInitialized &&
        _urlForRecording(recording) == url) {
      _preloadedControllers.remove(_currentIndex);
      await oldController?.dispose();
      _disposePreloadedExcept(null);
      _videoController = preloaded;
      if (mounted) {
        setState(() {});
        await _videoController!.play();
      }
      _preloadAdjacent();
      _config.onLoaded?.call(context, recording);
      return;
    }

    // Build new controller without clearing current — keeps previous video visible until new is ready (no blink).
    final newController = VideoPlayerController.networkUrl(Uri.parse(url));
    await newController.initialize();
    if (!mounted) return;
    await newController.play();
    if (!mounted) return;

    _videoController = newController;
    if (mounted) setState(() {});
    await oldController?.dispose();
    _disposePreloadedExcept(null);
    _preloadAdjacent();

    _config.onLoaded?.call(context, recording);
  }

  static String? _urlForRecording(IsmLiveStreamRecordingItem r) {
    final urls = r.recordedUrls;
    return urls.isEmpty ? null : urls.first;
  }

  void _disposePreloadedExcept(int? keepIndex) {
    for (final entry in _preloadedControllers.entries.toList()) {
      if (entry.key != keepIndex) {
        entry.value.dispose();
        _preloadedControllers.remove(entry.key);
      }
    }
  }

  void _preloadAdjacent() {
    final n = widget.recordings.length;
    if (n == 0) return;
    final nextIndex = _currentIndex + 1;
    final prevIndex = _currentIndex - 1;
    if (nextIndex < n && !_preloadedControllers.containsKey(nextIndex)) {
      _preloadIndex(nextIndex);
    }
    if (prevIndex >= 0 && !_preloadedControllers.containsKey(prevIndex)) {
      _preloadIndex(prevIndex);
    }
  }

  Future<void> _preloadIndex(int index) async {
    if (index < 0 || index >= widget.recordings.length) return;
    final recording = widget.recordings[index];
    final url = _urlForRecording(recording);
    if (url == null) return;
    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      await controller.initialize();
      if (!mounted) {
        controller.dispose();
        return;
      }
      _preloadedControllers[index] = controller;
    } catch (_) {
      // Ignore preload failures; page will load on demand.
    }
  }

  Future<void> _disposeVideo() async {
    await _videoController?.dispose();
    _videoController = null;
    for (final c in _preloadedControllers.values) {
      await c.dispose();
    }
    _preloadedControllers.clear();
  }

  void _onPageChanged(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    // Defer init so the widget tree rebuilds with null controller before we dispose the old one.
    WidgetsBinding.instance.addPostFrameCallback((_) => _initCurrentPage());
  }

  void _togglePlayPause() {
    if (_videoController == null) return;
    if (_videoController!.value.isPlaying) {
      _videoController!.pause();
    } else {
      _videoController!.play();
    }
    setState(() {});
  }

  void _onClose() {
    Navigator.of(context).maybePop();
  }

  @override
  void dispose() {
    _disposeVideo();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = _config;
    if (widget.recordings.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Recording')),
        body: const Center(child: Text('No recordings')),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              itemCount: widget.recordings.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                final recording = widget.recordings[index];
                final isActive = index == _currentIndex;
                return _RecordingPage(
                  recording: recording,
                  videoController: isActive ? _videoController : null,
                  onTap: () {
                    setState(() => _showOverlay = !_showOverlay);
                  },
                );
              },
            ),
            if (_showOverlay) ...[
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IsmLiveStreamRecordingTopControls(
                  recording: _currentRecording,
                  config: config,
                  onClose: _onClose,
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: IsmLiveStreamRecordingBottomControls(
                  videoController: _videoController,
                  onPlayPause: _togglePlayPause,
                ),
              ),
              Positioned(
                right: 8,
                top: 0,
                bottom: 0,
                child: Center(
                  child: IsmLiveStreamRecordingRightControls(
                    config: config,
                    recording: _currentRecording,
                  ),
                ),
              ),
              Center(
                child: GestureDetector(
                  onTap: _togglePlayPause,
                  child: IsmLiveStreamRecordingCenterPlayButton(
                    isPlaying: _videoController?.value.isPlaying ?? false,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecordingPage extends StatelessWidget {
  const _RecordingPage({
    required this.recording,
    required this.videoController,
    required this.onTap,
  });

  final IsmLiveStreamRecordingItem recording;
  final VideoPlayerController? videoController;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: IsmLiveStreamRecordingVideoWidget(
          controller: videoController,
        ),
      );
}
