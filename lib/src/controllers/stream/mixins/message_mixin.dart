part of '../stream_controller.dart';

mixin StreamMessageMixin {
  IsmLiveStreamController get _controller =>
      Get.find<IsmLiveStreamController>();

  IsmLiveChatModel convertMessageToChat(IsmLiveMessageModel message) =>
      IsmLiveChatModel(
        streamId: message.streamId,
        messageId: message.messageId,
        userId: message.senderId,
        userIdentifier: message.senderIdentifier,
        userName: message.senderName,
        imageUrl: message.senderProfileImageUrl ?? '',
        body: message.body,
        timeStamp: DateTime.fromMillisecondsSinceEpoch(message.sentAt),
        sentByMe: message.senderId == _controller.user?.userId,
        sentByHost: message.senderId == _controller.hostDetails?.userId,
      );

  Future<void> handleMessage(
    IsmLiveMessageModel message, [
    bool isMqtt = true,
  ]) async {
    switch (message.messageType) {
      case IsmLiveMessageType.normal:
        return await _controller.addMessages([message], isMqtt);

      case IsmLiveMessageType.heart:
        _controller.addHeart(message);
        break;
      case IsmLiveMessageType.gift:
        _controller.addGift(message);
        break;
      case IsmLiveMessageType.remove:
        IsmLiveLog.success('Message Removed');
        break;
      case IsmLiveMessageType.presence:
        IsmLiveLog.success('Presence Message');
        break;
    }
  }

  Future<void> sendTextMessage({
    required String streamId,
    required String body,
  }) async {
    if (body.trim().isEmpty) {
      return;
    }
    _controller.messageFieldController.clear();

    if (_controller.parentMessageId != null) {
      final isReply = await _controller.replyMessage(
        showLoading: false,
        sendMessageModel: IsmLiveSendMessageModel(
          streamId: streamId,
          body: body,
          searchableTags: [body],
          metaData: const IsmLiveMetaData(),
          deviceId: _controller.configuration?.projectConfig.deviceId ?? '',
          messageType: IsmLiveMessageType.normal,
          parentMessageId: _controller.parentMessageId,
        ),
      );

      if (!isReply) {
        _controller.messageFieldController.text = body;
      } else {
        _controller.parentMessageId = null;
      }
    } else {
      final isSent = await _controller.sendMessage(
        showLoading: false,
        sendMessageModel: IsmLiveSendMessageModel(
          streamId: streamId,
          body: body,
          searchableTags: [body],
          metaData: const IsmLiveMetaData(),
          deviceId: _controller.configuration?.projectConfig.deviceId ?? '',
          messageType: IsmLiveMessageType.normal,
        ),
      );

      if (!isSent) {
        _controller.messageFieldController.text = body;
      }
    }
  }

  Future<void> sendHeartMessage(String streamId) async {
    const body = 'heart';
    final isSent = await _controller.sendMessage(
      showLoading: false,
      sendMessageModel: IsmLiveSendMessageModel(
        streamId: streamId,
        body: body,
        searchableTags: [body],
        metaData: const IsmLiveMetaData(),
        deviceId: _controller.configuration?.projectConfig.deviceId ?? '',
        messageType: IsmLiveMessageType.heart,
      ),
    );

    if (isSent) {}
  }

  Future<void> sendGiftMessage({
    required String streamId,
    required IsmLiveGifts gift,
  }) async {
    final isSent = await _controller.sendMessage(
      showLoading: false,
      sendMessageModel: IsmLiveSendMessageModel(
        streamId: streamId,
        body: gift.name,
        searchableTags: [gift.name],
        metaData: const IsmLiveMetaData(),
        deviceId: _controller.configuration?.projectConfig.deviceId ?? '',
        messageType: IsmLiveMessageType.gift,
        customType: gift,
      ),
    );

    if (isSent) {}
  }

  Future<void> messageRemoved(String messageId) async {
    var message =
        _controller.streamMessagesList.cast<IsmLiveChatModel?>().firstWhere(
              (e) => e?.messageId == messageId,
              orElse: () => null,
            );
    IsmLiveLog(message);
    if (message == null) {
      return;
    }
    message = message.copyWith(isDeleted: true);
    final index = _controller.streamMessagesList.indexOf(message);
    IsmLiveLog.info(message);
    IsmLiveLog.info(index);
    if (index == -1) {
      return;
    }
    _controller.streamMessagesList[index] = message;
    _controller._streamMessagesList.refresh();
  }
}
