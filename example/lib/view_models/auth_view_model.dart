import 'dart:typed_data';

import 'package:appscrip_live_stream_component_example/models/models.dart';
import 'package:appscrip_live_stream_component_example/repositories/repositories.dart';
import 'package:appscrip_live_stream_component_example/utils/utils.dart';

class AuthViewModel {
  const AuthViewModel(this._repository);

  final AuthRepository _repository;

  Future<ModelWrapperExample> login({
    required String userName,
    required String email,
    required String password,
  }) async {
    try {
      return await _repository.login(
        userName: userName,
        email: email,
        password: password,
      );
    } catch (e, st) {
      AppLog.error('Login $e', st);
      return ModelWrapperExample.error();
    }
  }

  Future<ModelWrapperExample> signup({
    required bool isLoading,
    required Map<String, dynamic> createUser,
  }) async {
    try {
      return _repository.signup(isLoading: isLoading, createUser: createUser);
    } catch (e, st) {
      AppLog.error('Sign up $e', st);
      return ModelWrapperExample.error();
    }
  }

  /// get Api for Presigned Url.....
  Future<ModelWrapperExample<PresignedUrl>> getPresignedUrl({
    required bool showLoader,
    required String userIdentifier,
    required String mediaExtension,
  }) async {
    try {
      return _repository.getPresignedUrl(
        showLoader: showLoader,
        userIdentifier: userIdentifier,
        mediaExtension: mediaExtension,
      );
    } catch (e) {
      return ModelWrapperExample.error();
    }
  }

// / get Api for Presigned Url.....
  Future<ModelWrapperExample> updatePresignedUrl({
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
    } catch (e) {
      return ModelWrapperExample.error();
    }
  }
}
