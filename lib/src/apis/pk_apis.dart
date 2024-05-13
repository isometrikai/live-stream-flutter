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
    var payload = {
      'skip': skip,
      'limit': limit,
      'q': searchTag,
    };

    return await _apiWrapper.makeRequest(
      '${IsmLiveApis.getUsersToInviteForPK}?${payload.makeQuery()}',
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
}
