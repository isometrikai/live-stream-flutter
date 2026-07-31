import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/utils/recording_chat_helper.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Read-only chat overlay for stream recording replay.
///
/// Reveals comments in sync with [videoController] position using
/// [IsmLiveStreamRecordingReplayCapable.streamStartTime] (or a fallback baseline).
class IsmLiveRecordingChatOverlay extends StatefulWidget {
  const IsmLiveRecordingChatOverlay({
    super.key,
    required this.recording,
    required this.config,
    required this.videoController,
    required this.isActive,
  });

  final IsmLiveStreamRecordingItem recording;
  final IsmLiveStreamRecordingPlayerConfig config;
  final VideoPlayerController? videoController;
  final bool isActive;

  @override
  State<IsmLiveRecordingChatOverlay> createState() =>
      _IsmLiveRecordingChatOverlayState();
}

class _IsmLiveRecordingChatOverlayState
    extends State<IsmLiveRecordingChatOverlay> {
  final ScrollController _scrollController = ScrollController();

  List<IsmLiveChatModel> _allMessages = const [];
  List<IsmLiveChatModel> _visibleMessages = const [];
  DateTime? _fallbackStartTime;
  bool _isLoading = false;
  int _loadGeneration = 0;
  int _previousVisibleCount = 0;
  bool _isAtBottom = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    widget.videoController?.addListener(_onVideoTick);
    if (widget.isActive) {
      unawaited(_loadMessages());
    }
  }

  @override
  void didUpdateWidget(IsmLiveRecordingChatOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.videoController != widget.videoController) {
      oldWidget.videoController?.removeListener(_onVideoTick);
      widget.videoController?.addListener(_onVideoTick);
    }

    if (oldWidget.recording.streamId != widget.recording.streamId) {
      _resetForNewRecording();
      if (widget.isActive) {
        unawaited(_loadMessages());
      }
      return;
    }

    if (!oldWidget.isActive && widget.isActive) {
      if (_allMessages.isEmpty) {
        unawaited(_loadMessages());
      } else {
        _syncVisibleMessages(force: true);
      }
    }
  }

  void _resetForNewRecording() {
    _loadGeneration++;
    _allMessages = const [];
    _visibleMessages = const [];
    _fallbackStartTime = null;
    _previousVisibleCount = 0;
    _isLoading = false;
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    const bottomThresholdPx = 80.0;
    _isAtBottom =
        position.maxScrollExtent - position.pixels <= bottomThresholdPx;
  }

  void _onVideoTick() {
    if (!widget.isActive) return;
    _syncVisibleMessages();
  }

  Future<void> _loadMessages() async {
    final streamId = widget.recording.streamId;
    if (streamId.isEmpty) return;

    final generation = ++_loadGeneration;
    if (mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final messages = await IsmLiveRecordingChatHelper.fetchAllChatMessages(
        streamId: streamId,
        hostUserId: widget.recording.userId,
        currentUserId: widget.config.getCurrentUserId?.call(),
      );

      if (!mounted || generation != _loadGeneration) return;

      _allMessages = messages
          .where((m) => !m.isEvent && m.streamId == streamId)
          .toList();

      if (_resolveConfiguredStartTime() == null && _allMessages.isNotEmpty) {
        _fallbackStartTime = _allMessages.first.timeStamp;
      }

      _syncVisibleMessages(force: true);
    } finally {
      if (mounted && generation == _loadGeneration) {
        setState(() => _isLoading = false);
      }
    }
  }

  DateTime? _resolveConfiguredStartTime() => ismLiveRecordingStreamStartTime(
        widget.recording,
        widget.config,
      );

  DateTime? _effectiveStartTime() =>
      _resolveConfiguredStartTime() ?? _fallbackStartTime;

  void _syncVisibleMessages({bool force = false}) {
    if (!mounted) return;

    final startTime = _effectiveStartTime();
    List<IsmLiveChatModel> next;

    if (startTime == null || _allMessages.isEmpty) {
      next = startTime == null && _allMessages.isNotEmpty
          ? List<IsmLiveChatModel>.from(_allMessages)
          : const [];
    } else {
      final controller = widget.videoController;
      final position = controller != null && controller.value.isInitialized
          ? controller.value.position
          : Duration.zero;
      final cutoffMs =
          startTime.millisecondsSinceEpoch + position.inMilliseconds;
      next = _allMessages
          .where(
            (m) => m.timeStamp.millisecondsSinceEpoch <= cutoffMs,
          )
          .toList();
    }

    final countChanged = next.length != _visibleMessages.length;
    final tailChanged = next.isNotEmpty &&
        (_visibleMessages.isEmpty ||
            next.last.messageId != _visibleMessages.last.messageId);

    if (!force && !countChanged && !tailChanged) {
      return;
    }

    final delta = next.length - _previousVisibleCount;
    _previousVisibleCount = next.length;
    _visibleMessages = next;
    setState(() {});

    if (delta > 0 && _isAtBottom) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_scrollController.hasClients) return;
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _loadGeneration++;
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    widget.videoController?.removeListener(_onVideoTick);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _visibleMessages.isEmpty) {
      return const SizedBox.shrink();
    }
    if (_visibleMessages.isEmpty) {
      return const SizedBox.shrink();
    }

    final maxHeight = IsmLiveDimens.percentHeight(0.35);

    return Positioned(
      left: 8,
      right: 72,
      bottom: MediaQuery.paddingOf(context).bottom + 88,
      child: ShaderMask(
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
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: maxHeight,
            maxWidth: MediaQuery.sizeOf(context).width * 0.75,
          ),
          child: ListView.builder(
            controller: _scrollController,
            padding: IsmLiveDimens.edgeInsets0_8,
            shrinkWrap: true,
            itemCount: _visibleMessages.length,
            itemBuilder: (context, index) {
              final message = _visibleMessages[index];
              final screenConfigure = IsmLiveDelegate.streamScreenConfigure;
              final customBackgroundColor =
                  screenConfigure.chatItemBgColorCallback?.call(message);

              final defaultMessageWidget = _RecordingChatMessageItem(
                message: message,
                backgroundColor: customBackgroundColor,
              );

              return screenConfigure.chatMessageBuilder?.call(
                    context,
                    message,
                    defaultMessageWidget,
                  ) ??
                  defaultMessageWidget;
            },
          ),
        ),
      ),
    );
  }
}

class _RecordingChatMessageItem extends StatelessWidget {
  const _RecordingChatMessageItem({
    required this.message,
    this.backgroundColor,
  });

  final IsmLiveChatModel message;
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelSmall!
                                      .copyWith(
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
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
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
                              IsmLiveStrings.deletedMessageFormat(
                                ' ${message.body}',
                              ),
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(
                                color: Colors.white70,
                                fontStyle: FontStyle.italic,
                              ),
                            )
                          else ...[
                            if (message.isReply &&
                                message.parentBody != null) ...[
                              Text(
                                IsmLiveStrings.replyToFormat(
                                  message.parentBody ?? '',
                                ),
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                  color: Colors.white70,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            Text(
                              message.body,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(
                                color: IsmLiveColors.white,
                              ),
                              softWrap: true,
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
      );
}
