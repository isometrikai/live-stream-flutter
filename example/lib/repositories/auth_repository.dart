import 'dart:typed_data';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component_example/data/data.dart';
import 'package:appscrip_live_stream_component_example/utils/utils.dart';
import 'package:get/get.dart';

class AuthRepository {
  AuthRepository(this._apiWrapper);
  final IsmLiveApiWrapper _apiWrapper;

  var dbWrapper = Get.find<DBWrapper>();

  Future<IsmLiveResponseModel> login({
    required String userName,
    required String email,
    required String password,
  }) =>
      _apiWrapper.makeRequest(
        Apis.authenticate,
        type: IsmLiveRequestType.post,
        payload: {'userIdentifier': email, 'password': password},
        headers: Utility.commonHeader(),
        showLoader: true,
        showDialog: true,
      );

  Future<IsmLiveResponseModel> signup({
    required bool isLoading,
    required Map<String, dynamic> createUser,
  }) =>
      _apiWrapper.makeRequest(
        Apis.user,
        type: IsmLiveRequestType.post,
        payload: createUser,
        headers: Utility.commonHeader(),
        showLoader: isLoading,
      );

  /// get Api for Presigned Url.....
  Future<IsmLiveResponseModel> getPresignedUrl({
    required bool showLoader,
    required String userIdentifier,
    required String mediaExtension,
  }) =>
      _apiWrapper.makeRequest(
        '${Apis.presignedurl}?userIdentifier=$userIdentifier&mediaExtension=$mediaExtension',
        type: IsmLiveRequestType.get,
        headers: Utility.commonHeader(),
        showLoader: showLoader,
      );

  /// get Api for Presigned Url
  Future<IsmLiveResponseModel> updatePresignedUrl({
    required bool showLoading,
    required String presignedUrl,
    required Uint8List file,
  }) =>
      _apiWrapper.makeRequest(
        presignedUrl,
        baseUrl: '',
        type: IsmLiveRequestType.put,
        payload: file,
        headers: {},
        showLoader: showLoading,
        shouldEncodePayload: false,
      );
}
