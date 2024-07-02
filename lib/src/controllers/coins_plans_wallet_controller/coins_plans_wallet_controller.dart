import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class CoinsPlansWalletController extends GetxController {
  CoinsPlansWalletController(this._coinsPlansWalletViewMode);
  final CoinsPlansWalletViewMode _coinsPlansWalletViewMode;

  @override
  void onInit() {
    super.onInit();
    getCoinsPlans();
  }

  /// show the loader ...
  bool isLoading = false;

  /// to get the api plans and store in this
  final apiPlans = <CoinPlansWalletRes>[];

  /// get the plans from the store and store in this..
  final storePlans = <ProductDetails>[];

  /// to fetch coins plans
  Future<void> getCoinsPlans() async {
    isLoading = true;
    update(['CoinsPlansWalletView']);
    final data = await _coinsPlansWalletViewMode.getCoinsPlans(
      showLoader: true,
    );
    apiPlans.addAll(data.data);
    const ids = <String>{};
    for (var apiPlan in apiPlans) {
      if (apiPlan.platformPlanId.isNotEmpty) {
        ids.add(apiPlan.platformPlanId);
      }
    }
    final getStorePlans = await InAppPurchase.instance.queryProductDetails(ids);
    storePlans.addAll(getStorePlans.productDetails);
    storePlans
        .removeWhere((e) => !apiPlans.map((b) => b.planId).contains(e.id));
    storePlans.sort(
      (a, b) => b.rawPrice.compareTo(a.rawPrice),
    );
    update(['CoinsPlansWalletView']);
  }

  /// to purchase the coin plans...
  // Future<void> postPurchasePlans() async {
  //   final data = PurchaseBody(
  //     planId: '12345',
  //     transactionId: 'abcde',
  //     deviceType: 'Android',
  //     packageName: 'com.example.app',
  //     productId: 'com.example.product',
  //     purchaseToken: 'token_12345',
  //   ).toJson();
  //   final res = await _coinsPlansWalletViewMode.purchaseCoinsPlans(data: data);
  // }
}
