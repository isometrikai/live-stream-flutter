import 'dart:async';
import 'dart:convert';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component_example/data/local/db_wrapper.dart';
import 'package:appscrip_live_stream_component_example/data/local/local_keys.dart';
import 'package:appscrip_live_stream_component_example/models/agent_details_model.dart';
import 'package:appscrip_live_stream_component_example/models/agent_model.dart';
import 'package:appscrip_live_stream_component_example/repositories/agent_auth_repository.dart';
import 'package:get/get.dart';

class AgentAuthViewModel {
  AgentAuthViewModel(this._repository);

  final AgetAuthRepository _repository;

  DBWrapper get dbWrapper => Get.find<DBWrapper>();

  Future<AgentDetailsModel?> agentLogin({
    required AgentModel payload,
  }) async {
    try {
      var res = await _repository.agentlogin(
        payload: payload,
      );

      if (res.hasError) {
        return null;
      }
      var val = jsonDecode(res.data);
      var data = AgentDetailsModel.fromMap(val['data']);

      unawaited(
        Future.wait([
          dbWrapper.saveValue(LocalKeys.user, data.toJson()),
          dbWrapper.saveValue(LocalKeys.isLoggedIn, true),
          dbWrapper.saveValue(LocalKeys.userType, 'agent'),
        ]),
      );

      return data;
    } catch (e, st) {
      IsmLiveLog.error('agent Login $e', st);
      return null;
    }
  }

  Future<int?> sendOtp({
    required AgentModel payload,
  }) async {
    try {
      var res = await _repository.agentSendOtp(
        payload: payload,
      );

      if (res.hasError) {
        return null;
      }

      var data = res.decode();

      return data['data']['expires_in'];
    } catch (e, st) {
      IsmLiveLog.error('Send Otp $e', st);
      return null;
    }
  }
}
