part of '../live_delegate.dart';

/// Callback for handling any control option tap
/// Allows host apps to customize any control button behavior
/// - Custom control button functionality
/// - Integration with external services
/// - Custom permission checks
/// - Host-specific control features
///
/// [context] - The build context where the tap occurred
/// [option] - The control option that was tapped
/// [streamId] - The current stream ID
/// [isHost] - Whether the current user is the host
/// [isCopublishing] - Whether the user is copublishing
///
/// Return true if the host app handled the click and wants to prevent the default behavior,
/// false if the host app wants the SDK to handle it with the default behavior.
typedef ControlOptionCallback = Future<bool> Function(
  BuildContext context,
  IsmLiveStreamOption option,
  String streamId,
  bool isHost,
  bool isCopublishing,
);

/// Builder for custom control widgets
/// Allows host apps to replace default control widgets with custom ones
///
/// [context] - The build context
/// [option] - The control option
/// [onTap] - The tap callback
/// [isHost] - Whether the current user is the host
/// [isCopublishing] - Whether the user is copublishing
/// [streamId] - The current stream ID
///
/// Return a custom widget or null to use the default widget
typedef ControlWidgetBuilder = Widget? Function(
  BuildContext context,
  IsmLiveStreamOption option,
  VoidCallback onTap,
  bool isHost,
  bool isCopublishing,
  String streamId,
);

/// Bottom inset in logical pixels for the product-stream side options column
/// (vertical control strip). Used only when [IsmLiveDelegate.productStream] is
/// true, the keyboard is closed, and the stream is not in schedule mode.
///
/// Return a non-negative value to set the bottom [EdgeInsets] margin. Return
/// `null` to use the SDK default (28% of [MediaQuery] screen height).
///
/// Set via `IsmLiveApp.configureInterface(sideIconsConfigure:
/// IsmLiveSideIconsConfigure(productStreamSideOptionsBottomMargin: â€¦))`.
/// When the delegate field is `null`, the default fraction is applied without calling this.
typedef ProductStreamSideOptionsBottomMarginBuilder = double? Function(
  BuildContext context,
);

/// Horizontal alignment for the right-side stream control icons.
enum IsmLiveSideIconsHorizontalAlignment {
  start,
  center,
  end,
}

/// Configuration for right-side stream control icons.
///
/// Use this object in `IsmLiveApp.configureInterface(sideIconsConfigure: ...)`
/// to customize width, horizontal alignment, control option styling, and
/// related side-icon behavior.
class IsmLiveSideIconsConfigure {
  const IsmLiveSideIconsConfigure({
    this.width,
    this.horizontalAlignment = IsmLiveSideIconsHorizontalAlignment.end,
    this.viewersOptions = const [],
    this.hostOptions = const [],
    this.rtmpOptions = const [],
    this.copublisherOptions = const [],
    this.pkOptions = const [],
    this.controlOptionCallback,
    this.controlWidgetBuilder,
    this.productStreamSideOptionsBottomMargin,
    this.controlOptionBgGradient,
  });

  /// Width of side icons container in logical pixels.
  ///
  /// If null, SDK fallback width is used.
  final double? width;

  /// Horizontal alignment of icons inside the side icons container.
  final IsmLiveSideIconsHorizontalAlignment horizontalAlignment;

  /// Side icons shown to viewers.
  final List<IsmLiveStreamOption> viewersOptions;

  /// Side icons shown to host users.
  final List<IsmLiveStreamOption> hostOptions;

  /// Side icons shown in RTMP streams.
  final List<IsmLiveStreamOption> rtmpOptions;

  /// Side icons shown to copublishers.
  final List<IsmLiveStreamOption> copublisherOptions;

  /// Side icons shown in PK streams.
  final List<IsmLiveStreamOption> pkOptions;

  /// Unified side-icon tap callback.
  final ControlOptionCallback? controlOptionCallback;

  /// Custom side-icon widget builder.
  final ControlWidgetBuilder? controlWidgetBuilder;

  /// Custom bottom margin for side options in product stream mode.
  final ProductStreamSideOptionsBottomMarginBuilder?
      productStreamSideOptionsBottomMargin;

  /// Background gradient for stream control option buttons and message field.
  final LinearGradient? controlOptionBgGradient;

  IsmLiveSideIconsConfigure copyWith({
    double? width,
    IsmLiveSideIconsHorizontalAlignment? horizontalAlignment,
    List<IsmLiveStreamOption>? viewersOptions,
    List<IsmLiveStreamOption>? hostOptions,
    List<IsmLiveStreamOption>? rtmpOptions,
    List<IsmLiveStreamOption>? copublisherOptions,
    List<IsmLiveStreamOption>? pkOptions,
    ControlOptionCallback? controlOptionCallback,
    ControlWidgetBuilder? controlWidgetBuilder,
    ProductStreamSideOptionsBottomMarginBuilder?
        productStreamSideOptionsBottomMargin,
    LinearGradient? controlOptionBgGradient,
  }) =>
      IsmLiveSideIconsConfigure(
        width: width ?? this.width,
        horizontalAlignment: horizontalAlignment ?? this.horizontalAlignment,
        viewersOptions: viewersOptions ?? this.viewersOptions,
        hostOptions: hostOptions ?? this.hostOptions,
        rtmpOptions: rtmpOptions ?? this.rtmpOptions,
        copublisherOptions: copublisherOptions ?? this.copublisherOptions,
        pkOptions: pkOptions ?? this.pkOptions,
        controlOptionCallback:
            controlOptionCallback ?? this.controlOptionCallback,
        controlWidgetBuilder:
            controlWidgetBuilder ?? this.controlWidgetBuilder,
        productStreamSideOptionsBottomMargin:
            productStreamSideOptionsBottomMargin ??
                this.productStreamSideOptionsBottomMargin,
        controlOptionBgGradient:
            controlOptionBgGradient ?? this.controlOptionBgGradient,
      );
}