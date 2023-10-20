import 'package:appscrip_live_stream_component/src/view_models/view_models.dart';
import 'package:get/get.dart';

class IsmLiveStreamController extends GetxController {
  IsmLiveStreamController(this._viewModel);
  final IsmLiveStreamViewModel _viewModel;

  // static StreamController get instance {
  //   var id = '/${const Uuid().v4()}';
  //   var newInstance = Get.put(BlueprintController._(id), tag: id);
  //   return newInstance;
  // }
}
