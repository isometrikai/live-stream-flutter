part of '../stream_controller.dart';

mixin StreamAPIMixin {
  IsmLiveStreamController get _controller =>
      Get.find<IsmLiveStreamController>();

  IsmLiveDBWrapper get _dbWrapper => Get.find<IsmLiveDBWrapper>();

  Future<void> getUserDetails() async {
    await _controller._viewModel.getUserDetails();
    _controller.user =
        UserDetails.fromJson(_dbWrapper.getStringValue(IsmLiveLocalKeys.user));
    _controller.update([IsmLiveHeader.updateId]);
  }

  Future<bool> _subscribeUser(bool isSubscribing) =>
      _controller._viewModel.subscribeUser(
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

  Future<IsmLiveRTCModel?> getRTCToken(String streamId) =>
      _controller._viewModel.getRTCToken(streamId);

  Future<IsmLiveRTCModel?> createStream() =>
      _controller._viewModel.createStream(
        IsmLiveCreateStreamModel(
            streamImage: _controller.streamImage ??
                'http://res.cloudinary.com/dbmv1uykj/image/upload/v1700742161/n0i3pwzqp98i8csd4uyk.jpg',
            hdBroadcast: _controller.isHdBroadcast,
            enableRecording: _controller.isRecordingBroadcast,
            streamDescription: _controller.descriptionController.text),
      );

  Future<bool> stopStream(String streamId) =>
      _controller._viewModel.stopStream(streamId);

  Future<void> getPresignedUrl(String mediaExtension, Uint8List bytes) async {
    var res = await _controller._viewModel.getPresignedUrl(
      showLoader: false,
      userIdentifier: DateTime.now().millisecondsSinceEpoch.toString(),
      mediaExtension: mediaExtension,
    );
    if (res == null) {
      return;
    }
    var urlResponse = await _controller._viewModel.updatePresignedUrl(
        showLoading: false, presignedUrl: res.presignedUrl ?? '', file: bytes);
    if (urlResponse.statusCode == 200) {
      _controller.streamImage = res.mediaUrl ?? '';
    }
  }
}
