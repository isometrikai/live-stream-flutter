import 'dart:async';
import 'dart:convert';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CoinsPlansWalletController extends GetxController
    with GetTickerProviderStateMixin {
  CoinsPlansWalletController(this._coinsPlansWalletViewMode);
  final CoinsPlansWalletViewMode _coinsPlansWalletViewMode;

  @override
  void onInit() {
    super.onInit();
    coninTranscationTabController = TabController(
      vsync: this,
      length: IsmLiveCoinTransactionType.values.length,
    );

    IsmLiveUtility.updateLater(
      () {
        totalWalletCoins();
        getCoinsPlans();
      },
    );

    for (var type in IsmLiveCoinTransactionType.values) {
      _refreshControllers[type] = RefreshController();
      _transactions[type] = [];
    }
  }

  @override
  void onReady() {
    super.onReady();
    IsmLiveUtility.updateLater(() {
      coninTranscationTabController.addListener(() {
        coinTransactionType = IsmLiveCoinTransactionType
            .values[coninTranscationTabController.index];
      });

      unawaited(fetchTransactions());
    });
  }

  final _transactionDebouncer = IsmLiveDebouncer();
  final _transactions =
      <IsmLiveCoinTransactionType, List<IsmLiveCoinTransactionModel>>{};

  final _refreshControllers = <IsmLiveCoinTransactionType, RefreshController>{};

  RefreshController get refreshController =>
      _refreshControllers[coinTransactionType]!;

  List<IsmLiveCoinTransactionModel> get transactions =>
      _transactions[coinTransactionType]!;

  final Rx<IsmLiveCoinTransactionType> _coinTransactionType =
      IsmLiveCoinTransactionType.debit.obs;
  IsmLiveCoinTransactionType get coinTransactionType =>
      _coinTransactionType.value;
  set coinTransactionType(IsmLiveCoinTransactionType value) =>
      _coinTransactionType.value = value;

  /// to get the api plans and store in this
  final apiPlans = <CoinPlan>[];

  /// get the plans from the store and store in this..
  final storePlans = <ProductDetails>[];

  late TabController coninTranscationTabController;

  int coinBalance = 0;

  /// to fetch coins plans
  Future<void> getCoinsPlans() async {
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

    update([CoinsPlansWalletView.updateId]);
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

  Future<void> totalWalletCoins() async {
    var res = await _coinsPlansWalletViewMode.totalWalletCoins();
    if (res != null) {
      coinBalance = res.balance ?? 0;
    }
  }

  Future<void> fetchTransactions({
    IsmLiveCoinTransactionType? type,
    bool moreFetch = false,
    int limit = 15,
    int skip = 0,
    String? searchTag,
  }) async =>
      _transactionDebouncer.run(
        () => _fetchTransactions(
          type: type,
          moreFetch: moreFetch,
          limit: limit,
          skip: skip,
        ),
      );

  Future<void> _fetchTransactions({
    IsmLiveCoinTransactionType? type,
    required bool moreFetch,
    required int skip,
    required int limit,
  }) async {
    var txnType = type ?? coinTransactionType;
    var txnlist = await _coinsPlansWalletViewMode.fetchTransactions(
      txnType: txnType.label.toUpperCase(),
      limit: limit,
      skip: skip,
    );

    if (moreFetch) {
      _transactions[txnType]?.addAll(txnlist);
    } else {
      _transactions[txnType] = txnlist;
    }

    IsmLiveUtility.updateLater(() {
      update([IsmLiveCoinTransactions.updateId]);
    });
  }
}
