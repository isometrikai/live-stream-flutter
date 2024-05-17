import 'dart:convert';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:get/get.dart';

class IsmLivePkViewModel {
  const IsmLivePkViewModel(this._repository);
  final IsmLivePkRepository _repository;

  IsmLiveDBWrapper get _dbWrapper => Get.find<IsmLiveDBWrapper>();

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

  Future<void> invitationPk({
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

      IsmLiveLog('------------------>invitpk  $res');
    } catch (e, st) {
      IsmLiveLog.error(e, st);
    }
  }
}
