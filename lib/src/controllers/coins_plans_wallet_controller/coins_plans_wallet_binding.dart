import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/controllers/coins_plans_wallet_controller/coins_plans_wallet_controller.dart';
import 'package:get/get.dart';

class CoinsPlansWalletBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => CoinsPlansWalletController(
        CoinsPlansWalletViewMode(
          CoinsPlansWalletRepository(
            Get.find(),
          ),
        ),
      ),
      fenix: true,
    );
  }
}
