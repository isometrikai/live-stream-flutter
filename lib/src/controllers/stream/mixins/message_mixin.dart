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

  IsmLiveStreamController get _controller => Get.find<IsmLiveStreamController>();

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
        IsmLiveLog.success('Gift Recieved');
        IsmLiveLog.success(message);
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

    if (isSent) {
      _controller.messageFieldController.clear();
    }
  }
}
