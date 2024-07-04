import 'dart:convert';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:package_info_plus/package_info_plus.dart';

class CoinsPlansWalletController extends GetxController {
  CoinsPlansWalletController(this._coinsPlansWalletViewMode);
  final CoinsPlansWalletViewMode _coinsPlansWalletViewMode;

  @override
  void onInit() {
    super.onInit();
    getCoinsPlans();
  }

  /// show the loader ...
  var isPlansLoading = false;

  /// to get the api plans and store in this
  final apiPlans = <CoinPlan>[];

  /// get the plans from the store and store in this..
  final storePlans = <ProductDetails>[];

  /// to fetch coins plans
  Future<void> getCoinsPlans() async {
    isPlansLoading = true;
    update(['coin-plans-wallet-view']);
    final data = await _coinsPlansWalletViewMode.getCoinsPlans(
      showLoader: true,
    );
    apiPlans.clear();
    apiPlans.addAll(data.data);
    final _ids = <String>{};
    for (final apiPlan in apiPlans) {
      if (apiPlan.platformPlanId.isEmpty) continue;
      _ids.add(apiPlan.platformPlanId);
    }
    final getStorePlans =
        await InAppPurchase.instance.queryProductDetails(_ids);
    storePlans.clear();
    storePlans.addAll(getStorePlans.productDetails);
    storePlans.sort((a, b) => a.rawPrice.compareTo(b.rawPrice));
    apiPlans.removeWhere((apiPlan) =>
        !storePlans.map((e) => e.id).contains(apiPlan.platformPlanId));
    apiPlans.sort((a, b) => a.baseCurrencyValue.compareTo(b.baseCurrencyValue));
    isPlansLoading = false;
    update(['coin-plans-wallet-view']);
  }

  /// to purchase the coin plans...
  void purchasePlan({
    required ProductDetails storePlan,
    required CoinPlan apiPlan,
    required PurchaseDetails purchaseDetails,
  }) async {
    final deviceType = GetPlatform.isAndroid
        ? 'PLAY_STORE'
        : GetPlatform.isIOS
            ? 'APP_STORE'
            : '';
    final packageInfo = await PackageInfo.fromPlatform();
    var purchaseToken = '';
    if (GetPlatform.isAndroid) {
      final localeVerificationData =
          jsonDecode(purchaseDetails.verificationData.localVerificationData)
              as Map<String, dynamic>;
      purchaseToken = localeVerificationData['purchaseToken'] as String;
    } else if (GetPlatform.isIOS) {
      purchaseToken = purchaseDetails.verificationData.serverVerificationData;
    }
    final data = {
      'planId': apiPlan.id,
      'transactionId': purchaseDetails.purchaseID,
      'deviceType': deviceType,
      'packageName': packageInfo.packageName,
      'productId': purchaseDetails.productID,
      'purchaseToken': purchaseToken,
    };
    data.removeWhere((key, value) => value == null || value.isEmpty);
    final res = await _coinsPlansWalletViewMode.purchaseCoinsPlans(data: data);
    if (res == null) {
      await InAppPurchase.instance.completePurchase(purchaseDetails);
    }
  }

  void onTapBuyPlan({
    required ProductDetails storePlan,
    required CoinPlan apiPlan,
  }) async {
    final userId = Get.find<IsmLiveStreamController>().user?.userId ?? '';
    final purchaseParam = PurchaseParam(
      productDetails: storePlan,
      applicationUserName: userId,
    );
    InAppManager.i.buyConsumable(
      purchaseParam: purchaseParam,
      onPurchase: (purchaseDetails) => purchasePlan(
        purchaseDetails: purchaseDetails,
        apiPlan: apiPlan,
        storePlan: storePlan,
      ),
    );
  }
}
