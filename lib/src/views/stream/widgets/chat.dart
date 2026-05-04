import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Builder function for customizing chat message items
///
/// - [context]: BuildContext for accessing theme and media query
/// - [message]: The message object containing all message data
/// - [defaultChild]: The default chat message widget that can be used or modified
///
/// Returns a custom Widget or the modified defaultChild
typedef IsmLiveChatMessageBuilder = Widget Function(
  BuildContext context,
  IsmLiveChatModel message,
  Widget defaultChild,
);

/// Callback function for customizing chat message background color
///
/// - [message]: The message object containing all message data
///
/// Returns a Color for the message background, or null to use default
typedef IsmLiveChatItemBgColorCallback = Color? Function(
    IsmLiveChatModel message);

class IsmLiveChatView extends StatefulWidget {
  IsmLiveChatView({
    super.key,
    required this.isHost,
    required this.streamId,
    this.chatMessageBuilder,
    this.chatItemBgColorCallback,
  });

  final bool isHost;
  final String streamId;
  final IsmLiveChatMessageBuilder? chatMessageBuilder;
  final IsmLiveChatItemBgColorCallback? chatItemBgColorCallback;

  @override
  State<IsmLiveChatView> createState() => _IsmLiveChatViewState();
}

class _IsmLiveChatViewState extends State<IsmLiveChatView>
    with WidgetsBindingObserver {
  final messagesListController = ScrollController();
  final _controller = Get.find<IsmLiveStreamController>();
  bool _isScrolling = false;
  int _previousMessageCount = 0;
  bool _isAtBottom = true;
  bool _isPaginatingOlder = false;
  DateTime? _paginationMarkAt;
  Timer? _autoScrollTimer;
  int _lastAutoScrollScheduledForCount = 0;
  double _keyboardInset = 0;
  bool _isKeyboardOpen = false;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    messagesListController.addListener(_scrollListener);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncKeyboardMetrics(triggerRebuild: false);
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _syncKeyboardMetrics(triggerRebuild: true);
  }

  void _syncKeyboardMetrics({required bool triggerRebuild}) {
    final view = WidgetsBinding.instance.platformDispatcher.views.isNotEmpty
        ? WidgetsBinding.instance.platformDispatcher.views.first
        : null;
    final devicePixelRatio = view?.devicePixelRatio ?? 1.0;
    final inset = (view?.viewInsets.bottom ?? 0) / devicePixelRatio;
    final isOpen = inset > 0;

    if (inset == _keyboardInset && isOpen == _isKeyboardOpen) return;

    _keyboardInset = inset;
    _isKeyboardOpen = isOpen;

    // Ensure the chat re-evaluates constraints even when the parent GetX builder
    // doesn't rebuild on keyboard metric changes.
    if (triggerRebuild && mounted) {
      setState(() {});
    }
  }

  void _scrollListener() {
    if (!_isScrolling) {
      _isScrolling = true;
      _updateScrollAnchorsAndMaybeMarkPagination();
      _controller.messagePagination(messagesListController);
      Future.delayed(const Duration(milliseconds: 100), () {
        _isScrolling = false;
      });
    }
  }

  void _updateScrollAnchorsAndMaybeMarkPagination() {
    if (!messagesListController.hasClients) return;
    final position = messagesListController.position;

    // If user is close to bottom, allow auto-scroll on new messages.
    const bottomThresholdPx = 80.0;
    final distanceFromBottom = position.maxScrollExtent - position.pixels;
    _isAtBottom = distanceFromBottom <= bottomThresholdPx;

    // If user is at (or very near) the top, they're likely paging older messages.
    // Mark this briefly so incoming messages (or prepend) don't snap them to bottom.
    const topThresholdPx = 4.0;
    final atTop =
        (position.pixels - position.minScrollExtent).abs() <= topThresholdPx;
    if (atTop) {
      _isPaginatingOlder = true;
      _paginationMarkAt = DateTime.now();
    } else {
      // Release the paginate mark after a short grace window.
      final markedAt = _paginationMarkAt;
      if (markedAt != null &&
          DateTime.now().difference(markedAt) > const Duration(seconds: 2)) {
        _isPaginatingOlder = false;
        _paginationMarkAt = null;
      }
    }
  }

  @override
  void dispose() {
    try {
      WidgetsBinding.instance.removeObserver(this);
      _autoScrollTimer?.cancel();
      messagesListController.removeListener(_scrollListener);
      messagesListController.dispose();
    } catch (e) {
      IsmLiveLog('chat controller error $e');
    }
    super.dispose();
  }

  void _scrollToBottom({required bool useJump}) {
    if (messagesListController.hasClients) {
      final target = messagesListController.position.maxScrollExtent;
      if (useJump) {
        messagesListController.jumpTo(target);
      } else {
        messagesListController.animateTo(
          target,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    }
  }

  void _scheduleAutoScrollToBottom({
    required int currentMessageCount,
    required int delta,
    required bool shouldAutoScroll,
  }) {
    if (!shouldAutoScroll) return;

    // Avoid spamming scrolls during message bursts; keep the latest intent only.
    if (_lastAutoScrollScheduledForCount == currentMessageCount) return;
    _lastAutoScrollScheduledForCount = currentMessageCount;

    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer(const Duration(milliseconds: 60), () {
      if (!mounted) return;

      // If lots of messages arrived in a burst, jump (cheaper) instead of animating.
      final useJump = delta >= 4;
      _scrollToBottom(useJump: useJump);
    });
  }

  @override
  Widget build(BuildContext context) => GetX<IsmLiveStreamController>(
        builder: (controller) {
          final mediaQuery = MediaQuery.of(context);
          final isKeyboardOpen = _isKeyboardOpen;

          // Only render messages that belong to this view's stream.
          //
          // This guards against a rare race where the previous stream's
          // `streamMessagesList` has not yet been cleared (the cleanup runs
          // via `IsmLiveUtility.updateLater`, i.e. next frame + 10ms) by the
          // time the next stream's view is built. Without this filter, the
          // audience can briefly see chat from the previous stream in the
          // newly joined stream. Messages from different streams are not
          // de-duplicated by `.toSet()` because `IsmLiveChatModel` equality
          // is `(streamId, messageId)`.
          //
          // Falls back to the unfiltered list when `widget.streamId` is empty
          // (e.g. the schedule view before a stream is active) to preserve
          // existing behavior in those edge cases.
          final messagesForStream = widget.streamId.isEmpty
              ? controller.streamMessagesList
              : controller.streamMessagesList
                  .where((m) => m.streamId == widget.streamId)
                  .toList();

          // Scroll to bottom only when new message arrives (not on updates)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final currentMessageCount = messagesForStream.length;
            // Reset counter if messages were cleared (e.g., stream ended)
            if (currentMessageCount == 0) {
              _previousMessageCount = 0;
              return;
            }
            // Only scroll if message count increased (new message added)
            // Never auto-scroll while user is paging/reading older messages.
            // Auto-scroll only if user is already near the bottom.
            final delta = currentMessageCount - _previousMessageCount;
            if (delta > 0 && _isAtBottom && !_isPaginatingOlder) {
              _scheduleAutoScrollToBottom(
                currentMessageCount: currentMessageCount,
                delta: delta,
                shouldAutoScroll: _isAtBottom && !_isPaginatingOlder,
              );
            }
            _previousMessageCount = currentMessageCount;
          });

          final baseMaxHeight = controller.participantTracks.length < 2
              ? IsmLiveDimens.percentHeight(0.35)
              : controller.participantTracks.length < 4
                  ? IsmLiveDimens.percentHeight(0.3)
                  : IsmLiveDimens.percentHeight(0.15);

          // When keyboard opens, shrink the chat overlay so it never pushes/overlaps
          // the stream header/top UI. Keep a sensible minimum so chat remains usable.
          final effectiveMaxHeight = isKeyboardOpen
              ? (baseMaxHeight * 0.7).clamp(96.0, baseMaxHeight)
              : baseMaxHeight;

          return ShaderMask(
            shaderCallback: (rect) => const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.white,
                Colors.white,
              ],
              stops: [0.0, 0.1, 1.0],
            ).createShader(rect),
            blendMode: BlendMode.dstIn,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              constraints: BoxConstraints(
                maxHeight: effectiveMaxHeight,
                maxWidth: mediaQuery.size.width * 0.75,
              ),
              child: ListView.builder(
                controller: messagesListController,
                padding: IsmLiveDimens.edgeInsets0_8,
                shrinkWrap: true,
                itemCount: messagesForStream.length,
                itemBuilder: (context, index) {
                  final message = messagesForStream[index];

                  // Get custom background color if callback provided
                  final customBackgroundColor =
                      widget.chatItemBgColorCallback?.call(message);

                  // Build default chat message widget
                  final defaultMessageWidget = _ChatMessageItem(
                    message: message,
                    isHost: widget.isHost,
                    backgroundColor: customBackgroundColor,
                    onTap: () {
                      // Only host and moderator may reply/delete arbitrary messages.
                      // Co-publishers and members behave like viewers unless they are moderators.
                      final isHostOrModerator =
                          controller.isHost || controller.isModerator;

                      // Messages from the host: still only host or moderator.
                      final openSheetByMessageSource = message.sentByHost
                          ? isHostOrModerator
                          : true;

                      final openSheetByUserRole =
                          isHostOrModerator ? true : message.sentByMe;

                      final canOpenSheet =
                          openSheetByMessageSource && openSheetByUserRole;

                      // Block actions for replies whose parent message is deleted
                      // final hasDeletedParent = message.isReply &&
                      //     controller.streamMessagesList
                      //         .cast<IsmLiveChatModel?>()
                      //         .firstWhere(
                      //           (e) => e?.messageId == message.parentId,
                      //           orElse: () => null,
                      //         )
                      //         ?.isDeleted ==
                      //         true;

                      if (!message.isEvent &&
                          !message.isDeleted &&
                          canOpenSheet) {
                        IsmLiveUtility.openBottomSheet(
                          ChatBottomSheet(
                            message: message,
                          ),
                        );
                      }
                    },
                  );

                  // Use custom builder if provided, otherwise use default
                  return widget.chatMessageBuilder?.call(
                        context,
                        message,
                        defaultMessageWidget,
                      ) ??
                      defaultMessageWidget;
                },
              ),
            ),
          );
        },
      );
}

class _ChatMessageItem extends StatelessWidget {
  const _ChatMessageItem({
    required this.message,
    required this.isHost,
    required this.onTap,
    this.backgroundColor,
  });

  final IsmLiveChatModel message;
  final bool isHost;
  final VoidCallback onTap;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Align(
          alignment: Alignment.centerLeft,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            child: IsmLiveTapHandler(
              onTap: onTap,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: backgroundColor ?? Colors.black26,
                  borderRadius: BorderRadius.circular(IsmLiveDimens.ten),
                ),
                child: Padding(
                  padding: IsmLiveDimens.edgeInsets8_4,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IsmLiveImage.network(
                        IsmLiveDelegate.getUserProfileUrl
                                ?.call(message.imageUrl) ??
                            message.imageUrl,
                        name: message.userName,
                        initials: message.profileInitials,
                        dimensions: IsmLiveDimens.twentyFour,
                        isProfileImage: true,
                      ),
                      IsmLiveDimens.boxWidth4,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    '${message.displayName}${message.sentByMe ? " (You)" : ""}',
                                    style:
                                        context.textTheme.labelSmall!.copyWith(
                                      color: IsmLiveColors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (message.sentByHost) ...[
                                  IsmLiveDimens.boxWidth8,
                                  DecoratedBox(
                                    decoration: BoxDecoration(
                                      color: (context.liveTheme?.primaryColor ??
                                              IsmLiveColors.primary)
                                          .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(
                                          IsmLiveDimens.four),
                                    ),
                                    child: Padding(
                                      padding: IsmLiveDimens.edgeInsets6_2,
                                      child: Text(
                                        'Host',
                                        style: context.textTheme.labelSmall
                                            ?.copyWith(
                                          color: IsmLiveColors.white
                                              .withValues(alpha: 0.7),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            if (message.isDeleted)
                              Text(
                                ' ${message.body} Deleted Message',
                                style: context.textTheme.labelSmall?.copyWith(
                                  color: Colors.white70,
                                  fontStyle: FontStyle.italic,
                                ),
                              )
                            else ...[
                              if (message.isReply &&
                                  message.parentBody != null) ...[
                                Text(
                                  'Reply to ${message.parentBody}',
                                  style: context.textTheme.labelSmall?.copyWith(
                                    color: Colors.white70,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              Column(
                                children: [
                                  Text(
                                    message.body,
                                    style:
                                        context.textTheme.labelMedium?.copyWith(
                                      color: IsmLiveColors.white,
                                    ),
                                    softWrap: true,
                                  ),
                                  if (message.isCopublisherRequest)
                                    Row(
                                      children: [
                                        Expanded(
                                          child: SizedBox(
                                            height: IsmLiveDimens.thirtyTwo +
                                                IsmLiveDimens.two,
                                            child: IsmLiveButton(
                                              label: 'accept',
                                              onTap: () {
                                                final controller = Get.find<
                                                    IsmLiveStreamController>();
                                                controller
                                                    .acceptCopublisherRequest(
                                                  requestById: message.userId,
                                                  streamId: controller
                                                          .streamId ??
                                                      '',
                                                );
                                                controller.streamMessagesList[
                                                        controller
                                                            .streamMessagesList
                                                            .indexOf(message)] =
                                                    message.copyWith(
                                                        isCopublisherRequest:
                                                            false);
                                              },
                                            ),
                                          ),
                                        ),
                                        IsmLiveDimens.boxWidth2,
                                        Expanded(
                                          child: SizedBox(
                                            height: IsmLiveDimens.thirtyTwo +
                                                IsmLiveDimens.two,
                                            child: IsmLiveButton(
                                              label: 'deny',
                                              onTap: () {
                                                final controller = Get.find<
                                                    IsmLiveStreamController>();
                                                controller
                                                    .denyCopublisherRequest(
                                                  requestById: message.userId,
                                                  streamId: controller
                                                          .streamId ??
                                                      '',
                                                );
                                                controller.streamMessagesList[
                                                        controller
                                                            .streamMessagesList
                                                            .indexOf(message)] =
                                                    message.copyWith(
                                                        isCopublisherRequest:
                                                            false);
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
