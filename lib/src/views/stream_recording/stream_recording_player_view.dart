import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

/// Full-screen stream recording player with vertical swipe between recordings.
///
/// Uses [config] if provided, otherwise [IsmLiveDelegate.streamRecordingPlayerConfig].
/// Requires [IsmLiveStreamRecordingPlayerConfig.onRecordViewCount] and
/// [IsmLiveStreamRecordingPlayerConfig.onFetchStreamProducts] to be set.
class IsmLiveStreamRecordingPlayerView extends StatefulWidget {
  const IsmLiveStreamRecordingPlayerView({
    super.key,
    required this.recordings,
    this.initialIndex = 0,
    this.config,
  });

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
  List<IsmLiveStreamRecordingProduct> _products = [];
  bool _productsHasMore = false;
  int _productsPage = 1;
  bool _showOverlay = true;
  Timer? _overlayTimer;
  bool _isLoadingProducts = false;

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
    _startOverlayTimer();
  }

  void _startOverlayTimer() {
    _overlayTimer?.cancel();
    _overlayTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _showOverlay) {
        setState(() => _showOverlay = false);
      }
    });
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

    final config = _config;
    unawaited(config.onRecordViewCount(recording.streamId));
    await _fetchProducts(recording.streamId, 1, null);
  }

  Future<void> _fetchProducts(String streamId, int page, String? q) async {
    final config = _config;
    if (_isLoadingProducts) return;
    _isLoadingProducts = true;
    if (mounted) setState(() {});
    try {
      final list = await config.onFetchStreamProducts(streamId, page, q);
      if (!mounted) return;
      setState(() {
        if (page == 1) {
          _products = list.items;
        } else {
          _products = [..._products, ...list.items];
        }
        _productsHasMore = list.hasMore;
        _productsPage = list.page;
        _isLoadingProducts = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() => _isLoadingProducts = false);
      }
    }
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
    _showOverlay = true;
    _startOverlayTimer();
  }

  void _onClose() {
    Navigator.of(context).maybePop();
  }

  @override
  void dispose() {
    _overlayTimer?.cancel();
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
                    if (_showOverlay) _startOverlayTimer();
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
                  products: _products,
                  onPlayPause: _togglePlayPause,
                  onAllProducts: () => _showAllProductsSheet(context),
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
                    products: _products,
                    onAllProducts: () => _showAllProductsSheet(context),
                    onMore: () => _showMoreOptionsSheet(context),
                    onFollow: () => _showFollowUserSheet(context),
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

  void _showAllProductsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => IsmLiveStreamRecordingAllProductsSheet(
        products: _products,
        hasMore: _productsHasMore,
        page: _productsPage,
        onLoadMore: () => _fetchProducts(
          _currentRecording.streamId,
          _productsPage + 1,
          null,
        ),
        config: _config,
        recording: _currentRecording,
      ),
    );
  }

  void _showMoreOptionsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => IsmLiveStreamRecordingMoreOptionsSheet(
        recording: _currentRecording,
        config: _config,
        onClose: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  void _showFollowUserSheet(BuildContext context) {
    final userId = _currentRecording.userId;
    if (userId == null || userId.isEmpty) return;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => IsmLiveStreamRecordingFollowUserSheet(
        recording: _currentRecording,
        config: _config,
        onClose: () => Navigator.of(ctx).pop(),
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
