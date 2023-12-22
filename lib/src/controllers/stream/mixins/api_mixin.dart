part of '../stream_controller.dart';

mixin StreamAPIMixin {
  IsmLiveStreamController get _controller => Get.find<IsmLiveStreamController>();

  IsmLiveDBWrapper get _dbWrapper => Get.find<IsmLiveDBWrapper>();

  Future<void> getUserDetails() async {
    await _controller._viewModel.getUserDetails();
    _controller.user = UserDetails.fromJson(_dbWrapper.getStringValue(IsmLiveLocalKeys.user));
    _controller.update([IsmLiveHeader.updateId]);
  }

  Future<bool> _subscribeUser(bool isSubscribing) => _controller._viewModel.subscribeUser(
        isSubscribing: isSubscribing,
      );

  Future<void> getStreams([IsmLiveStreamType? type]) async {
    var streamType = type ?? _controller.streamType;
    _controller._streams[streamType] = await _controller._viewModel.getStreams(
      queryModel: streamType.queryModel,
    );
    _controller._streamRefreshControllers[streamType]!.refreshCompleted();
    IsmLiveUtility.updateLater(() {
      _controller.update([IsmLiveStreamListing.updateId]);
    });
  }

  Future<IsmLiveRTCModel?> getRTCToken(String streamId) => _controller._viewModel.getRTCToken(streamId);

  Future<IsmLiveRTCModel?> createStream() => _controller._viewModel.createStream(
        const IsmLiveCreateStreamModel(),
      );

  Future<bool> stopStream(String streamId) => _controller._viewModel.stopStream(streamId);
}
