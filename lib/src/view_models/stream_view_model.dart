import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

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

  Future<bool> leaveStream(String streamId) async {
    try {
      var res = await _repository.leaveStream(streamId);

      return !res.hasError;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return false;
    }
  }

  Future<IsmLiveRTCModel?> createStream(IsmLiveCreateStreamModel streamModel) async {
    try {
      var res = await _repository.createStream(streamModel);
      if (res.hasError) {
        return null;
      }
      final model = IsmLiveRTCModel.fromJson(res.data);

      unawaited(_dbWrapper.saveValueSecurely(model.streamId!, model.rtcToken));

      return model;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return null;
    }
  }

  Future<bool> stopStream(String streamId) async {
    try {
      var res = await _repository.stopStream(streamId);

      unawaited(_dbWrapper.deleteSecuredValue(streamId));

      return !res.hasError;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return false;
    }
  }

  Future<IsmLivePresignedUrl?> getPresignedUrl({
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
      return IsmLivePresignedUrl.fromMap(data);
    } catch (e) {
      return null;
    }
  }

  Future<List<IsmLiveMemberDetailsModel>> getStreamMembers({
    required String streamId,
    required int limit,
    required int skip,
    String? searchTag,
  }) async {
    try {
      var res = await _repository.getStreamMembers(
        streamId: streamId,
        limit: limit,
        searchTag: searchTag,
        skip: skip,
      );
      if (res.hasError) {
        return [];
      }

      var list = jsonDecode(res.data)['members'] as List? ?? [];

      return list.map((e) => IsmLiveMemberDetailsModel.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return [];
    }
  }

  Future<List<IsmLiveViewerModel>> getStreamViewer({
    required String streamId,
    required int limit,
    required int skip,
    String? searchTag,
  }) async {
    try {
      var res = await _repository.getStreamViewer(
        streamId: streamId,
        limit: limit,
        searchTag: searchTag,
        skip: skip,
      );
      if (res.hasError) {
        return [];
      }

      var list = jsonDecode(res.data)['viewers'] as List? ?? [];

      return list.map((e) => IsmLiveViewerModel.fromMap(e as Map<String, dynamic>)).toList();
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return [];
    }
  }

  // / get Api for Presigned Url.....
  Future<IsmLiveResponseModel> updatePresignedUrl({
    required bool showLoading,
    required String presignedUrl,
    required Uint8List file,
  }) async {
    try {
      return _repository.updatePresignedUrl(
        showLoading: showLoading,
        presignedUrl: presignedUrl,
        file: file,
      );
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return IsmLiveResponseModel.error();
    }
  }

  // Future<IsmLiveResponseModel> getEndStream({
  //   required bool showLoading,
  //   required String streamId,
  // }) async {
  //   try {
  //     return _repository.getEndStream(
  //       showLoading: showLoading,
  //       streamId: streamId,
  //     );
  //   } catch (e, st) {
  //     IsmLiveLog.error(e, st);
  //     return IsmLiveResponseModel.error();
  //   }
  // }

  Future<bool> sendMessage({
    required bool showLoading,
    required IsmLiveSendMessageModel sendMessageModel,
  }) async {
    try {
      var res = await _repository.sendMessage(
        showLoading: showLoading,
        payload: sendMessageModel.toMap(),
      );

      return !res.hasError;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return false;
    }
  }

  Future<bool> kickoutViewer({
    required String streamId,
    required String viewerId,
  }) async {
    try {
      var res = await _repository.kickoutViewer(
        streamId: streamId,
        viewerId: viewerId,
      );

      return !res.hasError;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return false;
    }
  }
}
