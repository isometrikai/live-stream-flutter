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
      );

  Future<IsmLiveResponseModel> getRTCToken(
    String streamId,
  ) =>
      _apiWrapper.makeRequest(
        IsmLiveApis.getRTCToken,
        type: IsmLiveRequestType.post,
        headers: IsmLiveUtility.tokenHeader(),
        payload: {
          'streamId': streamId,
        },
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
}
