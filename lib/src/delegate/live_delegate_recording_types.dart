part of '../live_delegate.dart';

/// Control option types for the Stream Recording Player.
/// Used by [IsmLiveStreamRecordingPlayerConfig.onControlOption].
enum IsmLiveStreamRecordingControlOption {
  product,
  share,
  settings,
  deleteStream,
  reportStream,
  navigateToCart,
  navigateToSocialPost,
  openUserProfile,
}

/// Slots in the Stream Recording Player UI that can be overridden by the host.
///
/// Use [IsmLiveStreamRecordingPlayerConfig.controlWidgetBuilder] to replace
/// a specific widget while keeping the rest of the SDK layout intact.
enum IsmLiveStreamRecordingControlWidgetSlot {
  // Top controls
  topProfile,
  topCart,
  topClose,

  // Right controls
  rightProduct,
  rightShare,
  rightSettings,

  // Bottom controls
  bottomPlayPause,
  bottomSeekBar,
  bottomDuration,
}

/// Called when the user triggers a control action in the recording player.
/// [option] identifies the action (product, share, delete, etc.).
typedef IsmLiveStreamRecordingControlOptionCallback = FutureOr<void> Function(
  BuildContext context,
  IsmLiveStreamRecordingControlOption option,
  IsmLiveStreamRecordingItem recording,
);

/// Builder that can override specific widgets in the Stream Recording Player.
///
/// Return `null` to keep [defaultChild].
typedef IsmLiveStreamRecordingControlWidgetBuilder = Widget? Function(
  BuildContext context,
  IsmLiveStreamRecordingControlWidgetSlot slot,
  IsmLiveStreamRecordingItem recording,
  IsmLiveStreamRecordingPlayerConfig config,
  Widget defaultChild, {
  VoidCallback? onTap,
  VideoPlayerController? videoController,
});

/// Builder for the top controls in the Stream Recording Player.
typedef IsmLiveStreamRecordingTopControlsBuilder = Widget Function(
  BuildContext context,
  IsmLiveStreamRecordingItem recording,
  IsmLiveStreamRecordingPlayerConfig config,
  VoidCallback onClose,
);

/// Builder for the bottom controls in the Stream Recording Player.
typedef IsmLiveStreamRecordingBottomControlsBuilder = Widget Function(
  BuildContext context,
  IsmLiveStreamRecordingItem recording,
  IsmLiveStreamRecordingPlayerConfig config,
  VideoPlayerController? videoController,
  VoidCallback onPlayPause,
);

/// Builder for the right controls in the Stream Recording Player.
typedef IsmLiveStreamRecordingRightControlsBuilder = Widget Function(
  BuildContext context,
  IsmLiveStreamRecordingItem recording,
  IsmLiveStreamRecordingPlayerConfig config,
);

/// Configuration for the Stream Recording Player.
///
/// Use [onLoaded] for initial-load logic (e.g. record view count, fetch products).
/// Use [onControlOption] for all control actions (product, share, more, etc.).
class IsmLiveStreamRecordingPlayerConfig {
  const IsmLiveStreamRecordingPlayerConfig({
    this.getCurrentUserId,
    this.onLoaded,
    this.onControlOption,
    this.controlWidgetBuilder,
    this.topControlsBuilder,
    this.bottomControlsBuilder,
    this.rightControlsBuilder,
  });

  /// Optional. For "my stream" vs others.
  final String? Function()? getCurrentUserId;

  /// Optional. Called when a recording has loaded and started playing (initial or after swipe).
  /// Host can perform initial API calls here (e.g. record view count, fetch products).
  final StreamRecordingPlayerLoadedCallback? onLoaded;

  /// Optional. Single handler for control option taps (product, share, settings,
  /// deleteStream, reportStream, navigateToCart, navigateToSocialPost, openUserProfile).
  final IsmLiveStreamRecordingControlOptionCallback? onControlOption;

  /// Optional. Override individual control widgets (top/bottom/right) without
  /// replacing the whole controls widget.
  final IsmLiveStreamRecordingControlWidgetBuilder? controlWidgetBuilder;

  /// Optional. If provided, replaces [IsmLiveStreamRecordingTopControls] widget.
  final IsmLiveStreamRecordingTopControlsBuilder? topControlsBuilder;

  /// Optional. If provided, replaces [IsmLiveStreamRecordingBottomControls] widget.
  final IsmLiveStreamRecordingBottomControlsBuilder? bottomControlsBuilder;

  /// Optional. If provided, replaces [IsmLiveStreamRecordingRightControls] widget.
  final IsmLiveStreamRecordingRightControlsBuilder? rightControlsBuilder;
}
