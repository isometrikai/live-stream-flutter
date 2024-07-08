part of '../stream_controller.dart';

// This mixin provides utility functions related to handling chat messages in a stream.
mixin StreamMessageMixin {
  IsmLiveStreamController get _controller =>
      Get.find<IsmLiveStreamController>();
// Convert IsmLiveMessageModel to IsmLiveChatModel
  IsmLiveChatModel convertMessageToChat(IsmLiveMessageModel message) =>
      IsmLiveChatModel(
        streamId: message.streamId,
        messageId: message.messageId,
        userId: message.senderId,
        userIdentifier: message.senderIdentifier,
        userName: message.name,
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

// Handle incoming message based on its type
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

// Send a heart message to the stream
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

  // Send a gift message to the stream
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
    _controller._streamMessagesList.refresh();
  }
}
