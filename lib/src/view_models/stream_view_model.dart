import 'dart:async';
import 'dart:convert';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/models/presigned_url.dart';
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

      return list
          .map((e) => IsmLiveStreamModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return [];
    }
  }

  Future<IsmLiveRTCModel?> getRTCToken(String streamId) async {
    try {
      var res = await _repository.getRTCToken(streamId);
      if (res.hasError) {
        return null;
      }

      return IsmLiveRTCModel.fromJson(res.data);
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return null;
    }
  }

  Future<IsmLiveRTCModel?> createStream(
      IsmLiveCreateStreamModel streamModel) async {
    try {
      var res = await _repository.createStream(streamModel);
      if (res.hasError) {
        return null;
      }
      return IsmLiveRTCModel.fromJson(res.data);
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return null;
    }
  }

  Future<bool> stopStream(String streamId) async {
    try {
      var res = await _repository.stopStream(streamId);
      return !res.hasError;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return false;
    }
  }

  Future<PresignedUrl?> getPresignedUrl({
    required bool showLoader,
    required String userIdentifier,
    required String mediaExtension,
  }) async {
    try {
      var res = await _repository.getPresignedUrl(
        showLoader: showLoader,
        userIdentifier: userIdentifier,
        mediaExtension: mediaExtension,
      );
      if (res.hasError) {
        return null;
      }
      var data = res.decode();
      return PresignedUrl.fromMap(data);
    } catch (e) {
      return null;
    }
  }
}
