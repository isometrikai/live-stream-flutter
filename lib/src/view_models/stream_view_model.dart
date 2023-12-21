import 'dart:async';
import 'dart:convert';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:get/get.dart';

class IsmLiveStreamViewModel {
  const IsmLiveStreamViewModel(this._repository);
  final IsmLiveStreamRepository _repository;

  IsmLiveDBWrapper get _dbWrapper => Get.find<IsmLiveDBWrapper>();

  Future<void> getUserDetails() async {
    var res = await _repository.getUserDetails();

    var user = UserDetails.fromJson(res.data);
    unawaited(_dbWrapper.saveValue(IsmLiveLocalKeys.user, user.toJson()));
    return;
  }

  Future<bool> subscribeUser({
    required bool isSubscribing,
  }) async {
    try {
      var res = await _repository.subscribeUser(
        isSubscribing: isSubscribing,
      );
      return !res.hasError;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return false;
    }
  }

  Future<List<IsmLiveStreamModel>> getStreams({
    required IsmLiveStreamQueryModel queryModel,
  }) async {
    try {
      var res = await _repository.getStreams(queryModel: queryModel);

      if (res.hasError) {
        return [];
      }

      var list = jsonDecode(res.data)['streams'] as List? ?? [];

      return list.map((e) => IsmLiveStreamModel.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return [];
    }
  }

  Future<bool> stopMeeting({
    required bool isLoading,
    required String meetingId,
  }) async {
    try {
      var res = await _repository.stopMeeting(
        isLoading: isLoading,
        meetingId: meetingId,
      );

      if (res?.hasError ?? true) {
        return false;
      }
      return true;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return false;
    }
  }
}
