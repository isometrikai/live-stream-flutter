import 'dart:async';
import 'dart:typed_data';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component_example/data/data.dart';
import 'package:appscrip_live_stream_component_example/models/models.dart';
import 'package:appscrip_live_stream_component_example/repositories/repositories.dart';
import 'package:get/get.dart';

class AuthViewModel {
  AuthViewModel(this._repository);

  final AuthRepository _repository;

  DBWrapper get dbWrapper => Get.find<DBWrapper>();

  Future<UserDetailsModel?> login({
    required String userName,
    required String email,
    required String password,
    required String deviceId,
  }) async {
    try {
      var res = await _repository.login(
        userName: userName,
        email: email,
        password: password,
      );
      if (res.hasError) {
        if ([401, 404].contains(res.statusCode)) {
          await IsmLiveUtility.showInfoDialog(res);
        }
        return null;
      }

      var data = res.decode();
      var userDetails = UserDetailsModel(
        userId: data['userId'],
        userToken: data['userToken'],
        email: email,
        deviceId: deviceId,
        userName: userName,
      );

      unawaited(
        Future.wait([
          dbWrapper.saveValue(LocalKeys.user, userDetails.toJson()),
          dbWrapper.saveValue(LocalKeys.isLoggedIn, true),
        ]),
      );

      return userDetails;
    } catch (e, st) {
      IsmLiveLog.error('Login $e', st);
      return null;
    }
  }

  Future<UserDetailsModel?> signup({
    required bool isLoading,
    required String deviceId,
    required Map<String, dynamic> createUser,
  }) async {
    try {
      var res = await _repository.signup(isLoading: isLoading, createUser: createUser);
      if (res.hasError) {
        if ([401, 404].contains(res.statusCode)) {
          await IsmLiveUtility.showInfoDialog(res);
        }
        return null;
      }
      var data = res.decode();

      var userDetails =
          UserDetailsModel(userId: data['userId'], userToken: data['userToken'], email: createUser['userIdentifier'], deviceId: deviceId);

      await dbWrapper.saveValue(LocalKeys.user, userDetails.toJson());

      return userDetails;
    } catch (e, st) {
      IsmLiveLog.error('Sign up $e', st);
      return null;
    }
  }

  /// get Api for Presigned Url.....
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
}
