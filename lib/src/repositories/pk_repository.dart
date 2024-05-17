import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';

class IsmLivePkRepository {
  const IsmLivePkRepository(this._api);
  final IsmLivePkApis _api;

  Future<IsmLiveResponseModel> getUsersToInviteForPK({
    required int skip,
    required int limit,
    String? searchTag,
  }) async =>
      await _api.getUsersToInviteForPK(
        limit: limit,
        skip: skip,
        searchTag: searchTag,
      );

  Future<IsmLiveResponseModel> sendInvitationToUserForPK({
    required String reciverStreamId,
    required String userId,
    required String senderStreamId,
  }) async =>
      await _api.sendInvitationToUserForPK(
        reciverStreamId: reciverStreamId,
        senderStreamId: senderStreamId,
        userId: userId,
      );

  Future<IsmLiveResponseModel> invitationPK({
    required String streamId,
    required String inviteId,
    required String response,
  }) async =>
      await _api.invitationPK(
        inviteId: inviteId,
        response: response,
        streamId: streamId,
      );
}
