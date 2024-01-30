part of '../stream_controller.dart';

mixin StreamAPIMixin {
  IsmLiveStreamController get _controller =>
      Get.find<IsmLiveStreamController>();

  IsmLiveDBWrapper get _dbWrapper => Get.find<IsmLiveDBWrapper>();

  final _memberDebouncer = IsmLiveDebouncer();
  final _viewerDebouncer = IsmLiveDebouncer();
  final _messagesDebouncer = IsmLiveDebouncer();

  Future<void> getUserDetails() async {
    await _controller._viewModel.getUserDetails();
    _controller.user = UserDetails.fromJson(
      _dbWrapper.getStringValue(IsmLiveLocalKeys.user),
    );
    _controller.update([IsmLiveHeader.updateId]);
  }

  Future<bool> _subscribeUser(
    bool isSubscribing,
  ) =>
      _controller._viewModel.subscribeUser(
        isSubscribing: isSubscribing,
      );

  Future<void> getStreams([
    IsmLiveStreamType? type,
  ]) async =>
      _controller.getStreamDebouncer.run(
        () => _getStreams(type),
      );

  Future<void> _getStreams([
    IsmLiveStreamType? type,
  ]) async {
    var streamType = type ?? _controller.streamType;
    _controller._streams[streamType] = await _controller._viewModel.getStreams(
      queryModel: streamType.queryModel,
    );
    _controller._streamRefreshControllers[streamType]!.refreshCompleted();
    IsmLiveUtility.updateLater(() {
      _controller.update([IsmLiveStreamListing.updateId]);
    });
  }

  Future<IsmLiveRTCModel?> getRTCToken(
    String streamId,
  ) =>
      _controller._viewModel.getRTCToken(streamId);

  Future<bool> leaveStream(
    String streamId,
  ) =>
      _controller._viewModel.leaveStream(streamId);

  Future<IsmLiveRTCModel?> createStream() async {
    var bytes = File(_controller.pickedImage!.path).readAsBytesSync();
    var type = _controller.pickedImage!.name.split('.').last;
    var image = await uploadImage(type, bytes);
    if (image.isNullOrEmpty) {
      return null;
    }
    return _controller._viewModel.createStream(
      IsmLiveCreateStreamModel(
        streamImage: image!,
        hdBroadcast: _controller.isHdBroadcast,
        enableRecording: _controller.isRecordingBroadcast,
        streamDescription: _controller.descriptionController.isEmpty
            ? 'N/A'
            : _controller.descriptionController.text,
      ),
    );
  }

  Future<bool> stopStream(
    String streamId,
  ) =>
      _controller._viewModel.stopStream(streamId);

  Future<void> getStreamMembers({
    required String streamId,
    required int limit,
    required int skip,
    String? searchTag,
  }) async =>
      _memberDebouncer.run(() => _getStreamMembers(
            streamId: streamId,
            limit: limit,
            skip: skip,
            searchTag: searchTag,
          ));

  Future<void> _getStreamMembers({
    required String streamId,
    required int limit,
    required int skip,
    String? searchTag,
  }) async {
    _controller.streamMembersList =
        await _controller._viewModel.getStreamMembers(
      streamId: streamId,
      limit: limit,
      skip: skip,
    );

    if (_controller.streamMembersList.isNotEmpty) {
      _controller.hostDetails = _controller.streamMembersList.firstWhere(
        (e) => e.isAdmin,
      );
    }
    _controller.update([IsmLiveStreamView.updateId]);
  }

  Future<void> getStreamViewer({
    required String streamId,
    int limit = 10,
    int skip = 0,
    String? searchTag,
  }) async =>
      _viewerDebouncer.run(
        () => _getStreamViewer(
          streamId: streamId,
          limit: limit,
          skip: skip,
          searchTag: searchTag,
        ),
      );

  Future<void> _getStreamViewer({
    required String streamId,
    required int limit,
    required int skip,
    String? searchTag,
  }) async {
    var res = await _controller._viewModel.getStreamViewer(
      streamId: streamId,
      limit: limit,
      skip: skip,
    );

    await _controller.addViewers(res);
  }

  Future<void> fetchMessages({
    required bool showLoading,
    required IsmLiveGetMessageModel getMessageModel,
  }) async =>
      _messagesDebouncer.run(
        () => _fetchMessages(
          getMessageModel: getMessageModel,
          showLoading: showLoading,
        ),
      );

  Future<void> _fetchMessages({
    required bool showLoading,
    required IsmLiveGetMessageModel getMessageModel,
  }) async {
    var res = await _controller._viewModel.fetchMessages(
      getMessageModel: getMessageModel,
      showLoading: showLoading,
    );
    await _controller.addMessages(res, false);
    if (_controller.messagesCount > 10) {
      _controller.messagesCount -= 10;
    } else {
      _controller.messagesCount = 0;
    }
  }

  Future<void> fetchMessagesCount({
    required bool showLoading,
    required IsmLiveGetMessageModel getMessageModel,
  }) async {
    _controller.messagesCount = await _controller._viewModel.fetchMessagesCount(
      getMessageModel: getMessageModel,
      showLoading: showLoading,
    );
  }

  Future<bool> sendMessage({
    required bool showLoading,
    required IsmLiveSendMessageModel sendMessageModel,
  }) async =>
      await _controller._viewModel.sendMessage(
        showLoading: showLoading,
        getMessageModel: sendMessageModel,
      );

  Future<bool> kickoutViewer({
    required String streamId,
    required String viewerId,
  }) =>
      _controller._viewModel.kickoutViewer(
        streamId: streamId,
        viewerId: viewerId,
      );

  Future<void> fetchUsers({
    bool forceFetch = false,
    int limit = 15,
    int skip = 0,
    String? searchTag,
  }) async {
    if (forceFetch || _controller.usersList.isEmpty) {
      var list = await _controller._viewModel.fetchUsers(
        limit: limit,
        skip: skip,
        searchTag: searchTag,
      );
      _controller.usersList.addAll(list ?? []);
    }
    _controller.update([IsmLiveModeratorSheet.updateId]);
  }

  Future<bool> deleteMessage({
    required String streamId,
    required String messageId,
  }) =>
      _controller._viewModel.deleteMessage(
        streamId: streamId,
        messageId: messageId,
      );

  Future<String?> uploadImage(String mediaExtension, Uint8List bytes) async {
    IsmLiveUtility.showLoader(
      Get.context?.liveTranslations.uploadingImage ??
          IsmLiveStrings.uploadingImage,
    );
    var res = await _controller._viewModel.getPresignedUrl(
      showLoader: false,
      userIdentifier: _controller.user?.userIdentifier ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      mediaExtension: mediaExtension,
    );
    if (res == null) {
      IsmLiveUtility.closeLoader();

      return null;
    }
    var urlResponse = await _controller._viewModel.updatePresignedUrl(
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
