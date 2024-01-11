part of '../stream_controller.dart';

mixin StreamMessageMixin {
  List<String> giftList = [
    IsmLiveAssetConstants.bell,
    IsmLiveAssetConstants.cherry,
    IsmLiveAssetConstants.icecream,
    IsmLiveAssetConstants.kiss,
    IsmLiveAssetConstants.lolipop,
    IsmLiveAssetConstants.paw,
  ];

  IsmLiveStreamController get _controller =>
      Get.find<IsmLiveStreamController>();

  Future<void> handleMessage(
    IsmLiveMessageModel message, [
    bool isMqtt = true,
  ]) async {
    switch (message.messageType) {
      case IsmLiveMessageType.normal:
        await _controller.addMessages([message], isMqtt);
        await _controller.messagesListController.animateTo(
          _controller.messagesListController.position.maxScrollExtent +
              IsmLiveDimens.hundred,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
        break;
      case IsmLiveMessageType.heart:
        _controller.addHeart(message);
        break;
      case IsmLiveMessageType.gift:
        IsmLiveLog.success('Gift Recieved');
        // TODO: Handle Gift animation
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

    if (isSent) {
      _controller.messageFieldController.clear();
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
    required String body,
  }) async {
    final isSent = await _controller.sendMessage(
      showLoading: false,
      sendMessageModel: IsmLiveSendMessageModel(
        streamId: streamId,
        body: body,
        searchableTags: [body],
        metaData: const IsmLiveMetaData(),
        deviceId: _controller.configuration?.projectConfig.deviceId ?? '',
        messageType: IsmLiveMessageType.gift,
      ),
    );

    if (isSent) {
      _controller.messageFieldController.clear();
    }
  }
}
