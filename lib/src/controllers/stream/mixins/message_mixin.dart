part of '../stream_controller.dart';

int? _heartLikeCountFromPayload(dynamic meta, Map<String, dynamic>? payload) {
  int? fromMap(dynamic map, String k1, String k2) {
    if (map is! Map) return null;
    for (final key in [k1, k2]) {
      final v = map[key];
      if (v is int) return v;
      if (v is num) return v.toInt();
    }
    return null;
  }

  return fromMap(meta, 'likeCount', 'likesCount') ??
      fromMap(payload, 'likeCount', 'likesCount');
}

// This mixin provides utility functions related to handling chat messages in a stream.
mixin StreamMessageMixin {
  IsmLiveStreamController get _controller =>
      Get.find<IsmLiveStreamController>();
  IsmLivePkController get _pkController => Get.find<IsmLivePkController>();
// Convert IsmLiveMessageModel to IsmLiveChatModel
  IsmLiveChatModel convertMessageToChat(IsmLiveMessageModel message) =>
      IsmLiveChatModel(
        streamId: message.streamId,
        messageId: message.messageId,
        userId: message.senderId,
        userIdentifier: message.senderIdentifier,
        userName: message.senderName,
        fullName: message.name,
        imageUrl: message.senderProfileImageUrl ?? '',
        body: message.body,
        timeStamp: DateTime.fromMillisecondsSinceEpoch(message.sentAt),
        sentByMe: message.senderId == _controller.user?.userId,
        sentByHost: message.senderId == _controller.hostDetails?.userId,
        isReply: message.replyMessage,
        parentId: message.parentMessageId,
        parentBody: message.metaData?.parentMessageBody,
        isEvent: message.isEvent,
        isCopublisherRequest: message.isCopublisherRequest,
      );

// Process message through host app's callback if provided
  IsmLiveMessageModel? _processMessage(
    IsmLiveMessageModel message,
    bool isMqtt,
  ) {
    // If no process callback is provided, return the original message
    if (IsmLiveDelegate.messageProcessCallback == null) {
      return message;
    }

    // Apply the host app's message processing
    return IsmLiveDelegate.messageProcessCallback!.call(
      message,
      _controller.streamId ?? '',
      isMqtt,
      _controller.isHost,
    );
  }

// Handle incoming message based on its type
  Future<void> handleMessage({
    required IsmLiveMessageModel message,
    Map<String, dynamic>? payload,
    bool isMqtt = true,
  }) async {
    // Process the message first
    final processedMessage = _processMessage(message, isMqtt);

    // If message was filtered out (null), don't process it
    if (processedMessage == null) {
      return;
    }

    switch (processedMessage.messageType) {
      case IsmLiveMessageType.normal:
        await _controller.addMessages([processedMessage], isMqtt);
        break;
      case IsmLiveMessageType.heart:
        if (processedMessage.senderId != _controller.user?.userId) {
          final meta = payload?['metaData'] ??
              processedMessage.metaData?.rawJson;
          final heartCount = _heartLikeCountFromPayload(meta, payload) ?? 1;
          _controller.addHeart(processedMessage, count: heartCount);
        }
        break;
      case IsmLiveMessageType.gift:
        if (_controller.pkStages?.isPk ?? false) {
          _pkController.pkBarStatus(payload ?? {});
        }
        if (processedMessage.senderId != _controller.user?.userId) {
          _controller.addGift(processedMessage, payload ?? {});
        }
        break;
      case IsmLiveMessageType.remove:
        IsmLiveLog.success('Message Removed');
        break;
      case IsmLiveMessageType.presence:
        IsmLiveLog.success('Presence Message');
        break;
      case IsmLiveMessageType.pk:
        _controller.pkStages ??= IsmLivePkStages.isPk();
        if (_controller.userRole?.isHost ?? false) {
          unawaited(
            _controller.getStreamMembers(
              streamId: _controller.streamId ?? '',
            ),
          );
        }
        break;
      case IsmLiveMessageType.pkStart:
        _pkController.pkStartEvent(payload ?? {});
        break;
      case IsmLiveMessageType.changeStream:
        await _changeStream(processedMessage);
        break;
      case IsmLiveMessageType.pkStop:
        _pkController.pkStopEvent(payload ?? {}, true);
        break;
      case IsmLiveMessageType.gift3D:
        break;
      case IsmLiveMessageType.probe:
        IsmLiveLog.success('Probe Message');
        break;
    }
  }

  Future<void> _changeStream(IsmLiveMessageModel processedMessage) async {
    IsmLiveLog.info('Change Stream Message');
    IsmLiveLog.info(
        'Change Stream action ${processedMessage.metaData?.rawJson?['action']}');
    if (processedMessage.metaData?.rawJson?['action'] == 'ACCEPT_PK' &&
        (_controller.userRole?.isHost == true)) {
      return;
    }

    var oldStreamId = _controller.streamId ?? '';
    var newStreamId = processedMessage.metaData?.rawJson?['streamId'] ?? '';
    if (processedMessage.metaData?.rawJson?['intentToStop'] == true) {
      IsmLiveLog.info('Intent to stop stream');
      IsmLiveUtility.showCustomDialog(const IsmLiveStreamEndDialog());
      // call stop brodcast ignore
    }

    if (processedMessage.metaData?.rawJson?['action'] == 'END') {
      IsmLiveLog.info('PK END');
    }

    if (_controller.userRole?.isHost == true ||
        _controller.userRole?.isPkGuest == true) {
      if (_controller.userRole?.isPkGuest == true) {
        // Co-publisher needs to disconnect and rejoin the appropriate stream
        IsmLiveLog.info(
            'Change Stream: This user PK Guest, first need to disconnect from stream $oldStreamId \n then join on original-streamId $newStreamId');

        await _controller.disconnectStream(
            isHost: _controller.userRole?.isHost ?? false,
            streamId: oldStreamId);

        final matching =
            _controller.streams.where((e) => e.streamId == newStreamId);
        if (matching.isNotEmpty && _controller.storedToken != null) {
          final stream = matching.first;
          await _controller.connectStream(
            token: _controller.storedToken ?? '',
            streamId: stream.streamId!,
            streamImage: stream.streamImage,
            isHost: true,
            isNewStream: true,
            hdBroadcast: stream.hdBroadcast ?? false,
            restream: stream.restream ?? false,
            context: Get.context!,
          );
        } else {
          IsmLiveLog.error(
              'Stream not found for streamId: $newStreamId or token not found');
        }
      }
    } else {
      IsmLiveLog.info(
          'Change Stream: This user viewer, first need to disconnect from stream $oldStreamId \n then join on original-streamId $newStreamId');

      await _controller.disconnectStream(
          isHost: _controller.userRole?.isHost ?? false,
          streamId: oldStreamId,
          goBack: false);

      final matching =
          _controller.streams.where((e) => e.streamId == newStreamId);
      if (matching.isNotEmpty) {
        final stream = matching.first;
        await _controller.initializeAndJoinStream(
          stream,
          false,
          context: Get.context!,
          reJoin: true,
        );
      } else {
        IsmLiveLog.error('Stream not found for streamId: $newStreamId');
      }
    }
  }

  // Send a text message to the stream
  Future<void> sendTextMessage({
    required String streamId,
    required String body,
    IsmLiveChatModel? parentMessage,
  }) async {
    if (body.trim().isEmpty) {
      return;
    }

    var userName = _controller.user?.name.split(' ');
    var lastName = userName?.sublist(1).join(' ');
    _controller.messageFieldController.clear();
    _controller.parentMessage = null;
    _controller.update([IsmLiveMessageField.updateId]);
// If there is a parent message, send a reply message
    if (parentMessage != null) {
      final isReply = await _controller.replyMessage(
        showLoading: false,
        sendMessageModel: IsmLiveSendMessageModel(
          streamId: streamId,
          body: body,
          searchableTags: [body],
          metaData: IsmLiveMetaData(
            parentMessageBody: parentMessage.body,
            firstName: userName?.first,
            lastName: lastName,
            profilePic: _controller.user?.profileUrl,
          ),
          deviceId: _controller.configuration?.projectConfig.deviceId ?? '',
          messageType: IsmLiveMessageType.normal,
          parentMessageId: parentMessage.messageId,
        ),
      );

      if (!isReply) {
        _controller.messageFieldController.text = body;
        _controller.parentMessage = parentMessage;
        _controller.update([IsmLiveMessageField.updateId]);
      }
    } else {
      // If no parent message, send a normal message
      final isSent = await _controller.sendMessage(
        showLoading: false,
        sendMessageModel: IsmLiveSendMessageModel(
          streamId: streamId,
          body: body,
          searchableTags: [body],
          metaData: IsmLiveMetaData(
            firstName: userName?.first,
            lastName: lastName,
            profilePic: _controller.user?.profileUrl,
          ),
          deviceId: _controller.configuration?.projectConfig.deviceId ?? '',
          messageType: IsmLiveMessageType.normal,
        ),
      );

      if (!isSent) {
        _controller.messageFieldController.text = body;
      }
    }
  }

  Future<void> sendHeartMessage(String streamId, {int count = 1}) async {
    final deviceId = _controller.configuration?.projectConfig.deviceId ?? '';
    final userId = _controller.user?.userId ?? '';
    final userName = _controller.user?.userName ?? '';
    final userImage = _controller.user?.userProfileImageUrl ?? '';
    const customType = 'like';

    await _controller.sendHearts(
      customType: customType,
      deviceId: deviceId,
      senderId: userId,
      senderImage: userImage,
      senderName: userName,
      streamId: streamId,
      likesCount: count,
    );
  }

  // Send a gift message to the stream
  Future<void> sendGiftMessage({
    required String streamId,
    required IsmLiveGiftsCategoryModel gift,
  }) async {
    final isSent = await _controller.sendMessage(
      showLoading: false,
      sendMessageModel: IsmLiveSendMessageModel(
        streamId: streamId,
        body: IsmLiveGiftModel(
          coinsValue: gift.virtualCurrency,
          giftCategoryName: '3D',
          giftName: gift.giftTitle,
          giftThumbnailUrl: gift.giftImage,
          message: gift.giftAnimationImage,
        ).toJson(),
        searchableTags: ['gift'],
        metaData: const IsmLiveMetaData(),
        deviceId: _controller.configuration?.projectConfig.deviceId ?? '',
        messageType: IsmLiveMessageType.gift3D,
        customType: 'gift',
      ),
    );

    if (isSent) {}
  }

  // Handle a message being removed
  Future<void> messageRemoved(String messageId, String userName) async {
    var message =
        _controller.streamMessagesList.cast<IsmLiveChatModel?>().firstWhere(
              (e) => e?.messageId == messageId,
              orElse: () => null,
            );
    if (message == null) {
      return;
    }

    final index = _controller.streamMessagesList.indexOf(message);
    if (index == -1) {
      return;
    }
    // Update the message as deleted
    message = message.copyWith(
      isDeleted: true,
      body: userName,
    );

    _controller.streamMessagesList[index] = message;

    // Also update all reply messages that reference this message as parent
    for (var i = 0; i < _controller.streamMessagesList.length; i++) {
      final reply = _controller.streamMessagesList[i];
      if (reply.isReply && reply.parentId == messageId) {
        _controller.streamMessagesList[i] = reply.copyWith(
          parentBody: '$userName Deleted Message',
        );
      }
    }
    _controller._streamMessagesList.refresh();
  }
}
