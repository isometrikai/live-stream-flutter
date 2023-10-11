import 'dart:typed_data';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component_example/data/data.dart';
import 'package:appscrip_live_stream_component_example/models/models.dart';
import 'package:appscrip_live_stream_component_example/repositories/repositories.dart';
import 'package:appscrip_live_stream_component_example/utils/utils.dart';
import 'package:get/get.dart';

class AuthViewModel {
  AuthViewModel(this._repository);

  final AuthRepository _repository;

  var dbWrapper = Get.find<DBWrapper>();

  Future<UserDetailsModel?> login({
    required String userName,
    required String email,
    required String password,
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
        userName: userName,
      );

      dbWrapper.saveValue(LocalKeys.user, userDetails.toJson());

      return userDetails;
    } catch (e, st) {
      AppLog.error('Login $e', st);
      return null;
    }
  }

  Future<UserDetailsModel?> signup({
    required bool isLoading,
    required Map<String, dynamic> createUser,
  }) async {
    try {
      var res = await _repository.signup(
          isLoading: isLoading, createUser: createUser);
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
        email: createUser['userIdentifier'],
      );

      dbWrapper.saveValue(LocalKeys.user, userDetails.toJson());

      return userDetails;
    } catch (e, st) {
      AppLog.error('Sign up $e', st);
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
      AppLog.error(e, st);
      return IsmLiveResponseModel.error();
    }
  }
}
