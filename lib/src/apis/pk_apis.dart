import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';

class IsmLivePkApis {
  const IsmLivePkApis(this._apiWrapper);
  final IsmLiveApiWrapper _apiWrapper;

  static const String baseUrl = IsmLiveApis.baseUrlStream;

  Future<IsmLiveResponseModel> getUsersToInviteForPK({
    required int skip,
    required int limit,
    String? searchTag,
  }) async {
    var params = {
      'skip': skip,
      'limit': limit,
      'q': searchTag,
    };

    return await _apiWrapper.makeRequest(
      '${IsmLiveApis.getUsersToInviteForPK}?${params.makeQuery()}',
      baseUrl: baseUrl,
      type: IsmLiveRequestType.get,
      showDialog: false,
      headers: IsmLiveUtility.tokenHeader(),
    );
  }

  Future<IsmLiveResponseModel> sendInvitationToUserForPK({
    required String reciverStreamId,
    required String userId,
    required String senderStreamId,
  }) async {
    var payload = {
      'reciverStreamId': reciverStreamId,
      'senderStreamId': senderStreamId,
      'userId': userId
    };
    return await _apiWrapper.makeRequest(
      IsmLiveApis.getUsersToInviteForPK,
      baseUrl: baseUrl,
      type: IsmLiveRequestType.post,
      payload: payload,
      headers: IsmLiveUtility.tokenHeader(),
    );
  }

  Future<IsmLiveResponseModel> invitationPK({
    required String streamId,
    required String inviteId,
    required String response,
  }) async {
    var payload = {
      'streamId': streamId,
      'inviteId': inviteId,
      'response': response
    };
    return await _apiWrapper.makeRequest(
      IsmLiveApis.invitaionPK,
      baseUrl: baseUrl,
      type: IsmLiveRequestType.post,
      payload: payload,
      headers: IsmLiveUtility.tokenHeader(),
    );
  }

  Future<IsmLiveResponseModel> publishPk({
    required String streamId,
    required bool startPublish,
  }) async {
    var payload = {
      'streamId': streamId,
      'startPublish': startPublish,
    };
    return await _apiWrapper.makeRequest(
      IsmLiveApis.publish,
      type: IsmLiveRequestType.put,
      payload: payload,
      headers: IsmLiveUtility.tokenHeader(),
    );
  }

  Future<IsmLiveResponseModel> startPkBattle({
    required String inviteId,
    required String battleTimeInMin,
  }) async {
    var payload = {
      'inviteId': inviteId,
      'battleTimeInMin': int.parse(battleTimeInMin),
    };
    return await _apiWrapper.makeRequest(
      IsmLiveApis.pkStart,
      baseUrl: baseUrl,
      type: IsmLiveRequestType.post,
      payload: payload,
      headers: IsmLiveUtility.tokenHeader(),
      showDialog: false,
    );
  }

  Future<IsmLiveResponseModel> stopPkBattle({
    required String pkId,
    required String action,
  }) async {
    var payload = {
      'pkId': pkId,
      'action': action,
    };
    return await _apiWrapper.makeRequest(
      IsmLiveApis.pkStop,
      baseUrl: baseUrl,
      type: IsmLiveRequestType.post,
      payload: payload,
      headers: IsmLiveUtility.tokenHeader(),
      showDialog: false,
    );
  }

  Future<IsmLiveResponseModel> pkWinner({
    required String pkId,
  }) async {
    var params = {
      'pkId': pkId,
    };
    return await _apiWrapper.makeRequest(
      '${IsmLiveApis.pkWinner}?${params.makeQuery()}',
      baseUrl: baseUrl,
      type: IsmLiveRequestType.get,
      headers: IsmLiveUtility.tokenHeader(),
      showDialog: false,
    );
  }

  Future<IsmLiveResponseModel> pkStatus({
    required String streamId,
  }) async {
    var params = {
      'streamId': streamId,
    };
    return await _apiWrapper.makeRequest(
      '${IsmLiveApis.pkStatus}?${params.makeQuery()}',
      baseUrl: baseUrl,
      type: IsmLiveRequestType.get,
      headers: IsmLiveUtility.tokenHeader(),
      showDialog: false,
    );
  }

  Future<IsmLiveResponseModel> getGiftCategories({
    required int skip,
    required int limit,
    String? searchTag,
  }) async {
    var params = {
      'skip': skip,
      'limit': limit,
      'q': searchTag,
    };

    return await _apiWrapper.makeRequest(
      '${IsmLiveApis.getGiftCategories}?${params.makeQuery()}',
      baseUrl: baseUrl,
      type: IsmLiveRequestType.get,
      showDialog: false,
      showLoader: true,
      headers: IsmLiveUtility.tokenHeader(),
    );
  }

  Future<IsmLiveResponseModel> getGiftsForACategory({
    required int skip,
    required int limit,
    required String giftGroupId,
    String? searchTag,
  }) async {
    var params = {
      'giftGroupId': giftGroupId,
      'skip': skip,
      'limit': limit,
      'q': searchTag,
    };

    return await _apiWrapper.makeRequest(
      '${IsmLiveApis.getGiftsForACategory}?${params.makeQuery()}',
      baseUrl: baseUrl,
      type: IsmLiveRequestType.get,
      showDialog: false,
      headers: IsmLiveUtility.tokenHeader(),
    );
  }

  Future<IsmLiveResponseModel> sendGiftToStreamer({
    required Map<String, dynamic> payload,
  }) async =>
      await _apiWrapper.makeRequest(
        IsmLiveApis.sendGiftToStreamer,
        baseUrl: baseUrl,
        type: IsmLiveRequestType.post,
        showDialog: true,
        payload: payload,
        headers: IsmLiveUtility.tokenHeader(),
      );

  Future<IsmLiveResponseModel> pkEnd({
    required String inviteId,
  }) async {
    var payload = {
      'InviteId': inviteId,
      'action': 'END',
      'intentToStop': false,
    };
    return await _apiWrapper.makeRequest(
      IsmLiveApis.pkEnd,
      baseUrl: baseUrl,
      type: IsmLiveRequestType.post,
      payload: payload,
      headers: IsmLiveUtility.tokenHeader(),
      showDialog: false,
    );
  }
}
