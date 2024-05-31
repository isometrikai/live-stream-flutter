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

  Future<IsmLiveResponseModel> sendGiftToStreamer() async =>
      await _api.sendGiftToStreamer(payload: {
        "messageStreamId": "661fc2b664c6660035a394b3",
        "senderId": "65eafd54837d0500019f065e",
        "giftThumbnailUrl":
            "https:\/\/admin-media1.isometrik.io\/virtual_currency_gift_icon\/TOr7LK_Zjr.png",
        "amount": 75,
        "giftId": "65f2834f3098f1fbf4022d46",
        "deviceId": "4B77871C-A748-41B7-81DF-55CFC8EA5FF0",
        "giftUrl":
            "https:\/\/admin-media1.isometrik.io\/virtual_currency_gift_animation\/ORZoL4_CYS.gif",
        "receiverUserId": "65eaff66837d050001712bfb",
        "reciverUserType": "publisher",
        "receiverName": "monikahi",
        "pkId": "",
        "receiverStreamId": "661fc2b664c6660035a394b3",
        "receiverCurrency": "INR",
        "isometricToken":
            "SFMyNTY.g3QAAAACZAAEZGF0YW0AAAAYNjVlYWZkNTQ4MzdkMDUwMDAxOWYwNjVlZAAGc2lnbmVkbgYARyB55o4B.ceGx2JoBHBppvYcmn6lGLxkUv0VOUoLEeMHENIgC8bo",
        "giftTitle": "Cat Dancing",
        "IsGiftVideo": false,
        "currency": "COIN",
        "isPk": false
      });
}
