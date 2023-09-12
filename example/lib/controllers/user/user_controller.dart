import 'package:appscrip_live_stream_component_example/data/data.dart';
import 'package:appscrip_live_stream_component_example/models/models.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  var dbWrapper = Get.find<DBWrapper>();

  UserDetailsModel? userDetail;

  Future<void> getUserData() async {
    var data = dbWrapper.getStringValue(LocalKeys.user);

    if (data.trim().isEmpty) {
      return;
    }
    userDetail = UserDetailsModel.fromJson(data);
  }
}
