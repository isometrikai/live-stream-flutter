part of '../stream_controller.dart';

/// A mixin containing methods related to API calls for managing streams and users.
mixin StreamAPIMixin {
  IsmLiveStreamController get _controller =>
      Get.find<IsmLiveStreamController>();

  /// Get the instance of IsmLiveDBWrapper using GetX.
  IsmLiveDBWrapper get _dbWrapper => Get.find<IsmLiveDBWrapper>();

  // Debouncers for handling multiple API calls.
  final _memberDebouncer = IsmLiveDebouncer();
  final _viewerDebouncer = IsmLiveDebouncer();
  final _messagesDebouncer = IsmLiveDebouncer();
  final _usersDebouncer = IsmLiveDebouncer();
  final _copublisherRequestsDebouncer = IsmLiveDebouncer();
  final _eligibleMembersDebouncer = IsmLiveDebouncer();
  final _moderatorsDebouncer = IsmLiveDebouncer();
  final _productsDebouncer = IsmLiveDebouncer();

  /// Fetch user details from local storage.
  Future<void> getUserDetails() async {
    await _controller._viewModel.getUserDetails();
    _controller.user = UserDetails.fromJson(
      _dbWrapper.getStringValue(IsmLiveLocalKeys.user),
    );
    _controller.update([IsmLiveHeader.updateId]);
  }

  /// Subscribe or unsubscribe the current user to/from the platform.
  Future<bool> _subscribeUser(
    bool isSubscribing,
  ) =>
      _controller._viewModel.subscribeUser(
        isSubscribing: isSubscribing,
      );

  /// Get streams based on the specified type (e.g., featured, trending, etc.).
  Future<void> getStreams([
    IsmLiveStreamType? type,
  ]) async =>
      _controller.getStreamDebouncer.run(
        () => _getStreams(type),
      );

  /// Internal method for getting streams based on the specified type.
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

  /// Get an RTC token for joining a stream.
  Future<IsmLiveRTCModel?> getRTCToken(
    String streamId,
  ) =>
      _controller._viewModel.getRTCToken(streamId);

//Leaves a live stream.
  Future<bool> leaveStream(
    String streamId,
  ) =>
      _controller._viewModel.leaveStream(streamId);

// Creates a new live stream with the provided details.
  Future<({IsmLiveRTCModel? model, String image})?> createStream() async {
    var bytes = File(_controller.pickedImage!.path).readAsBytesSync();
    var type = _controller.pickedImage!.name.split('.').last;
    var image = await uploadImage(type, bytes);
    if (image == null || image.isNullOrEmpty) {
      return null;
    }
    return (
      model: await _controller._viewModel.createStream(
        IsmLiveCreateStreamModel(
          streamImage: image,
          productsLinked: _controller.selectedProductsList.isNotEmpty,
          products:
              _controller.selectedProductsList.map((e) => e.productId).toList(),
          hdBroadcast: _controller.isHdBroadcast,
          enableRecording: _controller.isRecordingBroadcast,
          streamDescription: _controller.descriptionController.isEmpty
              ? 'N/A'
              : _controller.descriptionController.text,
          restream: _controller.isRestreamBroadcast,
        ),
      ),
      image: image,
    );
  }

// Stops an ongoing live stream.
  Future<bool> stopStream(
    String streamId,
  ) =>
      _controller._viewModel.stopStream(streamId);

  Future<void> getStreamMembers({
    required String streamId,
    int limit = 15,
    int skip = 0,
    String? searchTag,
  }) async =>
      _memberDebouncer.run(
        () => _getStreamMembers(
          streamId: streamId,
          limit: limit,
          skip: skip,
          searchTag: searchTag,
        ),
      );

// Fetches members of a particular live stream.
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
    _controller.update([IsmLiveMembersSheet.updateId]);
  }

//  Fetches viewers of a particular live stream.
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

//  Fetches viewers of a particular live stream.
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

// Fetches messages related to a live stream.
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

// Fetches the count of messages related to a live stream.

  Future<void> fetchMessagesCount({
    required bool showLoading,
    required IsmLiveGetMessageModel getMessageModel,
  }) async {
    _controller.messagesCount = await _controller._viewModel.fetchMessagesCount(
      getMessageModel: getMessageModel,
      showLoading: showLoading,
    );
  }

//Sends a message related to a live stream.
  Future<bool> sendMessage({
    required bool showLoading,
    required IsmLiveSendMessageModel sendMessageModel,
  }) async =>
      await _controller._viewModel.sendMessage(
        showLoading: showLoading,
        getMessageModel: sendMessageModel,
      );

//Replies to a message related to a live stream.
  Future<bool> replyMessage({
    required bool showLoading,
    required IsmLiveSendMessageModel sendMessageModel,
  }) async =>
      await _controller._viewModel.replyMessage(
        showLoading: showLoading,
        getMessageModel: sendMessageModel,
      );

//Kicks out a viewer from a live stream.
  Future<bool> kickoutViewer({
    required String streamId,
    required String viewerId,
  }) =>
      _controller._viewModel.kickoutViewer(
        streamId: streamId,
        viewerId: viewerId,
      );
//  Fetches users of the application.
  Future<void> fetchUsers({
    bool forceFetch = false,
    int limit = 15,
    int skip = 0,
    String? searchTag,
  }) async =>
      _usersDebouncer.run(
        () => _fetchUsers(
          forceFetch,
          limit,
          skip,
          searchTag,
        ),
      );
  Future<void> _fetchUsers(
    bool forceFetch,
    int limit,
    int skip,
    String? searchTag,
  ) async {
    if (forceFetch || _controller.usersList.isEmpty) {
      var list = await _controller._viewModel.fetchUsers(
        limit: limit,
        skip: skip,
        searchTag: searchTag,
      );
      _controller.usersList.addAll(list ?? []);
    }
    _controller.update([IsmLiveUsersSheet.updateId]);
  }

//Fetches moderators of a particular live stream.
  Future<void> fetchModerators({
    bool forceFetch = false,
    required String streamId,
    int limit = 15,
    int skip = 0,
    String? searchTag,
  }) async {
    _moderatorsDebouncer.run(
      () async => await _fetchModerators(
        streamId: streamId,
        forceFetch: forceFetch,
        limit: limit,
        skip: skip,
        searchTag: searchTag,
      ),
    );
  }

  Future<void> _fetchModerators({
    bool forceFetch = false,
    required String streamId,
    int limit = 15,
    int skip = 0,
    String? searchTag,
  }) async {
    if (forceFetch || _controller.moderatorsList.isEmpty) {
      var list = await _controller._viewModel.fetchModerators(
        streamId: streamId,
        limit: limit,
        skip: skip,
        searchTag: searchTag,
      );
      _controller.moderatorsList.addAll(list);
      _controller.moderatorsList = _controller.moderatorsList.toSet().toList();
    }
    _controller.update([IsmLiveModeratorsSheet.updateId]);
  }

//Deletes a message related to a live stream.
  Future<bool> deleteMessage({
    required String streamId,
    required String messageId,
  }) =>
      _controller._viewModel.deleteMessage(
        streamId: streamId,
        messageId: messageId,
      );

//Uploads an image for a live stream.
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

//Makes a user a moderator of a live stream.
  Future<bool> makeModerator({
    required String streamId,
    required String moderatorId,
  }) =>
      _controller._viewModel.makeModerator(
        streamId: streamId,
        moderatorId: moderatorId,
      );

//Removes a moderator from a live stream.
  Future<bool> removeModerator({
    required String streamId,
    required String moderatorId,
  }) async {
    var res = await _controller._viewModel.removeModerator(
      streamId: streamId,
      moderatorId: moderatorId,
    );
    if (res) {
      _controller.moderatorsList
          .removeWhere((element) => element.userId == moderatorId);

      _controller.update([IsmLiveModeratorsSheet.updateId]);
    }

    return res;
  }

// Leaves the moderator status of a user from a live stream.
  Future<bool> leaveModerator(
    String streamId,
  ) async {
    var isLeave = await _controller._viewModel.leaveModerator(
      streamId,
    );
    _controller.isModerator = !isLeave;

    return isLeave;
  }

//  Requests to become a co-publisher of a live stream.
  Future<bool> requestCopublisher(
    String streamId,
  ) async {
    var isSend = await _controller._viewModel.requestCopublisher(
      streamId,
    );
    return isSend;
  }

//  Fetches requests for co-publishing a live stream.
  Future<void> fetchCopublisherRequests({
    bool forceFetch = false,
    required String streamId,
    int limit = 15,
    int skip = 0,
    String? searchTag,
  }) async {
    _copublisherRequestsDebouncer.run(
      () async => await _fetchCopublisherRequests(
        streamId: streamId,
        forceFetch: forceFetch,
        limit: limit,
        skip: skip,
        searchTag: searchTag,
      ),
    );
  }

  Future<void> _fetchCopublisherRequests({
    bool forceFetch = false,
    required String streamId,
    int limit = 15,
    int skip = 0,
    String? searchTag,
  }) async {
    if (forceFetch || _controller.copublisherRequestsList.isEmpty) {
      var list = await _controller._viewModel.fetchCopublisherRequests(
        streamId: streamId,
        limit: limit,
        skip: skip,
        searchTag: searchTag,
      );
      _controller.copublisherRequestsList.addAll(list);
      _controller.copublisherRequestsList =
          _controller.copublisherRequestsList.toSet().toList();
    }
    _controller.update([IsmLiveCopublishingHostSheet.updateId]);
  }

// Fetches eligible members for co-publishing a live stream.
  Future<void> fetchEligibleMembers({
    bool forceFetch = false,
    required String streamId,
    int limit = 15,
    int skip = 0,
    String? searchTag,
  }) async {
    _eligibleMembersDebouncer.run(
      () async => await _fetchEligibleMembers(
        streamId: streamId,
        forceFetch: forceFetch,
        limit: limit,
        skip: skip,
        searchTag: searchTag,
      ),
    );
  }

  Future<void> _fetchEligibleMembers({
    bool forceFetch = false,
    required String streamId,
    int limit = 15,
    int skip = 0,
    String? searchTag,
  }) async {
    if (forceFetch || _controller.eligibleMembersList.isEmpty) {
      var list = await _controller._viewModel.fetchEligibleMembers(
        streamId: streamId,
        limit: limit,
        skip: skip,
        searchTag: searchTag,
      );
      _controller.eligibleMembersList.addAll(list);
      _controller.eligibleMembersList =
          _controller.eligibleMembersList.toSet().toList();
    }
    _controller.update([IsmLiveCopublishingHostSheet.updateId]);
  }

//  Accepts a request for co-publishing a live stream.
  Future<bool> acceptCopublisherRequest({
    required String streamId,
    required String requestById,
  }) async {
    var res = await _controller._viewModel.acceptCopublisherRequest(
      streamId: streamId,
      requestById: requestById,
    );
    if (res) {
      _controller.copublisherRequestsList
          .removeWhere((element) => element.userId == requestById);

      _controller.update([IsmLiveCopublishingHostSheet.updateId]);
    }

    return res;
  }

//Denies a request for co-publishing a live stream.
  Future<bool> denyCopublisherRequest({
    required String streamId,
    required String requestById,
  }) async {
    var res = await _controller._viewModel.denyCopublisherRequest(
      streamId: streamId,
      requestById: requestById,
    );
    if (res) {
      _controller.copublisherRequestsList
          .removeWhere((element) => element.userId == requestById);

      _controller.update([IsmLiveCopublishingHostSheet.updateId]);
    }

    return res;
  }

// Adds a member to a live stream.
  Future<bool> addMember({
    required String streamId,
    required String memberId,
  }) async {
    var res = await _controller._viewModel.addMember(
      streamId: streamId,
      memberId: memberId,
    );
    if (res) {
      _controller.eligibleMembersList
          .removeWhere((element) => element.userId == memberId);

      _controller.update([IsmLiveCopublishingHostSheet.updateId]);
    }

    return res;
  }

// Removes a member from a live stream.
  Future<bool> removeMember({
    required String streamId,
    required String memberId,
  }) async {
    var res = await _controller._viewModel.removeMember(
      streamId: streamId,
      memberId: memberId,
    );
    if (res) {
      _controller.streamMembersList
          .removeWhere((element) => element.userId == memberId);
      _controller.update([IsmLiveCopublishingHostSheet.updateId]);
    }

    return res;
  }

//Leaves a live stream as a member.
  Future<bool> leaveMember({
    required String streamId,
  }) async {
    var res = await _controller._viewModel.leaveMember(
      streamId: streamId,
    );
    if (res) {
      _controller.streamMembersList
          .removeWhere((element) => element.userId == _controller.user?.userId);

      _controller.update([IsmLiveMembersSheet.updateId]);
    }

    return res;
  }

//  Fetches the status of a co-publisher request.
  Future<void> statusCopublisherRequest(
    String streamId,
  ) async {
    var res = await _controller._viewModel.statusCopublisherRequest(
      streamId: streamId,
    );
    if (res != null) {
      if (res.accepted) {
        _controller.memberStatus = IsmLiveMemberStatus.requestApproved;
      } else if (res.pending) {
        _controller.memberStatus = IsmLiveMemberStatus.requested;
      }
    }
  }

// Switches the viewer to a different live stream.
  Future<String?> switchViewer({
    required String streamId,
  }) =>
      _controller._viewModel.switchViewer(
        streamId: streamId,
      );
// Fetches products associated with a live stream.
  Future<void> fetchProducts({
    bool forceFetch = false,
    int limit = 15,
    int skip = 0,
    String? searchTag,
  }) async {
    _productsDebouncer.run(
      () async => await _fetchProducts(
        forceFetch: forceFetch,
        limit: limit,
        skip: skip,
        searchTag: searchTag,
      ),
    );
  }

  Future<void> _fetchProducts({
    bool forceFetch = false,
    int limit = 15,
    int skip = 0,
    String? searchTag,
  }) async {
    if (forceFetch || _controller.productsList.isEmpty) {
      var list = await _controller._viewModel.fetchProducts(
        limit: limit,
        skip: skip,
        searchTag: searchTag,
      );
      _controller.productsList.addAll(list);
    }

    _controller.update([IsmLiveAddProduct.updateId]);
  }

  Future<void> getRestreamChannels() =>
      _controller._viewModel.getRestreamChannels();

  Future<bool> enableRestreamChannel(bool enable) =>
      _controller._viewModel.addRestreamChannel(
        url: _controller.rtmlUrl.text.trim(),
        enable: enable,
      );
}
