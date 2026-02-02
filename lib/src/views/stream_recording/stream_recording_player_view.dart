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

    // Clear controller from widget tree first so no widget holds it, then dispose.
    final oldController = _videoController;
    _videoController = null;
    if (mounted) setState(() {});
    await oldController?.dispose();

    final url = urls.first;
    _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
    await _videoController!.initialize();
    if (!mounted) return;
    await _videoController!.play();
    if (mounted) setState(() {});

    IsmLiveDelegate.streamRecordingPlayerLoadedCallback
        ?.call(context, recording);
  }

  Future<void> _disposeVideo() async {
    await _videoController?.dispose();
    _videoController = null;
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
