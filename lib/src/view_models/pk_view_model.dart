import 'dart:convert';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:get/get.dart';

class IsmLivePkViewModel {
  const IsmLivePkViewModel(this._repository);
  final IsmLivePkRepository _repository;

  IsmLiveDBWrapper get dbWrapper => Get.find<IsmLiveDBWrapper>();

  Future<List<IsmLivePkInviteModel>> getUsersToInviteForPK({
    required int skip,
    required int limit,
    String? searchTag,
  }) async {
    try {
      var res = await _repository.getUsersToInviteForPK(
        limit: limit,
        skip: skip,
        searchTag: searchTag,
      );
      if (res.hasError) {
        return [];
      }
      List list = jsonDecode(res.data)['streams'];

      return list
          .map((e) => IsmLivePkInviteModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return [];
    }
  }

  Future<bool> sendInvitationToUserForPK({
    required String reciverStreamId,
    required String userId,
    required String senderStreamId,
  }) async {
    try {
      var res = await _repository.sendInvitationToUserForPK(
        reciverStreamId: reciverStreamId,
        senderStreamId: senderStreamId,
        userId: userId,
      );
      return !res.hasError;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return false;
    }
  }

  Future<IsmLivePkInviteResponceModel?> invitationPk({
    required String streamId,
    required String inviteId,
    required String response,
  }) async {
    try {
      var res = await _repository.invitationPK(
        inviteId: inviteId,
        response: response,
        streamId: streamId,
      );

      if (!res.hasError) {
        return IsmLivePkInviteResponceModel.fromJson(res.data);
      }
    } catch (e, st) {
      IsmLiveLog.error(e, st);
    }
    return null;
  }

  Future<String?> publishPk({
    required String streamId,
    required bool startPublish,
  }) async {
    try {
      var res = await _repository.publishPk(
        startPublish: startPublish,
        streamId: streamId,
      );

      if (res.hasError) {
        return null;
      }
      var rtcToken = jsonDecode(res.data)['rtcToken'];

      return rtcToken;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
    }
    return null;
  }

  Future<IsmLivePkStatusModel?> pkStatus({
    required String streamId,
  }) async {
    try {
      var res = await _repository.pkStatus(
        streamId: streamId,
      );

      if (res.hasError) {
        return null;
      }

      var data = jsonDecode(res.data)['data'];

      return IsmLivePkStatusModel.fromMap(data);
    } catch (e, st) {
      IsmLiveLog.error(e, st);
    }
    return null;
  }

  Future<void> startPkBattle({
    required String inviteId,
    required String battleTimeInMin,
  }) async {
    try {
      var res = await _repository.startPkBattle(
        battleTimeInMin: battleTimeInMin,
        inviteId: inviteId,
      );

      if (res.hasError) {
        return;
      }
    } catch (e, st) {
      IsmLiveLog.error(e, st);
    }
    return;
  }

  Future<bool> stopPkBattle({
    required String action,
    required String pkId,
  }) async {
    try {
      var res = await _repository.stopPkBattle(
        action: action,
        pkId: pkId,
      );

      if (res.hasError) {
        return false;
      }
      return true;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return false;
    }
  }

  Future<void> pkWinner({
    required String pkId,
  }) async {
    try {
      var res = await _repository.pkWinner(
        pkId: pkId,
      );

      if (res.hasError) {
        return;
      }
    } catch (e, st) {
      IsmLiveLog.error(e, st);
    }
    return;
  }

  Future<List<IsmLiveGiftGroupModel>> getGiftCategories({
    required int skip,
    required int limit,
    String? searchTag,
  }) async {
    try {
      var res = await _repository.getGiftCategories(
        limit: limit,
        skip: skip,
        searchTag: searchTag,
      );
      if (res.hasError) {
        return [];
      }

      List data = jsonDecode(res.data)['data'];

      return data
          .map((e) => IsmLiveGiftGroupModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return [];
    }
  }

  Future<List<IsmLiveGiftsCategoryModel>> getGiftsForACategory({
    required int skip,
    required int limit,
    required String giftGroupId,
    String? searchTag,
  }) async {
    try {
      var res = await _repository.getGiftsForACategory(
        limit: limit,
        skip: skip,
        searchTag: searchTag,
        giftGroupId: giftGroupId,
      );
      if (res.hasError) {
        return [];
      }
      List data = jsonDecode(res.data)['data'];

      return data
          .map((e) =>
              IsmLiveGiftsCategoryModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return [];
    }
  }

  Future<void> sendGiftToStreamer(IsmLiveSendGiftModel payload) async {
    try {
      var res = await _repository.sendGiftToStreamer(payload);
      if (res.hasError) {}
    } catch (e, st) {
      IsmLiveLog.error(e, st);
    }
  }
}
