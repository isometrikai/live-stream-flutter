import 'dart:typed_data';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';

class IsmLiveStreamRepository {
  const IsmLiveStreamRepository(this._apiWrapper);
  final IsmLiveApiWrapper _apiWrapper;

  Future<IsmLiveResponseModel> getUserDetails() async => _apiWrapper.makeRequest(
        IsmLiveApis.userDetails,
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

  Future<IsmLiveResponseModel> getStreams({
    required IsmLiveStreamQueryModel queryModel,
  }) =>
      _apiWrapper.makeRequest(
        '${IsmLiveApis.getStreams}?${queryModel.toMap().makeQuery()}',
        type: IsmLiveRequestType.get,
        headers: IsmLiveUtility.tokenHeader(),
        showDialog: false,
      );

  Future<IsmLiveResponseModel> getRTCToken(
    String streamId,
  ) =>
      _apiWrapper.makeRequest(
        IsmLiveApis.viewer,
        type: IsmLiveRequestType.post,
        headers: IsmLiveUtility.tokenHeader(),
        payload: {
          'streamId': streamId,
        },
        showLoader: true,
      );

  Future<IsmLiveResponseModel> leaveStream(
    String streamId,
  ) =>
      _apiWrapper.makeRequest(
        '${IsmLiveApis.leaveStream}?streamId=$streamId',
        type: IsmLiveRequestType.delete,
        headers: IsmLiveUtility.tokenHeader(),
        showLoader: true,
      );

  Future<IsmLiveResponseModel> createStream(
    IsmLiveCreateStreamModel streamModel,
  ) =>
      _apiWrapper.makeRequest(
        IsmLiveApis.stream,
        type: IsmLiveRequestType.post,
        headers: IsmLiveUtility.tokenHeader(),
        payload: streamModel.toMap(),
        showLoader: true,
      );

  Future<IsmLiveResponseModel> stopStream(
    String streamId,
  ) =>
      _apiWrapper.makeRequest(
        IsmLiveApis.stream,
        type: IsmLiveRequestType.put,
        headers: IsmLiveUtility.tokenHeader(),
        payload: {
          'streamId': streamId,
        },
        showLoader: true,
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

  Future<IsmLiveResponseModel> fetchMessages({
    required bool showLoading,
    required Map<String, dynamic> payload,
  }) =>
      _apiWrapper.makeRequest(
        '${IsmLiveApis.getMessages}?${payload.makeQuery()}',
        type: IsmLiveRequestType.get,
        headers: IsmLiveUtility.tokenHeader(),
        showLoader: showLoading,
      );

  Future<IsmLiveResponseModel> fetchMessagesCount({
    required bool showLoading,
    required Map<String, dynamic> payload,
  }) =>
      _apiWrapper.makeRequest(
        '${IsmLiveApis.getMessagesCont}?${payload.makeQuery()}',
        type: IsmLiveRequestType.get,
        headers: IsmLiveUtility.tokenHeader(),
        showLoader: showLoading,
        showDialog: false,
      );

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

  Future<IsmLiveResponseModel?> fetchUsers({
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
    );
  }
}
