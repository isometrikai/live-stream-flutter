import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/apis/pk_apis.dart';
import 'package:get/get.dart';

class IsmLivePkBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<IsmLivePkController>(
      () => IsmLivePkController(
        IsmLivePkViewModel(
          IsmLivePkRepository(
            IsmLivePkApis(
              Get.find(),
            ),
          ),
        ),
      ),
    );
  }
}
