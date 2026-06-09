import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:get/get.dart';

/// Fetches and converts stream chat messages for recording replay.
///
/// Uses the same messages API as live streams but keeps results isolated from
/// [IsmLiveStreamController.streamMessagesList].
/// Resolves stream start time for recording chat replay.
DateTime? ismLiveRecordingStreamStartTime(
  IsmLiveStreamRecordingItem recording,
  IsmLiveStreamRecordingPlayerConfig config,
) {
  final fromConfig = config.resolveStreamStartTime?.call(recording);
  if (fromConfig != null) {
    return fromConfig;
  }
  if (recording is IsmLiveStreamRecordingReplayCapable) {
    return (recording as IsmLiveStreamRecordingReplayCapable).streamStartTime;
  }
  return null;
}

class _ResolvedRecordedMessageQuery {
  const _ResolvedRecordedMessageQuery({
    required this.query,
    required this.count,
  });

  final IsmLiveGetMessageModel query;
  final int count;
}

class IsmLiveRecordingChatHelper {
  const IsmLiveRecordingChatHelper._();

  static const int _defaultPageSize = 50;

  /// Base query for ended/recorded streams (`activeStream=false`).
  ///
  /// Pass [useArchived] to also request archived messages after the initial
  /// attempt returns no data.
  static IsmLiveGetMessageModel _recordedStreamMessageQuery(
    String streamId, {
    bool useArchived = false,
  }) =>
      IsmLiveGetMessageModel(
        streamId: streamId,
        messageType: [IsmLiveMessageType.normal.value],
        activeStream: false,
        archived: useArchived ? true : null,
      );

  static IsmLiveStreamViewModel _viewModel() {
    if (!Get.isRegistered<IsmLiveStreamController>()) {
      IsmLiveStreamBinding().dependencies();
    }
    return Get.find<IsmLiveStreamController>().viewModel;
  }

  /// Picks the recording message query params for this stream.
  ///
  /// 1. Try `activeStream=false`.
  /// 2. If count is zero or the first page is empty, retry with
  ///    `activeStream=false` and `archived=true`.
  /// 3. All pagination for this recording uses the resolved params.
  static Future<_ResolvedRecordedMessageQuery> _resolveRecordedMessageQuery(
    String streamId,
    IsmLiveStreamViewModel viewModel,
  ) async {
    final inactiveQuery = _recordedStreamMessageQuery(streamId);
    final inactiveCount = await viewModel.fetchMessagesCount(
      showLoading: false,
      getMessageModel: inactiveQuery,
    );
    if (inactiveCount > 0) {
      final firstPage = await viewModel.fetchMessages(
        showLoading: false,
        showDialog: false,
        getMessageModel: inactiveQuery.copyWith(
          sort: 1,
          skip: 0,
          limit: 1,
          senderIdsExclusive: false,
        ),
      );
      if (firstPage.isNotEmpty) {
        return _ResolvedRecordedMessageQuery(
          query: inactiveQuery,
          count: inactiveCount,
        );
      }
    }

    final archivedQuery = _recordedStreamMessageQuery(
      streamId,
      useArchived: true,
    );
    final archivedCount = await viewModel.fetchMessagesCount(
      showLoading: false,
      getMessageModel: archivedQuery,
    );
    return _ResolvedRecordedMessageQuery(
      query: archivedQuery,
      count: archivedCount,
    );
  }

  /// Loads all normal chat messages for [streamId], oldest first.
  static Future<List<IsmLiveChatModel>> fetchAllChatMessages({
    required String streamId,
    String? hostUserId,
    String? currentUserId,
    int pageSize = _defaultPageSize,
  }) async {
    if (streamId.isEmpty) {
      return const [];
    }

    final viewModel = _viewModel();
    final resolved = await _resolveRecordedMessageQuery(streamId, viewModel);
    if (resolved.count <= 0) {
      return const [];
    }

    final allMessages = <IsmLiveMessageModel>[];
    final safePageSize = pageSize <= 0 ? _defaultPageSize : pageSize;

    for (var skip = 0; skip < resolved.count; skip += safePageSize) {
      final remaining = resolved.count - skip;
      final limit = remaining < safePageSize ? remaining : safePageSize;
      final batch = await viewModel.fetchMessages(
        showLoading: false,
        showDialog: false,
        getMessageModel: resolved.query.copyWith(
          sort: 1,
          skip: skip,
          limit: limit,
          senderIdsExclusive: false,
        ),
      );
      allMessages.addAll(batch);
    }

    final chats = allMessages
        .map(
          (message) => _convertMessageToChat(
            message,
            streamId: streamId,
            hostUserId: hostUserId,
            currentUserId: currentUserId,
          ),
        )
        .whereType<IsmLiveChatModel>()
        .toList()
      ..sort(
        (a, b) => a.timeStamp.millisecondsSinceEpoch
            .compareTo(b.timeStamp.millisecondsSinceEpoch),
      );

    return chats;
  }

  static IsmLiveChatModel? _convertMessageToChat(
    IsmLiveMessageModel message, {
    required String streamId,
    String? hostUserId,
    String? currentUserId,
  }) {
    final processed = _processMessage(message, streamId);
    if (processed == null) {
      return null;
    }

    return IsmLiveChatModel(
      streamId: processed.streamId.isEmpty ? streamId : processed.streamId,
      messageId: processed.messageId,
      userId: processed.senderId,
      userIdentifier: processed.senderIdentifier,
      userName: processed.senderName,
      fullName: processed.name,
      imageUrl: processed.senderProfileImageUrl ?? '',
      body: processed.body,
      timeStamp: DateTime.fromMillisecondsSinceEpoch(processed.sentAt),
      sentByMe: currentUserId != null && processed.senderId == currentUserId,
      sentByHost: hostUserId != null && processed.senderId == hostUserId,
      isReply: processed.replyMessage,
      parentId: processed.parentMessageId,
      parentBody: processed.metaData?.parentMessageBody,
      isEvent: processed.isEvent,
      isCopublisherRequest: processed.isCopublisherRequest,
    );
  }

  static IsmLiveMessageModel? _processMessage(
    IsmLiveMessageModel message,
    String streamId,
  ) {
    final callback =
        IsmLiveDelegate.streamScreenConfigure.messageProcessCallback;
    if (callback == null) {
      return message;
    }

    return callback.call(
      message,
      streamId,
      false,
      false,
    );
  }
}
