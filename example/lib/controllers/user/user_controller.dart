import 'package:appscrip_live_stream_component_example/data/data.dart';
import 'package:appscrip_live_stream_component_example/models/models.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  DBWrapper get dbWrapper => Get.find<DBWrapper>();

  UserDetailsModel? userDetail;
  AgentDetailsModel? agentDetail;

  Future<void> getUserData() async {
    var data = dbWrapper.getStringValue(LocalKeys.user);

    if (data.trim().isEmpty) {
      return;
    }
    userDetail = UserDetailsModel.fromJson(data);
  }

  Future<void> getAgentData() async {
    var data = dbWrapper.getStringValue(LocalKeys.user);

    if (data.trim().isEmpty) {
      return;
    }
    agentDetail = AgentDetailsModel.fromJson(data);
  }
}
