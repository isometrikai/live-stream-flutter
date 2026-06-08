part of '../live_delegate.dart';

/// Configuration class for GoLive screen customization.
///
/// This class provides a centralized way to configure GoLive screen components
/// including header builder, button builder, text styles, icons, and future GoLive-related features.
/// Similar to IsmLiveEcomConfigure, this allows for better organization and
/// extensibility of GoLive screen configuration.
class IsmLiveGoLiveScreenConfigure {
  const IsmLiveGoLiveScreenConfigure({
    this.isHdStreamFeatureEnabled,
    this.isScheduleStreamFeatureEnabled,
    this.isProductStreamFeatureEnabled,
    this.isRtmpStreamFeatureEnabled,
    this.isRestreamStreamFeatureEnabled,
    this.isPaidStreamFeatureEnabled,
    this.isMultiLiveStreamFeatureEnabled,
    this.isRecordedStreamFeatureEnabled,
    this.onGoLiveButtonTap,
    this.onGoLiveViewDispose,
    this.goLiveHeaderBuilder,
    this.goLiveButtonBuilder,
    this.scheduleStreamCenterOverlayBuilder,
    this.onScheduleLiveToggle,
    this.defaultHdBroadcastToggleValue,
    this.defaultRecordBroadcastToggleValue,
    this.defaultRestreamBroadcastToggleValue,
    this.defaultBroadcastDescription,
    this.radioTileTextStyle,
    this.addCoverTextStyle,
    this.addIcon,
    this.tabSelectedTextStyle,
    this.tabUnselectedTextStyle,
    this.titleTextStyle,
  });

  /// Custom header builder for the GoLive screen.
  ///
  /// If provided, this will replace the default header in the GoLive view.
  /// The builder receives the context and stream controller for customization.
  final GoLiveHeaderBuilder? goLiveHeaderBuilder;

  /// Feature flag to show/hide HD stream support in UI.
  final bool? isHdStreamFeatureEnabled;

  /// Feature flag to show/hide schedule stream support in UI.
  final bool? isScheduleStreamFeatureEnabled;

  /// Feature flag to show/hide product stream support in UI.
  final bool? isProductStreamFeatureEnabled;

  /// Feature flag to show/hide RTMP stream support in UI.
  final bool? isRtmpStreamFeatureEnabled;

  /// Feature flag to show/hide restream support in UI.
  final bool? isRestreamStreamFeatureEnabled;

  /// Feature flag to show/hide paid stream support in UI.
  final bool? isPaidStreamFeatureEnabled;

  /// Feature flag to show/hide multi-live support in UI.
  final bool? isMultiLiveStreamFeatureEnabled;

  /// Feature flag to show/hide recorded stream support in UI.
  final bool? isRecordedStreamFeatureEnabled;

  /// Callback for GoLive button click.
  final GoLiveClickCallback? onGoLiveButtonTap;

  /// Callback for GoLive screen dispose.
  final GoLiveDisposeCallback? onGoLiveViewDispose;

  /// Custom button builder for the GoLive screen.
  ///
  /// If provided, this will replace the default GoLive button/navigation bar.
  /// The builder receives context, stream controller, onGoLivePressed callback,
  /// and isEnabled state for proper customization.
  final GoLiveButtonBuilder? goLiveButtonBuilder;

  /// Optional callback invoked when `Schedule Live` toggle value changes.
  final ScheduleLiveToggleCallback? onScheduleLiveToggle;

  /// Custom centered overlay builder for scheduled stream view.
  ///
  /// If provided, this widget is rendered in the center of the scheduled
  /// stream overlay while preserving the SDK's existing layout and controls.
  final ScheduleStreamCenterOverlayBuilder? scheduleStreamCenterOverlayBuilder;

  /// Optional default value for `HD Broadcast` toggle on fresh GoLive flow.
  ///
  /// This is ignored while editing an existing/scheduled stream.
  final bool? defaultHdBroadcastToggleValue;

  /// Optional default value for `Record Broadcast` toggle on fresh GoLive flow.
  ///
  /// This is ignored while editing an existing/scheduled stream.
  final bool? defaultRecordBroadcastToggleValue;

  /// Optional default value for `Restream Broadcast` toggle on fresh GoLive flow.
  ///
  /// This is ignored while editing an existing/scheduled stream.
  final bool? defaultRestreamBroadcastToggleValue;

  /// Optional default text for the stream description on a fresh GoLive flow.
  ///
  /// This is ignored while editing an existing/scheduled stream.
  final String? defaultBroadcastDescription;

  /// Custom text style for radio tile components (switches, toggles).
  ///
  /// If provided, this function will be called to generate text styles for text elements
  /// in IsmLiveRadioListTile and similar radio/toggle components in the GoLive screen.
  /// The function receives the context and isDark parameter to allow theme-aware styling.
  /// If not provided, the default text style will be used.
  final TextStyle Function(BuildContext context, bool isDark)?
      radioTileTextStyle;

  /// Custom text style for "Add cover" and similar action text elements.
  ///
  /// If provided, this will be used for action text elements like "Add cover",
  /// "Add description", and similar interactive text elements in the GoLive screen.
  /// If not provided, the default text style will be used.
  final TextStyle? addCoverTextStyle;

  /// Custom icon for "Add" actions in GoLive screen.
  ///
  /// If provided, this will be used for add action icons like "Add Cover",
  /// "Add products", and similar interactive elements in the GoLive screen.
  /// If not provided, the default Icons.add_circle_outline_rounded will be used.
  final IconData? addIcon;

  /// Custom text style for selected bottom tab label in GoLive screen.
  ///
  /// If provided, this style will be applied to the selected tab text in the
  /// bottom tab selector (e.g., "Go Live", "Live from device").
  final TextStyle? tabSelectedTextStyle;

  /// Custom text style for unselected bottom tab label in GoLive screen.
  ///
  /// If provided, this style will be applied to the unselected tab text in the
  /// bottom tab selector.
  final TextStyle? tabUnselectedTextStyle;

  /// Custom text style for title elements in GoLive screen.
  ///
  /// If provided, this style will be applied to title text elements in the
  /// GoLive screen such as main titles, section headers, and other prominent text.
  /// If not provided, the default text style will be used.
  final TextStyle? titleTextStyle;

  IsmLiveGoLiveScreenConfigure copyWith({
    bool? isHdStreamFeatureEnabled,
    bool? isScheduleStreamFeatureEnabled,
    bool? isProductStreamFeatureEnabled,
    bool? isRtmpStreamFeatureEnabled,
    bool? isRestreamStreamFeatureEnabled,
    bool? isPaidStreamFeatureEnabled,
    bool? isMultiLiveStreamFeatureEnabled,
    bool? isRecordedStreamFeatureEnabled,
    GoLiveClickCallback? onGoLiveButtonTap,
    GoLiveDisposeCallback? onGoLiveViewDispose,
    GoLiveHeaderBuilder? goLiveHeaderBuilder,
    GoLiveButtonBuilder? goLiveButtonBuilder,
    ScheduleStreamCenterOverlayBuilder? scheduleStreamCenterOverlayBuilder,
    ScheduleLiveToggleCallback? onScheduleLiveToggle,
    bool? defaultHdBroadcastToggleValue,
    bool? defaultRecordBroadcastToggleValue,
    bool? defaultRestreamBroadcastToggleValue,
    String? defaultBroadcastDescription,
    TextStyle Function(BuildContext context, bool isDark)? radioTileTextStyle,
    TextStyle? addCoverTextStyle,
    IconData? addIcon,
    TextStyle? tabSelectedTextStyle,
    TextStyle? tabUnselectedTextStyle,
    TextStyle? titleTextStyle,
  }) =>
      IsmLiveGoLiveScreenConfigure(
        isHdStreamFeatureEnabled:
            isHdStreamFeatureEnabled ?? this.isHdStreamFeatureEnabled,
        isScheduleStreamFeatureEnabled: isScheduleStreamFeatureEnabled ??
            this.isScheduleStreamFeatureEnabled,
        isProductStreamFeatureEnabled:
            isProductStreamFeatureEnabled ?? this.isProductStreamFeatureEnabled,
        isRtmpStreamFeatureEnabled:
            isRtmpStreamFeatureEnabled ?? this.isRtmpStreamFeatureEnabled,
        isRestreamStreamFeatureEnabled: isRestreamStreamFeatureEnabled ??
            this.isRestreamStreamFeatureEnabled,
        isPaidStreamFeatureEnabled:
            isPaidStreamFeatureEnabled ?? this.isPaidStreamFeatureEnabled,
        isMultiLiveStreamFeatureEnabled: isMultiLiveStreamFeatureEnabled ??
            this.isMultiLiveStreamFeatureEnabled,
        isRecordedStreamFeatureEnabled: isRecordedStreamFeatureEnabled ??
            this.isRecordedStreamFeatureEnabled,
        onGoLiveButtonTap: onGoLiveButtonTap ?? this.onGoLiveButtonTap,
        onGoLiveViewDispose: onGoLiveViewDispose ?? this.onGoLiveViewDispose,
        goLiveHeaderBuilder: goLiveHeaderBuilder ?? this.goLiveHeaderBuilder,
        goLiveButtonBuilder: goLiveButtonBuilder ?? this.goLiveButtonBuilder,
        scheduleStreamCenterOverlayBuilder:
            scheduleStreamCenterOverlayBuilder ??
                this.scheduleStreamCenterOverlayBuilder,
        onScheduleLiveToggle: onScheduleLiveToggle ?? this.onScheduleLiveToggle,
        defaultHdBroadcastToggleValue:
            defaultHdBroadcastToggleValue ?? this.defaultHdBroadcastToggleValue,
        defaultRecordBroadcastToggleValue: defaultRecordBroadcastToggleValue ??
            this.defaultRecordBroadcastToggleValue,
        defaultRestreamBroadcastToggleValue:
            defaultRestreamBroadcastToggleValue ??
                this.defaultRestreamBroadcastToggleValue,
        defaultBroadcastDescription:
            defaultBroadcastDescription ?? this.defaultBroadcastDescription,
        radioTileTextStyle: radioTileTextStyle ?? this.radioTileTextStyle,
        addCoverTextStyle: addCoverTextStyle ?? this.addCoverTextStyle,
        addIcon: addIcon ?? this.addIcon,
        tabSelectedTextStyle: tabSelectedTextStyle ?? this.tabSelectedTextStyle,
        tabUnselectedTextStyle:
            tabUnselectedTextStyle ?? this.tabUnselectedTextStyle,
        titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      );
}