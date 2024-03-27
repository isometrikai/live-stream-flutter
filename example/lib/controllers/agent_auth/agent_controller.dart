import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component_example/controllers/user/user_binding.dart';
import 'package:appscrip_live_stream_component_example/controllers/user/user_controller.dart';
import 'package:appscrip_live_stream_component_example/models/agent_model.dart';
import 'package:appscrip_live_stream_component_example/utils/app_config.dart';
import 'package:appscrip_live_stream_component_example/utils/navigators/routes_management.dart';
import 'package:appscrip_live_stream_component_example/view_models/agent_auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AgentAuthControlletr extends GetxController {
  AgentAuthControlletr(this._viewModel);
  final AgentAuthViewModel _viewModel;
  var phoneNoController = TextEditingController();
  var otpController = TextEditingController();

  AppConfig get _appConfig => Get.find();

  UserController get userController {
    if (!Get.isRegistered<UserController>()) {
      UserBinding().dependencies();
    }
    return Get.find<UserController>();
  }

  Future<void> agentLogin() async {
    var res = await _viewModel.agentLogin(
      payload: AgentModel(
        clientName: '65fac77b6a4e7c0001d4dc36',
        countryCode: '+91',
        phone: phoneNoController.text.trim(),
        createdUnderProjectId: '6407af55-c50d-47d2-9b2e-557f1f5ff404',
        phoneIsoCode: 'IN',
        otp: otpController.text.trim(),
      ),
    );
    if (res == null) {
      return;
    }
    IsmLiveLog('_______________  $res');
    unawaited(userController.getAgentData());
    RouteManagement.goToHome();
  }

  Future<void> sentOtp() async {
    var res = await _viewModel.sendOtp(
      payload: AgentModel(
        clientName: '65fac77b6a4e7c0001d4dc36',
        countryCode: '+91',
        phone: phoneNoController.text.trim(),
        createdUnderProjectId: '6407af55-c50d-47d2-9b2e-557f1f5ff404',
        phoneIsoCode: 'IN',
      ),
    );
    if (res == null) {
      return;
    }
    RouteManagement.goToAgentOtp();
  }
}
