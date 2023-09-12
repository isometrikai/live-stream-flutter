import 'dart:convert';
import 'dart:typed_data';

import 'package:appscrip_live_stream_component_example/data/data.dart';
import 'package:appscrip_live_stream_component_example/models/models.dart';
import 'package:appscrip_live_stream_component_example/utils/utils.dart';
import 'package:get/get.dart';

class AuthRepository {
  AuthRepository(this._apiWrapper);
  final ApiWrapper _apiWrapper;

  var dbWrapper = Get.find<DBWrapper>();

  Future<ModelWrapperExample<UserDetailsModel>> login({
    required String userName,
    required String email,
    required String password,
  }) async {
    try {
      var res = await _apiWrapper.makeRequest(
        Apis.authenticate,
        type: RequestType.post,
        payload: {'userIdentifier': email, 'password': password},
        headers: Utility.commonHeader(),
        showLoader: true,
        showDialog: true,
      );

      if (res.hasError) {
        if ([401, 404].contains(res.statusCode)) {
          await Utility.showInfoDialog(res);
        }
        return ModelWrapperExample.errorResponse(res);
      }

      var data = jsonDecode(res.data);
      var userDetails = UserDetailsModel(
        userId: data['userId'],
        userToken: data['userToken'],
        email: email,
        userName: userName,
      );

      dbWrapper.saveValue(LocalKeys.user, userDetails.toJson());

      return ModelWrapperExample(
        data: userDetails,
        statusCode: res.statusCode,
        hasError: res.hasError,
      );
    } catch (e, st) {
      AppLog.error('Sign up $e', st);
      return const ModelWrapperExample(
        data: null,
        statusCode: 1000,
        hasError: true,
      );
    }
  }

  Future<ModelWrapperExample<UserDetailsModel>> signup({
    required bool isLoading,
    required Map<String, dynamic> createUser,
  }) async {
    try {
      var res = await _apiWrapper.makeRequest(
        Apis.user,
        type: RequestType.post,
        payload: createUser,
        headers: Utility.commonHeader(),
        showLoader: isLoading,
      );
      if (res.hasError) {
        if ([401, 404].contains(res.statusCode)) {
          await Utility.showInfoDialog(res);
        }
        return ModelWrapperExample.errorResponse(res);
      }
      var data = jsonDecode(res.data);

      var userDetails = UserDetailsModel(
        userId: data['userId'],
        userToken: data['userToken'],
        email: createUser['userIdentifier'],
      );

      dbWrapper.saveValue(LocalKeys.user, userDetails.toJson());

      return ModelWrapperExample(
        data: userDetails,
        statusCode: res.statusCode,
        hasError: res.hasError,
      );
    } catch (e, st) {
      AppLog.error('Sign up $e', st);
      return const ModelWrapperExample(
        data: null,
        statusCode: 1000,
        hasError: true,
      );
    }
  }

  /// get Api for Presigned Url.....
  Future<ModelWrapperExample<PresignedUrl>> getPresignedUrl({
    required bool showLoader,
    required String userIdentifier,
    required String mediaExtension,
  }) async {
    try {
      var res = await _apiWrapper.makeRequest(
        '${Apis.presignedurl}?userIdentifier=$userIdentifier&mediaExtension=$mediaExtension',
        type: RequestType.get,
        headers: Utility.commonHeader(),
        showLoader: showLoader,
      );
      if (res.hasError) {
        return ModelWrapperExample.errorResponse(res);
      }
      var data = jsonDecode(res.data);
      return ModelWrapperExample(
        data: PresignedUrl.fromMap(data),
        statusCode: res.statusCode,
        hasError: res.hasError,
      );
    } catch (e) {
      return const ModelWrapperExample(
        data: null,
        statusCode: 1000,
        hasError: true,
      );
    }
  }

  /// get Api for Presigned Url
  Future<ModelWrapperExample<ResponseModel>> updatePresignedUrl({
    required bool showLoading,
    required String presignedUrl,
    required Uint8List file,
  }) async {
    try {
      var res = await _apiWrapper.makeRequest(
        presignedUrl,
        baseUrl: '',
        type: RequestType.put,
        payload: file,
        headers: {},
        showLoader: showLoading,
        shouldEncodePayload: false,
      );

      return ModelWrapperExample.errorResponse(res);
    } catch (e) {
      return const ModelWrapperExample(
        data: null,
        statusCode: 1000,
        hasError: true,
      );
    }
  }
}
