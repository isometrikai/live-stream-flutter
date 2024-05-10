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

      return list
          .map((e) => IsmLiveStreamModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return [];
    }
  }

  Future<IsmLiveRTCModel?> getRTCToken(String streamId, bool showLoader) async {
    try {
      var res = await _repository.getRTCToken(streamId, showLoader);
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

  Future<IsmLiveRTCModel?> createStream(
    IsmLiveCreateStreamModel streamModel,
    UserDetails? user,
  ) async {
    try {
      var res = await _repository.createStream(
        streamModel,
        user,
      );
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

      return list
          .map((e) =>
              IsmLiveMemberDetailsModel.fromMap(e as Map<String, dynamic>))
          .toList();
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

      return list
          .map((e) => IsmLiveViewerModel.fromMap(e as Map<String, dynamic>))
          .toList();
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
    required IsmLiveSendMessageModel getMessageModel,
  }) async {
    try {
      var res = await _repository.sendMessage(
        showLoading: showLoading,
        payload: getMessageModel.toMap(),
      );

      return !res.hasError;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return false;
    }
  }

  Future<bool> replyMessage({
    required bool showLoading,
    required IsmLiveSendMessageModel getMessageModel,
  }) async {
    try {
      var res = await _repository.replyMessage(
        showLoading: showLoading,
        payload: getMessageModel.toMap(),
      );

      return !res.hasError;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return false;
    }
  }

  Future<List<IsmLiveMessageModel>> fetchMessages({
    required bool showLoading,
    required IsmLiveGetMessageModel getMessageModel,
  }) async {
    try {
      var res = await _repository.fetchMessages(
        showLoading: showLoading,
        payload: getMessageModel.toMap(),
      );
      if (res.hasError) {
        return [];
      }

      var list = jsonDecode(res.data)['messages'] as List? ?? [];

      return list
          .map((e) => IsmLiveMessageModel.fromMap(e as Map<String, dynamic>))
          .where((e) => e.messageType == IsmLiveMessageType.normal)
          .toList();
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return [];
    }
  }

  Future<int> fetchMessagesCount({
    required bool showLoading,
    required IsmLiveGetMessageModel getMessageModel,
  }) async {
    try {
      var res = await _repository.fetchMessagesCount(
        showLoading: showLoading,
        payload: getMessageModel.toMap(),
      );
      if (res.hasError) {
        return 0;
      }

      var count = jsonDecode(res.data)['messagesCount'];

      return count;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return 0;
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

  Future<bool> deleteMessage({
    required String streamId,
    required String messageId,
  }) async {
    try {
      var res = await _repository.deleteMessage(
        streamId: streamId,
        messageId: messageId,
      );

      return !res.hasError;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return false;
    }
  }

  Future<List<UserDetails>?> fetchUsers({
    required int skip,
    required int limit,
    String? searchTag,
  }) async {
    try {
      var res = await _repository.fetchUsers(
        isLoading: false,
        skip: skip,
        limit: limit,
        searchTag: searchTag,
      );
      if (res.hasError) {
        return null;
      }
      var data = jsonDecode(res.data);
      List listOfUsers = data['users'];
      var userDetailsList = <UserDetails>[];

      for (var i in listOfUsers) {
        userDetailsList.add(UserDetails.fromMap(i));
      }
      return userDetailsList;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return null;
    }
  }

  Future<List<UserDetails>> fetchModerators({
    required int skip,
    required String streamId,
    required int limit,
    String? searchTag,
  }) async {
    try {
      var res = await _repository.fetchModerators(
        isLoading: false,
        streamId: streamId,
        skip: skip,
        limit: limit,
        searchTag: searchTag,
      );

      if (res.hasError) {
        return [];
      }

      List listOfModerators = jsonDecode(res.data)['moderators'];

      return listOfModerators
          .map((e) => UserDetails.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return [];
    }
  }

  Future<bool> makeModerator({
    required String streamId,
    required String moderatorId,
  }) async {
    try {
      var res = await _repository.makeModerator(
        streamId: streamId,
        moderatorId: moderatorId,
      );

      return !res.hasError;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return false;
    }
  }

  Future<bool> removeModerator({
    required String streamId,
    required String moderatorId,
  }) async {
    try {
      var res = await _repository.removeModerator(
        streamId: streamId,
        moderatorId: moderatorId,
      );

      return !res.hasError;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return false;
    }
  }

  Future<bool> leaveModerator(String streamId) async {
    try {
      var res = await _repository.leaveModerator(streamId);
      return !res.hasError;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return false;
    }
  }

  Future<bool> requestCopublisher(String streamId) async {
    try {
      var res = await _repository.requestCopublisher(streamId);

      return !res.hasError;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return false;
    }
  }

  Future<List<UserDetails>> fetchCopublisherRequests({
    required int skip,
    required String streamId,
    required int limit,
    String? searchTag,
  }) async {
    try {
      var res = await _repository.fetchCopublisherRequests(
        streamId: streamId,
        skip: skip,
        limit: limit,
        searchTag: searchTag,
      );

      if (res.hasError) {
        return [];
      }

      List listOfcopublishRequests = jsonDecode(res.data)['copublishRequests'];

      return listOfcopublishRequests
          .map((e) => UserDetails.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return [];
    }
  }

  Future<List<UserDetails>> fetchEligibleMembers({
    required int skip,
    required String streamId,
    required int limit,
    String? searchTag,
  }) async {
    try {
      var res = await _repository.fetchEligibleMembers(
        streamId: streamId,
        skip: skip,
        limit: limit,
        searchTag: searchTag,
      );

      if (res.hasError) {
        return [];
      }

      List listOfcopublishRequests =
          jsonDecode(res.data)['streamEligibleMembers'];

      return listOfcopublishRequests
          .map((e) => UserDetails.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return [];
    }
  }

  Future<bool> acceptCopublisherRequest({
    required String streamId,
    required String requestById,
  }) async {
    try {
      var res = await _repository.acceptCopublisherRequest(
        streamId: streamId,
        requestById: requestById,
      );

      return !res.hasError;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return false;
    }
  }

  Future<bool> denyCopublisherRequest({
    required String streamId,
    required String requestById,
  }) async {
    try {
      var res = await _repository.denyCopublisherRequest(
        streamId: streamId,
        requestById: requestById,
      );

      return !res.hasError;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return false;
    }
  }

  Future<bool> addMember({
    required String streamId,
    required String memberId,
  }) async {
    try {
      var res = await _repository.addMember(
        streamId: streamId,
        memberId: memberId,
      );

      return !res.hasError;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return false;
    }
  }

  Future<bool> removeMember({
    required String streamId,
    required String memberId,
  }) async {
    try {
      var res = await _repository.removeMember(
        streamId: streamId,
        memberId: memberId,
      );

      return !res.hasError;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return false;
    }
  }

  Future<bool> leaveMember({
    required String streamId,
  }) async {
    try {
      var res = await _repository.leaveMember(
        streamId: streamId,
      );

      return !res.hasError;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return false;
    }
  }

  Future<({bool pending, bool accepted})?> statusCopublisherRequest({
    required String streamId,
  }) async {
    try {
      var res = await _repository.statusCopublisherRequest(
        streamId: streamId,
      );

      var data = jsonDecode(res.data);

      return (
        pending: data['pending'] as bool? ?? false,
        accepted: data['accepted'] as bool? ?? false
      );
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return null;
    }
  }

  Future<String?> switchViewer({
    required String streamId,
  }) async {
    try {
      var res = await _repository.switchViewer(
        streamId: streamId,
      );
      if (res.hasError) {
        return null;
      }
      var rtcToken = jsonDecode(res.data)['rtcToken'];

      return rtcToken;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return null;
    }
  }

  Future<dynamic> getRestreamChannels() async {
    try {
      var res = await _repository.getRestreamChannels();
      if (res.hasError) {
        return null;
      }

      return res;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return null;
    }
  }

  Future<bool> addRestreamChannel({
    required String url,
    required bool enable,
  }) async {
    try {
      var res = await _repository.addRestreamChannel(
        url: url,
        enable: enable,
      );

      return !res.hasError;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return false;
    }
  }

  Future<IsmLiveProductDetailModel?> fetchProductDetails() async {
    try {
      var res = await _repository.fetchProductDetails();
      if (res.hasError) {
        return null;
      }
      return IsmLiveProductDetailModel.fromJson(res.data);
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return null;
    }
  }

  Future<List<IsmLiveProductModel>> fetchProducts({
    required int skip,
    required int limit,
    String? searchTag,
  }) async {
    try {
      var res = await _repository.fetchProducts(
        limit: limit,
        skip: skip,
        searchTag: searchTag,
      );
      if (res.hasError) {
        return [];
      }

      List list = jsonDecode(res.data)['products'];

      return list
          .map((e) => IsmLiveProductModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return [];
    }
  }

  Future<IsmLiveStreamAnalyticsModel?> streamAnalytics({
    required String streamId,
  }) async {
    try {
      var res = await _repository.streamAnalytics(
        streamId: streamId,
      );

      if (!res.hasError) {
        return IsmLiveStreamAnalyticsModel.fromJson(res.data);
      }
    } catch (e, st) {
      IsmLiveLog.error(e, st);
    }
    return null;
  }

  Future<void> streamAnalyticsViewers({
    required String streamId,
  }) async {
    try {
      var res = await _repository.streamAnalyticsViewers(
        streamId: streamId,
      );

      if (!res.hasError) {
        IsmLiveLog('-------------- ${res.data}');
      }
    } catch (e, st) {
      IsmLiveLog.error(e, st);
    }
    return;
  }

  Future<void> getUsersToInviteForPK({
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
      if (res.hasError) {}

      IsmLiveLog('_____________________---- pk $res');
    } catch (e, st) {
      IsmLiveLog.error(e, st);
    }
  }
}
