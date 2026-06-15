import 'dart:async';
import 'dart:io';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/store_kit_2_wrappers.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

class InAppManager {
  InAppManager._() {
    _initialize();
  }

  static final _service = InAppManager._();

  static InAppManager get i => _service;

  static StreamSubscription<List<PurchaseDetails>>? _purchaseStream;

  static ValueChanged<PurchaseDetails>? _onPurchase;

  /// True while the purchase-flow loader from [PurchaseStatus.pending] is shown.
  static bool _purchaseLoaderVisible = false;

  static void _dismissPurchaseLoaderIfShown() {
    if (!_purchaseLoaderVisible) return;
    _purchaseLoaderVisible = false;
    IsmLiveUtility.closeDialog();
  }

  /// Method for Initialize In App Purchase
  void _initialize() {
    try {
      unawaited(_purchaseStream?.cancel());
    } catch (_) {}
    _purchaseStream = null;
    _purchaseStream =
        InAppPurchase.instance.purchaseStream.listen((purchaseLists) {
      for (final purchase in purchaseLists) {
        switch (purchase.status) {
          case PurchaseStatus.pending:
            _purchaseLoaderVisible = true;
            IsmLiveUtility.showLoader();
            break;
          case PurchaseStatus.purchased:
            _dismissPurchaseLoaderIfShown();
            _onPurchase?.call(purchase);
            _onPurchase = null;
            break;
          case PurchaseStatus.error:
            _completePurchaseIfNeeded(purchase);
            _dismissPurchaseLoaderIfShown();
            IsmLiveUtility.showAlertDialog(
              message: purchase.error?.message ?? '',
            );
            _onPurchase = null;
            break;
          case PurchaseStatus.restored:
            // iOS re-delivers unfinished consumables as restored when the user
            // tries to buy again ("already been bought, will be restored").
            _dismissPurchaseLoaderIfShown();
            final handler = _onPurchase;
            _onPurchase = null;
            if (handler != null) {
              handler(purchase);
            } else {
              _completePurchaseIfNeeded(purchase);
            }
            break;
          case PurchaseStatus.canceled:
            _dismissPurchaseLoaderIfShown();
            _onPurchase = null;
            _completePurchaseIfNeeded(purchase);
            break;
        }
      }
    });
  }

  static bool shouldCompletePurchase(PurchaseDetails purchase) =>
      purchase.pendingCompletePurchase ||
      purchase.status == PurchaseStatus.restored;

  static void _completePurchaseIfNeeded(PurchaseDetails purchase) {
    if (!shouldCompletePurchase(purchase)) return;
    unawaited(InAppPurchase.instance.completePurchase(purchase));
  }

  /// Clears unfinished platform transactions before starting a new purchase.
  Future<void> prepareForPurchase() => _finishPastPurchases();

  /// Method for Finish Past Purchases
  Future<void> _finishPastPurchases() async {
    if (GetPlatform.isIOS) {
      await _finishUnfinishedStoreKit2Transactions();
      final transactions = <SKPaymentTransactionWrapper>[];
      try {
        await SKPaymentQueueWrapper().transactions().then((value) {
          transactions.clear();
          transactions.addAll(value);
        });
      } catch (_) {}
      for (final transaction in transactions) {
        if (transaction.transactionState ==
            SKPaymentTransactionStateWrapper.purchasing) {
          continue;
        }
        try {
          await SKPaymentQueueWrapper().finishTransaction(transaction);
        } catch (_) {}
      }
      return;
    } else if (GetPlatform.isAndroid) {
      final androidAddition = InAppPurchase.instance
          .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      final oldPurchases = <GooglePlayPurchaseDetails>[];
      try {
        await androidAddition.queryPastPurchases().then((value) {
          oldPurchases.clear();
          oldPurchases.addAll(value.pastPurchases);
        });
      } catch (_) {}
      for (final purchase in oldPurchases) {
        try {
          await androidAddition.consumePurchase(purchase);
        } catch (_) {}
      }
      return;
    }
  }

  /// StoreKit 2 keeps unfinished consumables in its own queue (not SK1).
  Future<void> _finishUnfinishedStoreKit2Transactions() async {
    try {
      final unfinished = await SK2Transaction.unfinishedTransactions();
      for (final transaction in unfinished) {
        try {
          await SK2Transaction.finish(int.parse(transaction.id));
        } catch (_) {}
      }
    } catch (_) {}
  }

  /// Method for Request to Purchase Consumable
  void buyConsumable({
    required PurchaseParam purchaseParam,
    required ValueChanged<PurchaseDetails> onPurchase,
  }) {
    unawaited(_buyConsumable(
      purchaseParam: purchaseParam,
      onPurchase: onPurchase,
    ));
  }

  Future<void> _buyConsumable({
    required PurchaseParam purchaseParam,
    required ValueChanged<PurchaseDetails> onPurchase,
  }) async {
    try {
      await prepareForPurchase();
      _onPurchase = onPurchase;
      await InAppPurchase.instance.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: Platform.isIOS,
      );
    } catch (_) {}
  }

  /// Method for Request to Purchase Non Consumable
  void buyNonConsumable({
    required PurchaseParam purchaseParam,
    required ValueChanged<PurchaseDetails> onPurchase,
  }) {
    try {
      _onPurchase = onPurchase;
      InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (_) {}
  }
}
