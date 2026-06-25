part of '../live_delegate.dart';

/// Builder for a full-width widget at the bottom of the live stream screen,
/// rendered directly below the message input row.
///
/// Return `null` to hide the widget for the current state (e.g. when the
/// keyboard is open).
typedef StreamBottomWidgetBuilder = Widget? Function(
  BuildContext context,
  String streamId,
  bool isHost,
  bool isKeyboardOpen,
);

/// Builder for a custom widget at the end of the live timer row in the stream
/// header (after LIVE label, timer, and coins).
///
/// Only used when [streamHeaderInfoSectionBuilder] returns `null` (default UI).
/// Return `null` to hide the trailing widget.
typedef StreamHeaderTimerTrailingWidgetBuilder = Widget? Function(
  BuildContext context,
  String streamId,
  bool isHost,
  String streamCoins,
  bool isPaidStream,
);

/// Builder that replaces the stream header info section (live timer row and
/// description / PK result banner).
///
/// Return `null` to show the default timer and description UI. Return a widget
/// to show custom content instead. The stream duration timer in
/// [IsmLiveStreamController] keeps running while custom content is shown; only
/// the display is swapped.
typedef StreamHeaderInfoSectionBuilder = Widget? Function(
  BuildContext context,
  String streamId,
  bool isHost,
  String streamCoins,
  bool isPaidStream,
  String description,
  bool pkCompleted,
  bool isBattleTie,
  String? winnerName,
);

/// Builder for the stream overlay gradients that dim the video/grid.
///
/// When set, this single builder replaces the default SDK top + bottom
/// gradients. Return `null` to hide gradients entirely.
typedef StreamGradientOverlayBuilder = Widget? Function(
  BuildContext context,
  String streamId,
  bool isHost,
  bool isSchedule,
);

/// Builder for the message field send action button.
///
/// [disabled] reflects whether the message field is disabled.
/// [messageText] is the current input text from the message field controller.
/// [onSend] invokes the default send-message behavior when sending is allowed.
///
/// [isInsideInputField] is `true` when the send control is rendered as the
/// input suffix icon; `false` when it is rendered beside the input field.
typedef MessageSendButtonBuilder = Widget Function(
  BuildContext context,
  String streamId,
  bool isHost,
  bool disabled,
  String messageText,
  VoidCallback? onSend,
  bool isInsideInputField,
);

/// Handler invoked when the user presses the system back button while on the
/// live stream screen.
///
/// Use this to mirror whatever the top-right cross / end-stream button does in
/// your app — that button can itself be customized via [endButton], so the SDK
/// cannot infer its action automatically. When this handler is `null`, the SDK
/// runs its default end-stream flow (identical to the default cross icon).
typedef StreamBackPressCallback = void Function(
  BuildContext context,
  String streamId,
  bool isHost,
  bool isSchedule,
);

/// Configuration for the live stream screen UI.
///
/// Set via `IsmLiveApp.configureInterface(streamScreenConfigure: ...)`.
class IsmLiveStreamScreenConfigure {
  const IsmLiveStreamScreenConfigure({
    this.streamHeader,
    this.streamBottomBuilder,
    this.inputBuilder,
    this.chatMessageBuilder,
    this.chatItemBgColorCallback,
    this.endButton,
    this.endStreamScreen,
    this.showStreamHeader = true,
    this.streamHeaderPosition,
    this.endStreamWidgetPosition,
    this.logoWidget,
    this.messageProcessCallback,
    this.streamScreenLoadedCallback,
    this.hostTopProfileClickCallback,
    this.goLiveSmallButtonBuilder,
    this.scheduleStreamCenterOverlayBuilder,
    this.cartBuilder,
    this.topViewersListCallback,
    this.moderatorsListCallback,
    this.onStreamScrollCallback,
    this.addCoinsClickCallback,
    this.giftClickCallback,
    this.heartBatchFlushCallback,
    this.useGridLayoutForMultipleParticipants,
    this.showParticipantFullNamesInPublisherGrid,
    this.streamBottomWidgetBuilder,
    this.streamHeaderTimerTrailingWidgetBuilder,
    this.streamHeaderInfoSectionBuilder,
    this.streamGradientOverlayBuilder,
    this.messageSendIconInsideInputField,
    this.messageSendButtonBuilder,
    this.constrainChatViewWidth,
    this.chatViewMaxWidthFraction,
    this.showYourLiveSheet = true,
    this.showStreamMemberCount = false,
    this.onStreamBackPress,
  });

  final IsmLiveStreamHeaderBuilder? streamHeader;

  final IsmLiveStreamBottomBuilder? streamBottomBuilder;

  final IsmLiveInputBuilder? inputBuilder;

  final IsmLiveChatMessageBuilder? chatMessageBuilder;

  final IsmLiveChatItemBgColorCallback? chatItemBgColorCallback;

  final Widget? endButton;

  final Widget? endStreamScreen;

  final bool showStreamHeader;

  final Alignment? streamHeaderPosition;

  final Alignment? endStreamWidgetPosition;

  final Widget? logoWidget;

  final MessageProcessCallback? messageProcessCallback;

  final StreamViewLoadedCallback? streamScreenLoadedCallback;

  final HostTopProfileClickCallback? hostTopProfileClickCallback;

  final GoLiveSmallButtonBuilder? goLiveSmallButtonBuilder;

  final ScheduleStreamCenterOverlayBuilder? scheduleStreamCenterOverlayBuilder;

  final IsmLiveCartBuilder? cartBuilder;

  final TopViewersListCallback? topViewersListCallback;

  final ModeratorsListCallback? moderatorsListCallback;

  final OnStreamScrollCallback? onStreamScrollCallback;

  final AddCoinsClickCallback? addCoinsClickCallback;

  final GiftClickCallback? giftClickCallback;

  final HeartBatchFlushCallback? heartBatchFlushCallback;

  /// When `true`, 2+ participants use the multi-column grid layout.
  final bool? useGridLayoutForMultipleParticipants;

  /// When `true`, publisher tiles show participant full names.
  final bool? showParticipantFullNamesInPublisherGrid;

  Alignment get resolvedStreamHeaderPosition =>
      streamHeaderPosition ?? Alignment.topLeft;

  Alignment get resolvedEndStreamWidgetPosition =>
      endStreamWidgetPosition ?? Alignment.topRight;

  bool get resolvedUseGridLayoutForMultipleParticipants =>
      useGridLayoutForMultipleParticipants ?? false;

  bool get resolvedShowParticipantFullNamesInPublisherGrid =>
      showParticipantFullNamesInPublisherGrid ?? false;

  /// Full-width widget shown at the bottom of the stream screen, below the
  /// message input row.
  final StreamBottomWidgetBuilder? streamBottomWidgetBuilder;

  /// Custom widget appended at the end of the stream header timer row.
  final StreamHeaderTimerTrailingWidgetBuilder?
      streamHeaderTimerTrailingWidgetBuilder;

  /// Custom widget replacing the timer row and description / PK banner.
  final StreamHeaderInfoSectionBuilder? streamHeaderInfoSectionBuilder;

  /// Single builder for the gradients overlay shown on top of the video/grid.
  ///
  /// When `null`, the SDK uses the default top and bottom gradients.
  /// Return `null` from the builder to hide gradients entirely.
  final StreamGradientOverlayBuilder? streamGradientOverlayBuilder;

  /// When `true`, the send action is shown inside [IsmLiveInputField] as a
  /// suffix icon (visible only when the field has text). When `false`, it is
  /// shown as a separate button next to the input.
  ///
  /// When `null`, defaults to [IsmLiveDelegate.productStream] == `true` for
  /// backward compatibility.
  final bool? messageSendIconInsideInputField;

  /// Custom builder for the message send button (inside or outside the input).
  ///
  /// When `null`, the SDK uses the default send icon / [CustomIconButton].
  final MessageSendButtonBuilder? messageSendButtonBuilder;

  /// When `true`, the live chat overlay is left-aligned with a capped max width
  /// ([chatViewMaxWidthFraction] of the screen) so sibling UI (e.g. product
  /// tiles) can share the row.
  ///
  /// When `null`, defaults to [IsmLiveDelegate.productStream] == `true` for
  /// backward compatibility.
  final bool? constrainChatViewWidth;

  /// Max chat width as a fraction of screen width when [constrainChatViewWidth]
  /// is enabled. Default `0.5` (half screen).
  final double? chatViewMaxWidthFraction;

  /// When `true`, shows [YourLiveSheet] after the new-stream countdown completes.
  ///
  /// When `false`, the countdown still runs but the bottom sheet is not shown.
  /// Theme [IsmLiveCounterProperties.showYoureLiveSheet] is also respected when
  /// this is `true`. Default `true`.
  final bool showYourLiveSheet;

  /// When `true`, shows the member count chip in the stream header timer row.
  /// Tapping it opens [IsmLiveMembersSheet]. Default `false` (hidden).
  final bool showStreamMemberCount;

  /// Invoked when the system back button is pressed on the live stream screen.
  ///
  /// When set, the SDK delegates the back press to this handler so host apps
  /// can run the same action as their (possibly customized) top-right cross
  /// icon. When `null`, the SDK runs its default end-stream flow.
  final StreamBackPressCallback? onStreamBackPress;

  IsmLiveStreamScreenConfigure copyWith({
    IsmLiveStreamHeaderBuilder? streamHeader,
    IsmLiveStreamBottomBuilder? streamBottomBuilder,
    IsmLiveInputBuilder? inputBuilder,
    IsmLiveChatMessageBuilder? chatMessageBuilder,
    IsmLiveChatItemBgColorCallback? chatItemBgColorCallback,
    Widget? endButton,
    Widget? endStreamScreen,
    bool? showStreamHeader,
    Alignment? streamHeaderPosition,
    Alignment? endStreamWidgetPosition,
    Widget? logoWidget,
    MessageProcessCallback? messageProcessCallback,
    StreamViewLoadedCallback? streamScreenLoadedCallback,
    HostTopProfileClickCallback? hostTopProfileClickCallback,
    GoLiveSmallButtonBuilder? goLiveSmallButtonBuilder,
    ScheduleStreamCenterOverlayBuilder? scheduleStreamCenterOverlayBuilder,
    IsmLiveCartBuilder? cartBuilder,
    TopViewersListCallback? topViewersListCallback,
    ModeratorsListCallback? moderatorsListCallback,
    OnStreamScrollCallback? onStreamScrollCallback,
    AddCoinsClickCallback? addCoinsClickCallback,
    GiftClickCallback? giftClickCallback,
    HeartBatchFlushCallback? heartBatchFlushCallback,
    bool? useGridLayoutForMultipleParticipants,
    bool? showParticipantFullNamesInPublisherGrid,
    StreamBottomWidgetBuilder? streamBottomWidgetBuilder,
    StreamHeaderTimerTrailingWidgetBuilder?
        streamHeaderTimerTrailingWidgetBuilder,
    StreamHeaderInfoSectionBuilder? streamHeaderInfoSectionBuilder,
    StreamGradientOverlayBuilder? streamGradientOverlayBuilder,
    bool? messageSendIconInsideInputField,
    MessageSendButtonBuilder? messageSendButtonBuilder,
    bool? constrainChatViewWidth,
    double? chatViewMaxWidthFraction,
    bool? showYourLiveSheet,
    bool? showStreamMemberCount,
    StreamBackPressCallback? onStreamBackPress,
  }) =>
      IsmLiveStreamScreenConfigure(
        streamHeader: streamHeader ?? this.streamHeader,
        streamBottomBuilder: streamBottomBuilder ?? this.streamBottomBuilder,
        inputBuilder: inputBuilder ?? this.inputBuilder,
        chatMessageBuilder: chatMessageBuilder ?? this.chatMessageBuilder,
        chatItemBgColorCallback:
            chatItemBgColorCallback ?? this.chatItemBgColorCallback,
        endButton: endButton ?? this.endButton,
        endStreamScreen: endStreamScreen ?? this.endStreamScreen,
        showStreamHeader: showStreamHeader ?? this.showStreamHeader,
        streamHeaderPosition: streamHeaderPosition ?? this.streamHeaderPosition,
        endStreamWidgetPosition:
            endStreamWidgetPosition ?? this.endStreamWidgetPosition,
        logoWidget: logoWidget ?? this.logoWidget,
        messageProcessCallback:
            messageProcessCallback ?? this.messageProcessCallback,
        streamScreenLoadedCallback:
            streamScreenLoadedCallback ?? this.streamScreenLoadedCallback,
        hostTopProfileClickCallback:
            hostTopProfileClickCallback ?? this.hostTopProfileClickCallback,
        goLiveSmallButtonBuilder:
            goLiveSmallButtonBuilder ?? this.goLiveSmallButtonBuilder,
        scheduleStreamCenterOverlayBuilder:
            scheduleStreamCenterOverlayBuilder ??
                this.scheduleStreamCenterOverlayBuilder,
        cartBuilder: cartBuilder ?? this.cartBuilder,
        topViewersListCallback:
            topViewersListCallback ?? this.topViewersListCallback,
        moderatorsListCallback:
            moderatorsListCallback ?? this.moderatorsListCallback,
        onStreamScrollCallback:
            onStreamScrollCallback ?? this.onStreamScrollCallback,
        addCoinsClickCallback:
            addCoinsClickCallback ?? this.addCoinsClickCallback,
        giftClickCallback: giftClickCallback ?? this.giftClickCallback,
        heartBatchFlushCallback:
            heartBatchFlushCallback ?? this.heartBatchFlushCallback,
        useGridLayoutForMultipleParticipants:
            useGridLayoutForMultipleParticipants ??
                this.useGridLayoutForMultipleParticipants,
        showParticipantFullNamesInPublisherGrid:
            showParticipantFullNamesInPublisherGrid ??
                this.showParticipantFullNamesInPublisherGrid,
        streamBottomWidgetBuilder:
            streamBottomWidgetBuilder ?? this.streamBottomWidgetBuilder,
        streamHeaderTimerTrailingWidgetBuilder:
            streamHeaderTimerTrailingWidgetBuilder ??
                this.streamHeaderTimerTrailingWidgetBuilder,
        streamHeaderInfoSectionBuilder: streamHeaderInfoSectionBuilder ??
            this.streamHeaderInfoSectionBuilder,
        streamGradientOverlayBuilder:
            streamGradientOverlayBuilder ?? this.streamGradientOverlayBuilder,
        messageSendIconInsideInputField: messageSendIconInsideInputField ??
            this.messageSendIconInsideInputField,
        messageSendButtonBuilder:
            messageSendButtonBuilder ?? this.messageSendButtonBuilder,
        constrainChatViewWidth:
            constrainChatViewWidth ?? this.constrainChatViewWidth,
        chatViewMaxWidthFraction:
            chatViewMaxWidthFraction ?? this.chatViewMaxWidthFraction,
        showYourLiveSheet: showYourLiveSheet ?? this.showYourLiveSheet,
        showStreamMemberCount:
            showStreamMemberCount ?? this.showStreamMemberCount,
        onStreamBackPress: onStreamBackPress ?? this.onStreamBackPress,
      );

  /// Resolves whether the send icon is inside the input field.
  ///
  /// Uses [messageSendIconInsideInputField] when set; otherwise mirrors legacy
  /// [IsmLiveDelegate.productStream] behavior.
  bool resolveMessageSendIconInsideInputField() =>
      messageSendIconInsideInputField ??
      IsmLiveDelegate.productStream == true;

  /// Resolves whether the stream chat view should use a width constraint.
  bool resolveConstrainChatViewWidth() =>
      constrainChatViewWidth ?? IsmLiveDelegate.productStream == true;

  /// Resolves the chat max-width fraction (clamped to `0.1`â€“`1.0`).
  double resolveChatViewMaxWidthFraction() =>
      (chatViewMaxWidthFraction ?? 0.5).clamp(0.1, 1.0);
}
