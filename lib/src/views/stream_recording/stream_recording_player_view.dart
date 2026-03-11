import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/res/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'recording_video_cache_manager.dart';
import 'widgets/video_player_widget.dart';

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
  int _currentIndex = 0;
  bool _showOverlay = true;

  final RecordingVideoCacheManager _cacheManager =
      RecordingVideoCacheManager.instance;
  final Map<int, GlobalKey> _pageKeys = {};

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
      _preloadAround(_currentIndex);
      _config.onLoaded?.call(context, _currentRecording);
    });
  }

  void _onPageChanged(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    _preloadAround(index);
  }

  void _togglePlayPause() {
    final key = _pageKeys[_currentIndex];
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
                _pageKeys[index] ??= GlobalKey();
                return _RecordingPage(
                  recording: recording,
                  isActive: isActive,
                  playerKey: _pageKeys[index]!,
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
                  videoController: null,
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
                    isPlaying: _pageKeys[_currentIndex] != null
                        ? (IsmLiveRecordingAutoVideoPlayer.of(
                                    _pageKeys[_currentIndex]!)
                                ?.isPlaying ??
                            false)
                        : false,
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
    required this.isActive,
    required this.playerKey,
    required this.onTap,
  });

  final IsmLiveStreamRecordingItem recording;
  final bool isActive;
  final GlobalKey playerKey;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: isActive && recording.recordedUrls.isNotEmpty
            ? IsmLiveRecordingAutoVideoPlayer(
                key: playerKey,
                url: recording.recordedUrls.first,
              )
            : const ColoredBox(color: Colors.black),
      );
}
