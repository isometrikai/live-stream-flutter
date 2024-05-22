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

  Future<IsmLiveResponseModel> publishPk({
    required String streamId,
    required bool startPublish,
  }) async =>
      await _api.publishPk(
        startPublish: startPublish,
        streamId: streamId,
      );

  Future<IsmLiveResponseModel> startPkBattle({
    required String inviteId,
    required String battleTimeInMin,
  }) async =>
      await _api.startPkBattle(
        battleTimeInMin: battleTimeInMin,
        inviteId: inviteId,
      );

  Future<IsmLiveResponseModel> pkStatus({
    required String streamId,
  }) async =>
      await _api.pkStatus(
        streamId: streamId,
      );
}
