part of '../stream_controller.dart';

mixin StreamAPIMixin {
  IsmLiveStreamController get _controller =>
      Get.find<IsmLiveStreamController>();

  IsmLiveDBWrapper get _dbWrapper => Get.find<IsmLiveDBWrapper>();

  IsmLiveStreamViewModel get _viewModel => _controller._viewModel;

  Future<void> getUserDetails() async {
    await _viewModel.getUserDetails();
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
      _viewModel.getRTCToken(streamId);

  Future<IsmLiveRTCModel?> createStream() async {
    var bytes = File(_controller.pickedImage!.path).readAsBytesSync();
    var type = _controller.pickedImage!.name.split('.').last;
    var image = await uploadImage(type, bytes);
    if (image.isNullOrEmpty) {
      return null;
    }
    return _viewModel.createStream(
      IsmLiveCreateStreamModel(
        streamImage: image!,
        hdBroadcast: _controller.isHdBroadcast,
        enableRecording: _controller.isRecordingBroadcast,
        streamDescription: _controller.descriptionController.text,
      ),
    );
  }

  Future<bool> stopStream(String streamId) => _viewModel.stopStream(streamId);

  Future<void> getStreamMembers({
    required String streamId,
    required int limit,
    required int skip,
    String? searchTag,
  }) async {
    _controller.streamMembersList = await _viewModel.getStreamMembers(
        streamId: streamId, limit: limit, skip: skip);

    if (_controller.streamMembersList.isNotEmpty) {
      _controller.hostDetails = _controller.streamMembersList
          .firstWhere((element) => element.isAdmin);
    }
  }

  Future<void> getStreamViewer({
    required String streamId,
    required int limit,
    required int skip,
    String? searchTag,
  }) async {
    _controller.streamViewersList = await _viewModel.getStreamViewer(
        streamId: streamId, limit: limit, skip: skip);
  }

  Future<String?> uploadImage(String mediaExtension, Uint8List bytes) async {
    IsmLiveUtility.showLoader();
    var res = await _viewModel.getPresignedUrl(
      showLoader: false,
      userIdentifier: _controller.user?.userIdentifier ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      mediaExtension: mediaExtension,
    );
    if (res == null) {
      IsmLiveUtility.closeLoader();

      return null;
    }
    var urlResponse = await _viewModel.updatePresignedUrl(
      showLoading: false,
      presignedUrl: res.presignedUrl ?? '',
      file: bytes,
    );
    IsmLiveUtility.closeLoader();

    if (urlResponse.statusCode != 200) {
      return null;
    }
    return res.mediaUrl ?? '';
  }
}
