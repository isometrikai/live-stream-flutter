import 'package:appscrip_live_stream_component_example/data/data.dart';
import 'package:appscrip_live_stream_component_example/models/models.dart';
import 'package:appscrip_live_stream_component_example/view_models/view_models.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  HomeController(this._viewModel);

  final HomeViewModel _viewModel;

  var dbWrapper = Get.find<DBWrapper>();

  late UserDetailsModel user;

  @override
  void onInit() {
    super.onInit();

    user = UserDetailsModel.fromJson(dbWrapper.getStringValue(LocalKeys.user));
  }
}
