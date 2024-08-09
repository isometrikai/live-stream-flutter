import 'dart:typed_data';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';

class IsmLiveStreamRepository {
  const IsmLiveStreamRepository(this._apiWrapper);
  final IsmLiveApiWrapper _apiWrapper;

  Future<IsmLiveResponseModel> getUserDetails() async =>
      _apiWrapper.makeRequest(
        IsmLiveApis.userDetails,
        type: IsmLiveRequestType.get,
        headers: IsmLiveUtility.tokenHeader(),
      );

  Future<IsmLiveResponseModel> userDetails() async => _apiWrapper.makeRequest(
        IsmLiveApis.getUserDetails,
        type: IsmLiveRequestType.get,
        headers: IsmLiveUtility.tokenHeader(),
      );

  Future<IsmLiveResponseModel> subscribeUser({
    required bool isSubscribing,
  }) {
    var api = IsmLiveApis.userSubscription;
    if (!isSubscribing) {
      api = '$api?streamStartChannel=true';
    }
    return _apiWrapper.makeRequest(
      api,
      type: isSubscribing ? IsmLiveRequestType.put : IsmLiveRequestType.delete,
      payload: !isSubscribing
          ? null
          : {
              'streamStartChannel': true,
            },
      headers: IsmLiveUtility.tokenHeader(),
    );
  }

  // Future<IsmLiveResponseModel> getStreams({
  //   required IsmLiveStreamQueryModel queryModel,
  // }) =>
  //     _apiWrapper.makeRequest(
  //       '${IsmLiveApis.getStreams}?${queryModel.toMap().makeQuery()}',
  //       type: IsmLiveRequestType.get,
  //       headers: IsmLiveUtility.tokenHeader(),
  //       showDialog: false,
  //     );

  Future<IsmLiveResponseModel> getStreams({
    required IsmLiveStreamQueryModel queryModel,
  }) =>
      _apiWrapper.makeRequest(
        '${IsmLiveApis.fetchStream}?${queryModel.toMap().makeQuery()}',
        type: IsmLiveRequestType.get,
        baseUrl: IsmLiveApis.baseUrlStream,
        headers: IsmLiveUtility.tokenHeader(),
        showDialog: false,
      );

  Future<IsmLiveResponseModel> getRTCToken(String streamId, bool showLoader) =>
      _apiWrapper.makeRequest(
        IsmLiveApis.viewer,
        type: IsmLiveRequestType.post,
        headers: IsmLiveUtility.tokenHeader(),
        payload: {
          'streamId': streamId,
        },
        showLoader: showLoader,
      );

  Future<IsmLiveResponseModel> leaveStream(
    String streamId,
  ) =>
      _apiWrapper.makeRequest(
        '${IsmLiveApis.leaveStream}?streamId=$streamId',
        type: IsmLiveRequestType.delete,
        headers: IsmLiveUtility.tokenHeader(),
        showLoader: true,
        showDialog: false,
      );

  Future<IsmLiveResponseModel> createStream(
    IsmLiveCreateStreamModel streamModel,
    UserDetails? user,
  ) =>
      _apiWrapper.makeRequest(
        IsmLiveApis.newStream,
        baseUrl: IsmLiveApis.baseUrlStream,
        type: IsmLiveRequestType.post,
        headers: IsmLiveUtility.tokenHeader(),
        payload: {
          'isRecorded': false,
          'rtmpIngest': streamModel.rtmpIngest,
          'enableRecording': streamModel.enableRecording,
          'streamDescription': streamModel.streamDescription,
          'isScheduledStream': streamModel.isScheduledStream,
          'scheduleStartTime': streamModel.scheduleStartTime,
          'members': streamModel.members,
          'isometrikUserId': user?.userId,
          'country': streamModel.metaData?.country ?? 'INDIA',
          'persistRtmpIngestEndpoint': streamModel.persistRtmpIngestEndpoint,
          'userName': user?.userName,
          'productsLinked': streamModel.productsLinked,
          'restream': streamModel.restream,
          'userType': 1,
          'currency': streamModel.paymentCurrencyCode,
          'audioOnly': streamModel.audioOnly,
          'isPublicStream': streamModel.isPublic,
          'isPaid': streamModel.isPaid,
          'lowLatencyMode': streamModel.lowLatencyMode,
          'hdBroadcast': streamModel.hdBroadcast,
          'isGroupStream': true,
          'isPublic': streamModel.isPublic,
          'paymentType': streamModel.paymentType,
          'products': streamModel.products,
          'multiLive': streamModel.multiLive,
          'isSelfHosted': streamModel.selfHosted,
          'userId': user?.userId,
          'createdBy': user?.userId,
          'streamImage': streamModel.streamImage,
          'amount': streamModel.paymentAmount,
        },
        showLoader: true,
      );

  Future<IsmLiveResponseModel> stopStream(
    String streamId,
    String isometrikUserId,
  ) =>
      _apiWrapper.makeRequest(
        IsmLiveApis.newStream,
        baseUrl: IsmLiveApis.baseUrlStream,
        type: IsmLiveRequestType.patch,
        headers: IsmLiveUtility.tokenHeader(),
        payload: {
          'streamId': streamId,
          'isometrikUserId': isometrikUserId,
        },
        showLoader: true,
        showDialog: false,
      );

  Future<IsmLiveResponseModel> getPresignedUrl({
    required bool showLoader,
    required String userIdentifier,
    required String mediaExtension,
  }) =>
      _apiWrapper.makeRequest(
        '${IsmLiveApis.presignedurl}?userIdentifier=$userIdentifier&mediaExtension=$mediaExtension',
        type: IsmLiveRequestType.get,
        headers: IsmLiveUtility.secretHeader(),
        showLoader: showLoader,
      );

  Future<IsmLiveResponseModel> getStreamMembers({
    required String streamId,
    required int limit,
    required int skip,
    String? searchTag,
  }) =>
      _apiWrapper.makeRequest(
        '${IsmLiveApis.getStreamMembers}?streamId=$streamId&limit=$limit&skip=$skip',
        type: IsmLiveRequestType.get,
        headers: IsmLiveUtility.tokenHeader(),
        showLoader: false,
        showDialog: false,
      );

  Future<IsmLiveResponseModel> getStreamViewer({
    required String streamId,
    required int limit,
    required int skip,
    String? searchTag,
  }) =>
      _apiWrapper.makeRequest(
        '${IsmLiveApis.getStreamViewer}?streamId=$streamId&limit=$limit&skip=$skip',
        type: IsmLiveRequestType.get,
        headers: IsmLiveUtility.tokenHeader(),
        showLoader: false,
        showDialog: false,
      );

  Future<IsmLiveResponseModel> updatePresignedUrl({
    required bool showLoading,
    required String presignedUrl,
    required Uint8List file,
  }) =>
      _apiWrapper.makeRequest(
        presignedUrl,
        baseUrl: '',
        type: IsmLiveRequestType.put,
        payload: file,
        headers: {},
        showLoader: showLoading,
        shouldEncodePayload: false,
      );

  // Future<IsmLiveResponseModel> getEndStream({
  //   required bool showLoading,
  //   required String streamId,
  // }) =>
  //     _apiWrapper.makeRequest(
  //       '${IsmLiveApis.getEndStream}?streamId=$streamId',
  //       type: IsmLiveRequestType.get,
  //       headers: IsmLiveUtility.tokenHeader(),
  //       showLoader: showLoading,
  //     );

  Future<IsmLiveResponseModel> sendMessage({
    required bool showLoading,
    required Map<String, dynamic> payload,
  }) =>
      _apiWrapper.makeRequest(
        IsmLiveApis.postMessage,
        type: IsmLiveRequestType.post,
        headers: IsmLiveUtility.tokenHeader(),
        payload: payload,
        showLoader: showLoading,
      );

  Future<IsmLiveResponseModel> replyMessage({
    required bool showLoading,
    required Map<String, dynamic> payload,
  }) =>
      _apiWrapper.makeRequest(
        IsmLiveApis.replyMessage,
        type: IsmLiveRequestType.post,
        headers: IsmLiveUtility.tokenHeader(),
        payload: payload,
        showLoader: showLoading,
      );

  Future<IsmLiveResponseModel> fetchMessages({
    required bool showLoading,
    required List<int> messageType,
    required Map<String, dynamic> payload,
  }) {
    payload['messageType'] = null;
    return _apiWrapper.makeRequest(
      '${IsmLiveApis.messages}?${payload.makeQuery()}&messageTypes=${messageType.join(',')}',
      type: IsmLiveRequestType.get,
      headers: IsmLiveUtility.tokenHeader(),
      showLoader: showLoading,
    );
  }

  Future<IsmLiveResponseModel> fetchMessagesCount({
    required bool showLoading,
    required List<int> messageType,
    required Map<String, dynamic> payload,
  }) {
    payload['messageType'] = null;
    return _apiWrapper.makeRequest(
      '${IsmLiveApis.messagesCount}?${payload.makeQuery()}&messageTypes=${messageType.join(',')}',
      type: IsmLiveRequestType.get,
      headers: IsmLiveUtility.tokenHeader(),
      showLoader: showLoading,
      showDialog: false,
    );
  }

  Future<IsmLiveResponseModel> kickoutViewer({
    required String streamId,
    required String viewerId,
  }) {
    var payload = {
      'streamId': streamId,
      'viewerId': viewerId,
    };
    return _apiWrapper.makeRequest(
      '${IsmLiveApis.viewer}?${payload.makeQuery()}',
      type: IsmLiveRequestType.delete,
      headers: IsmLiveUtility.tokenHeader(),
      showLoader: true,
    );
  }

  Future<IsmLiveResponseModel> deleteMessage({
    required String streamId,
    required String messageId,
  }) {
    var payload = {
      'streamId': streamId,
      'messageId': messageId,
    };
    return _apiWrapper.makeRequest(
      '${IsmLiveApis.deleteMessage}?${payload.makeQuery()}',
      type: IsmLiveRequestType.delete,
      headers: IsmLiveUtility.tokenHeader(),
      showLoader: false,
    );
  }

  Future<IsmLiveResponseModel> fetchUsers({
    required bool isLoading,
    required int skip,
    required int limit,
    String? searchTag,
  }) async {
    var payload = {
      'skip': skip,
      'limit': limit,
      'searchTag': searchTag,
    };

    var res = await _apiWrapper.makeRequest(
      '${IsmLiveApis.getUsers}?${payload.makeQuery()}',
      type: IsmLiveRequestType.get,
      showLoader: isLoading,
      showDialog: false,
      headers: IsmLiveUtility.secretHeader(),
    );

    return res;
  }

  Future<IsmLiveResponseModel> fetchModerators({
    required bool isLoading,
    required int skip,
    required String streamId,
    required int limit,
    String? searchTag,
  }) async {
    var payload = {
      'streamId': streamId,
      'skip': skip,
      'limit': limit,
      'searchTag': searchTag,
    };

    var res = await _apiWrapper.makeRequest(
      '${IsmLiveApis.getModerators}?${payload.makeQuery()}',
      type: IsmLiveRequestType.get,
      showLoader: isLoading,
      showDialog: false,
      headers: IsmLiveUtility.tokenHeader(),
    );

    return res;
  }

  Future<IsmLiveResponseModel> makeModerator({
    required String streamId,
    required String moderatorId,
  }) {
    var payload = {
      'streamId': streamId,
      'moderatorId': moderatorId,
    };
    return _apiWrapper.makeRequest(
      IsmLiveApis.moderator,
      type: IsmLiveRequestType.post,
      payload: payload,
      headers: IsmLiveUtility.tokenHeader(),
      showLoader: true,
    );
  }

  Future<IsmLiveResponseModel> removeModerator({
    required String streamId,
    required String moderatorId,
  }) {
    var payload = {
      'streamId': streamId,
      'moderatorId': moderatorId,
    };
    return _apiWrapper.makeRequest(
      '${IsmLiveApis.moderator}?${payload.makeQuery()}',
      type: IsmLiveRequestType.delete,
      headers: IsmLiveUtility.tokenHeader(),
      showLoader: true,
    );
  }

  Future<IsmLiveResponseModel> leaveModerator(String streamId) {
    var payload = {
      'streamId': streamId,
    };
    return _apiWrapper.makeRequest(
      '${IsmLiveApis.leaveModerator}?${payload.makeQuery()}',
      type: IsmLiveRequestType.delete,
      headers: IsmLiveUtility.tokenHeader(),
      showLoader: true,
      showDialog: false,
    );
  }

  Future<IsmLiveResponseModel> requestCopublisher(String streamId) {
    var payload = {
      'streamId': streamId,
    };
    return _apiWrapper.makeRequest(
      IsmLiveApis.copublisherRequest,
      type: IsmLiveRequestType.post,
      headers: IsmLiveUtility.tokenHeader(),
      payload: payload,
      showLoader: true,
    );
  }

  Future<IsmLiveResponseModel> fetchCopublisherRequests({
    required int skip,
    required String streamId,
    required int limit,
    String? searchTag,
  }) async {
    var payload = {
      'streamId': streamId,
      'skip': skip,
      'limit': limit,
      'searchTag': searchTag,
    };

    return await _apiWrapper.makeRequest(
      '${IsmLiveApis.copublishersRequests}?${payload.makeQuery()}',
      type: IsmLiveRequestType.get,
      headers: IsmLiveUtility.tokenHeader(),
      showDialog: false,
    );
  }

  Future<IsmLiveResponseModel> fetchEligibleMembers({
    required int skip,
    required String streamId,
    required int limit,
    String? searchTag,
  }) async {
    var payload = {
      'streamId': streamId,
      'skip': skip,
      'limit': limit,
      'searchTag': searchTag,
    };

    return await _apiWrapper.makeRequest(
      '${IsmLiveApis.eligibleMembers}?${payload.makeQuery()}',
      type: IsmLiveRequestType.get,
      headers: IsmLiveUtility.tokenHeader(),
      showDialog: false,
    );
  }

  Future<IsmLiveResponseModel> acceptCopublisherRequest({
    required String streamId,
    required String requestById,
  }) {
    var payload = {
      'streamId': streamId,
      'requestByUserId': requestById,
    };
    return _apiWrapper.makeRequest(
      '${IsmLiveApis.acceptCopublisher}?${payload.makeQuery()}',
      type: IsmLiveRequestType.post,
      headers: IsmLiveUtility.tokenHeader(),
      showLoader: true,
    );
  }

  Future<IsmLiveResponseModel> denyCopublisherRequest({
    required String streamId,
    required String requestById,
  }) {
    var payload = {
      'streamId': streamId,
      'requestByUserId': requestById,
    };
    return _apiWrapper.makeRequest(
      '${IsmLiveApis.denyCopublisher}?${payload.makeQuery()}',
      type: IsmLiveRequestType.post,
      headers: IsmLiveUtility.tokenHeader(),
      showLoader: true,
    );
  }

  Future<IsmLiveResponseModel> addMember({
    required String streamId,
    required String memberId,
  }) {
    var payload = {
      'streamId': streamId,
      'memberId': memberId,
    };
    return _apiWrapper.makeRequest(
      IsmLiveApis.member,
      type: IsmLiveRequestType.post,
      payload: payload,
      headers: IsmLiveUtility.tokenHeader(),
      showLoader: true,
    );
  }

  Future<IsmLiveResponseModel> removeMember({
    required String streamId,
    required String memberId,
  }) {
    var payload = {
      'streamId': streamId,
      'memberId': memberId,
    };
    return _apiWrapper.makeRequest(
      '${IsmLiveApis.member}?${payload.makeQuery()}',
      type: IsmLiveRequestType.delete,
      headers: IsmLiveUtility.tokenHeader(),
      showLoader: true,
    );
  }

  Future<IsmLiveResponseModel> leaveMember({
    required String streamId,
  }) {
    var payload = {
      'streamId': streamId,
    };
    return _apiWrapper.makeRequest(
      '${IsmLiveApis.leaveMember}?${payload.makeQuery()}',
      type: IsmLiveRequestType.delete,
      headers: IsmLiveUtility.tokenHeader(),
      showLoader: true,
      showDialog: false,
    );
  }

  Future<IsmLiveResponseModel> statusCopublisherRequest({
    required String streamId,
  }) {
    var payload = {
      'streamId': streamId,
    };
    return _apiWrapper.makeRequest(
      '${IsmLiveApis.statusCopublisher}?${payload.makeQuery()}',
      type: IsmLiveRequestType.get,
      headers: IsmLiveUtility.tokenHeader(),
      showLoader: false,
      showDialog: false,
    );
  }

  Future<IsmLiveResponseModel> switchViewer({
    required String streamId,
  }) {
    var payload = {
      'streamId': streamId,
    };
    return _apiWrapper.makeRequest(
      IsmLiveApis.switchProfile,
      type: IsmLiveRequestType.post,
      payload: payload,
      headers: IsmLiveUtility.tokenHeader(),
      showLoader: true,
    );
  }

  Future<IsmLiveResponseModel> fetchProductDetails() {
    var parameter = {
      'url':
          'https://www.lenskart.com/vincent-chase-vc-s13981-c3-sunglasses.html',
    };
    return _apiWrapper.makeRequest(
      '${IsmLiveApis.productDetails}?${parameter.makeQuery()}',
      type: IsmLiveRequestType.get,
      headers: IsmLiveUtility.tokenHeader(),
      showLoader: true,
    );
  }

  Future<IsmLiveResponseModel> fetchProducts({
    required int skip,
    required int limit,
    String? searchTag,
  }) async {
    var payload = {
      'skip': skip,
      'limit': limit,
      'searchTag': searchTag,
    };

    return await _apiWrapper.makeRequest(
      '${IsmLiveApis.products}?${payload.makeQuery()}',
      type: IsmLiveRequestType.get,
      headers: IsmLiveUtility.tokenHeader(),
    );
  }

  Future<IsmLiveResponseModel> getRestreamChannels() => _apiWrapper.makeRequest(
        IsmLiveApis.restreamChannel,
        type: IsmLiveRequestType.get,
        headers: IsmLiveUtility.tokenHeader(),
        showLoader: false,
        showDialog: false,
      );

  Future<IsmLiveResponseModel> addRestreamChannel({
    required String url,
    required String channelName,
    required int channelType,
    required bool enable,
  }) {
    final payload = {
      'ingestUrl': url,
      'enabled': enable,
      'channelType': channelType,
      'channelName': channelName,
    };
    return _apiWrapper.makeRequest(
      IsmLiveApis.restreamChannel,
      type: IsmLiveRequestType.post,
      payload: payload,
      headers: IsmLiveUtility.tokenHeader(),
      showLoader: true,
      showDialog: true,
    );
  }

  Future<IsmLiveResponseModel> editRestreamChannel({
    required String url,
    required String channelId,
    required String channelName,
    required int channelType,
    required bool enable,
  }) {
    final payload = {
      'ingestUrl': url,
      'enabled': enable,
      'channelType': channelType,
      'channelName': channelName,
      'channelId': channelId,
    };
    return _apiWrapper.makeRequest(
      IsmLiveApis.restreamChannel,
      type: IsmLiveRequestType.patch,
      payload: payload,
      headers: IsmLiveUtility.tokenHeader(),
      showLoader: true,
      showDialog: true,
    );
  }

  Future<IsmLiveResponseModel> sendHearts({
    required String streamId,
    required String senderId,
    required String senderImage,
    required String senderName,
    required String deviceId,
    required String customType,
  }) {
    final payload = {
      'streamId': streamId,
      'senderImage': senderImage,
      'senderName': senderName,
      'deviceId': deviceId,
      'customType': customType,
      'senderId': senderId,
    };
    return _apiWrapper.makeRequest(
      IsmLiveApis.sendHearts,
      baseUrl: IsmLiveApis.baseUrlStream,
      type: IsmLiveRequestType.post,
      payload: payload,
      headers: IsmLiveUtility.tokenHeader(),
    );
  }

  Future<IsmLiveResponseModel> streamAnalytics({
    required String streamId,
  }) {
    var payload = {
      'streamId': streamId,
    };

    return _apiWrapper.makeRequest(
      '${IsmLiveApis.streamAnalytics}?${payload.makeQuery()}',
      baseUrl: IsmLiveApis.baseUrlStream,
      type: IsmLiveRequestType.get,
      headers: IsmLiveUtility.tokenHeader(),
    );
  }

  Future<IsmLiveResponseModel> buyStream({
    required String streamId,
  }) {
    var payload = {
      'streamId': streamId,
    };

    return _apiWrapper.makeRequest(
      '${IsmLiveApis.buyStream}',
      baseUrl: IsmLiveApis.baseUrlStream,
      type: IsmLiveRequestType.post,
      showLoader: true,
      payload: payload,
      headers: IsmLiveUtility.tokenHeader(),
    );
  }

  Future<IsmLiveResponseModel> streamAnalyticsViewers({
    required String streamId,
    required int skip,
    required int limit,
  }) {
    var payload = {
      'streamId': streamId,
      'skip': skip,
      'limit': limit,
    };
    return _apiWrapper.makeRequest(
      '${IsmLiveApis.streamAnalyticsViewers}?${payload.makeQuery()}',
      baseUrl: IsmLiveApis.baseUrlStream,
      type: IsmLiveRequestType.get,
      headers: IsmLiveUtility.tokenHeader(),
      showLoader: true,
      showDialog: false,
    );
  }

  Future<IsmLiveResponseModel> fetchScheduledStream({
    required int skip,
    required int limit,
  }) {
    var payload = {
      'skip': skip,
      'limit': limit,
    };
    return _apiWrapper.makeRequest(
      '${IsmLiveApis.fetchScheduledStream}?${payload.makeQuery()}',
      baseUrl: IsmLiveApis.baseUrlStream,
      type: IsmLiveRequestType.get,
      headers: IsmLiveUtility.tokenHeader(),
      showLoader: true,
      showDialog: false,
    );
  }

  Future<IsmLiveResponseModel> totalWalletCoins() {
    var payload = {
      'currency': 'COIN',
    };
    return _apiWrapper.makeRequest(
      '${IsmLiveApis.fetchCoins}?${payload.makeQuery()}',
      baseUrl: IsmLiveApis.baseUrlStream,
      type: IsmLiveRequestType.get,
      headers: IsmLiveUtility.tokenHeader(),
      showLoader: false,
      showDialog: false,
    );
  }
}
