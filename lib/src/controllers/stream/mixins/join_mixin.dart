part of '../stream_controller.dart';

// Shared join-stream utilities: video presets, orchestration entry points.
mixin StreamJoinMixin {
  // Get references to the necessary controllers and wrappers using Get.find()
  IsmLiveStreamController get _controller => Get.find();
  IsmLiveDBWrapper get _dbWrapper => Get.find();

  // Check if Go Live is enabled by checking if the description controller is not empty
  bool get isGoLiveEnabled => _controller.descriptionController.isNotEmpty;

  // ---------------------------------------------------------------------------
  // Shared video quality presets
  //
  // NOTE:
  // - Use ONE source of truth for dimensions/bitrates across:
  //   - camera capture (manual track creation)
  //   - room default capture options
  //   - publish options / simulcast layers
  // ---------------------------------------------------------------------------

  // HD: 1080p portrait, 30fps ~6Mbps (industry-standard live baseline)
  static const lk.VideoParameters _lkHdVideoParams = lk.VideoParameters(
    dimensions: // lk.VideoDimensions(1080, 1920),
        lk.VideoDimensionsPresets.h1080_169,
    encoding: lk.VideoEncoding(
      maxFramerate: 30,
      maxBitrate: 6000 * 1000,
    ),
  );

  // SD: 30fps ~3Mbps
  static const lk.VideoParameters _lkSdVideoParams = lk.VideoParameters(
    dimensions: // lk.VideoDimensions(720, 1280),
        lk.VideoDimensionsPresets.h720_169,
    encoding: lk.VideoEncoding(
      maxFramerate: 25,
      maxBitrate: 2500 * 1000,
    ),
  );

  /// Restream: quality between SD and full HD, tuned for external platforms.
  static const lk.VideoParameters _lkRestreamVideoParams = lk.VideoParameters(
    dimensions: // lk.VideoDimensions(720, 1280),
        lk.VideoDimensionsPresets.h720_169,
    encoding: lk.VideoEncoding(
      maxFramerate: 30,
      maxBitrate: 4000 * 1000,
    ),
  );

  IsmLiveVideoPublishConfig? get _videoPublishConfig =>
      IsmLiveDelegate.goLiveScreenConfigure?.videoPublishConfig;

  lk.VideoParameters _resolveLkVideoParams({
    required bool hdBroadcast,
    required bool restream,
  }) {
    final base = hdBroadcast
        ? _lkHdVideoParams
        : restream
            ? _lkRestreamVideoParams
            : _lkSdVideoParams;
    final profile = _videoPublishConfig?.profileFor(
      hdBroadcast: hdBroadcast,
      restream: restream,
    );
    if (profile == null) return base;

    final applied = profile.applyOn(
      IsmLiveVideoEncode(
        maxBitrate: base.encoding!.maxBitrate,
        maxFramerate: base.encoding!.maxFramerate,
        width: base.dimensions.width,
        height: base.dimensions.height,
      ),
    );
    return lk.VideoParameters(
      dimensions: lk.VideoDimensions(applied.width, applied.height),
      encoding: lk.VideoEncoding(
        maxBitrate: applied.maxBitrate,
        maxFramerate: applied.maxFramerate,
      ),
    );
  }

  /// Lower layers from the host app. Empty keeps LiveKit's default ladder.
  List<lk.VideoParameters> _resolveLkSimulcastLayers() {
    final config = _videoPublishConfig;
    if (config == null || config.simulcastLayers.isEmpty) {
      return const [];
    }
    final usable = config.usableSimulcastLayers;
    if (usable.length != config.simulcastLayers.length) {
      IsmLiveLog.error(
        'Dropped ${config.simulcastLayers.length - usable.length} '
        'video simulcast layer(s) missing width, height, or maxBitrate',
      );
    }
    return [
      for (final layer in usable)
        lk.VideoParameters(
          dimensions: lk.VideoDimensions(layer.width!, layer.height!),
          encoding: lk.VideoEncoding(
            maxBitrate: layer.maxBitrate!,
            maxFramerate:
                (layer.maxFramerate != null && layer.maxFramerate! > 0)
                    ? layer.maxFramerate!
                    : 15,
          ),
        ),
    ];
  }

  bool isScheduleStreamNotStartedYet(IsmLiveStreamDataModel stream) {
    if (stream.isScheduledStream == true &&
        (stream.streamId == null ||
            stream.streamId?.isEmpty == true ||
            stream.streamId?.contains('0000') == true)) {
      return true;
    }
    return false;
  }

// Initialize the page controller
  void initialize(int index) {
    _controller.pageController = PageController(
      initialPage: index,
    );
  }
}