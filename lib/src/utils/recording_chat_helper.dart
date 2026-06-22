import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:get/get.dart';

/// Fetches and converts stream chat messages for recording replay.
///
/// Uses the same messages API as live streams but keeps results isolated from
/// [IsmLiveStreamController.streamMessagesList].
///
/// Backend lifecycle for recordings:
/// - Recently ended streams: `activeStream=false`
/// - After archive migration: `activeStream=false` + `archived=true`
///
/// We probe with the messages API only (no count). Whichever param set returns
/// the first page is reused for all further pagination (`skip` / `limit`).
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

class _ResolvedRecordedMessageAccess {
  const _ResolvedRecordedMessageAccess({
    required this.query,
    required this.firstPage,
  });

  final IsmLiveGetMessageModel query;
  final List<IsmLiveMessageModel> firstPage;
}

class IsmLiveRecordingChatHelper {
  const IsmLiveRecordingChatHelper._();

  static const int _defaultPageSize = 10;

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

  static Future<List<IsmLiveMessageModel>> _fetchMessagePage(
    IsmLiveStreamViewModel viewModel,
    IsmLiveGetMessageModel baseQuery, {
    required int skip,
    required int limit,
  }) =>
      viewModel.fetchMessages(
        showLoading: false,
        showDialog: false,
        getMessageModel: baseQuery.copyWith(
          sort: 1,
          skip: skip,
          limit: limit,
          senderIdsExclusive: false,
        ),
      );

  /// Resolves which query params work for this recording and returns page 0.
  ///
  /// 1. `fetchMessages` with `activeStream=false`
  /// 2. If empty, `fetchMessages` with `activeStream=false` + `archived=true`
  /// 3. Further pages use the same params with increasing `skip`
  static Future<_ResolvedRecordedMessageAccess?> _resolveRecordedMessageAccess(
    String streamId,
    IsmLiveStreamViewModel viewModel,
    int pageSize,
  ) async {
    final inactiveQuery = _recordedStreamMessageQuery(streamId);
    final inactivePage = await _fetchMessagePage(
      viewModel,
      inactiveQuery,
      skip: 0,
      limit: pageSize,
    );
    if (inactivePage.isNotEmpty) {
      return _ResolvedRecordedMessageAccess(
        query: inactiveQuery,
        firstPage: inactivePage,
      );
    }

    final archivedQuery = _recordedStreamMessageQuery(
      streamId,
      useArchived: true,
    );
    final archivedPage = await _fetchMessagePage(
      viewModel,
      archivedQuery,
      skip: 0,
      limit: pageSize,
    );
    if (archivedPage.isEmpty) {
      return null;
    }

    return _ResolvedRecordedMessageAccess(
      query: archivedQuery,
      firstPage: archivedPage,
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
    final safePageSize = pageSize <= 0 ? _defaultPageSize : pageSize;
    final resolved = await _resolveRecordedMessageAccess(
      streamId,
      viewModel,
      safePageSize,
    );
    if (resolved == null) {
      return const [];
    }

    final allMessages = List<IsmLiveMessageModel>.from(resolved.firstPage);
    var skip = resolved.firstPage.length;

    while (true) {
      final batch = await _fetchMessagePage(
        viewModel,
        resolved.query,
        skip: skip,
        limit: safePageSize,
      );
      if (batch.isEmpty) {
        break;
      }
      allMessages.addAll(batch);
      skip += batch.length;
      if (batch.length < safePageSize) {
        break;
      }
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
