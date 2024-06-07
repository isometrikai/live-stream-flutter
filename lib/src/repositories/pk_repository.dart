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

  Future<IsmLiveResponseModel> stopPkBattle({
    required String action,
    required String pkId,
  }) async =>
      await _api.stopPkBattle(
        action: action,
        pkId: pkId,
      );

  Future<IsmLiveResponseModel> pkWinner({
    required String pkId,
  }) async =>
      await _api.pkWinner(
        pkId: pkId,
      );

  Future<IsmLiveResponseModel> pkStatus({
    required String streamId,
  }) async =>
      await _api.pkStatus(
        streamId: streamId,
      );

  Future<IsmLiveResponseModel> getGiftCategories({
    required int skip,
    required int limit,
    String? searchTag,
  }) async =>
      await _api.getGiftCategories(
        limit: limit,
        skip: skip,
        searchTag: searchTag,
      );

  Future<IsmLiveResponseModel> getGiftsForACategory({
    required int skip,
    required int limit,
    required String giftGroupId,
    String? searchTag,
  }) async =>
      await _api.getGiftsForACategory(
        limit: limit,
        skip: skip,
        searchTag: searchTag,
        giftGroupId: giftGroupId,
      );

  Future<IsmLiveResponseModel> sendGiftToStreamer(
          IsmLiveSendGiftModel payload) async =>
      await _api.sendGiftToStreamer(
        payload: payload.toMap().removeNullValues(),
      );

  Future<IsmLiveResponseModel> pkEnd({
    required String inviteId,
  }) async =>
      await _api.pkEnd(
        inviteId: inviteId,
      );
}
