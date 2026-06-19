import 'dart:async';
import 'dart:io';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_2_wrappers.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

typedef PurchaseHandler = Future<void> Function(PurchaseDetails purchase);

class InAppManager {
  InAppManager._() {
    _initialize();
  }

  static final _service = InAppManager._();

  static InAppManager get i => _service;

  static StreamSubscription<List<PurchaseDetails>>? _purchaseStream;

  static PurchaseHandler? _onPurchase;

  /// Called after stale device-queue transactions are cleared (refresh wallet).
  static VoidCallback? onStaleTransactionsCleared;

  /// True while the purchase-flow loader from [PurchaseStatus.pending] is shown.
  static bool _purchaseLoaderVisible = false;

  static void _dismissPurchaseLoaderIfShown() {
    if (!_purchaseLoaderVisible) return;
    _purchaseLoaderVisible = false;
    IsmLiveUtility.closeDialog();
  }

  static void _clearActivePurchaseHandler() {
    _onPurchase = null;
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
        unawaited(_handlePurchaseUpdate(purchase));
      }
    });
  }

  static Future<void> _handlePurchaseUpdate(PurchaseDetails purchase) async {
    switch (purchase.status) {
      case PurchaseStatus.pending:
        _purchaseLoaderVisible = true;
        IsmLiveUtility.showLoader();
        break;
      case PurchaseStatus.purchased:
        _dismissPurchaseLoaderIfShown();
        await _deliverAndComplete(purchase);
        _clearActivePurchaseHandler();
        break;
      case PurchaseStatus.error:
        await _completePurchaseAwait(purchase);
        _dismissPurchaseLoaderIfShown();
        IsmLiveUtility.showAlertDialog(
          message: purchase.error?.message ?? '',
        );
        _clearActivePurchaseHandler();
        break;
      case PurchaseStatus.restored:
        // iOS re-delivers unfinished consumables as restored when the user
        // tries to buy again ("already been bought, will be restored").
        _dismissPurchaseLoaderIfShown();
        await _deliverAndComplete(purchase);
        _clearActivePurchaseHandler();
        break;
      case PurchaseStatus.canceled:
        _dismissPurchaseLoaderIfShown();
        await _completePurchaseAwait(purchase);
        _clearActivePurchaseHandler();
        break;
    }
  }

  static Future<void> _deliverAndComplete(PurchaseDetails purchase) async {
    final handler = _onPurchase;
    _onPurchase = null;
    if (handler != null) {
      try {
        await handler(purchase);
      } catch (e, st) {
        IsmLiveLog.error(e, st);
        await _completePurchaseAwait(purchase);
      }
      return;
    }
    await _completePurchaseAwait(purchase);
  }

  static bool shouldCompletePurchase(PurchaseDetails purchase) =>
      purchase.pendingCompletePurchase ||
      purchase.status == PurchaseStatus.restored;

  static Future<void> _completePurchaseAwait(PurchaseDetails purchase) async {
    if (!shouldCompletePurchase(purchase)) return;
    try {
      await InAppPurchase.instance.completePurchase(purchase);
    } catch (e, st) {
      IsmLiveLog.error(e, st);
    }
  }

  /// Clears unfinished platform transactions before starting a new purchase.
  Future<void> prepareForPurchase({String? productId}) =>
      _finishPastPurchases(productId: productId);

  /// Method for Finish Past Purchases
  Future<void> _finishPastPurchases({String? productId}) async {
    if (GetPlatform.isIOS) {
      var clearedAny = false;
      clearedAny = await _syncAndClearIosQueue(productId: productId) || clearedAny;
      if (productId != null && await _iosQueueHasProduct(productId)) {
        await Future<void>.delayed(const Duration(milliseconds: 150));
        clearedAny =
            await _syncAndClearIosQueue(productId: productId) || clearedAny;
        if (await _iosQueueHasProduct(productId)) {
          clearedAny =
              await _syncAndClearIosQueue(productId: null) || clearedAny;
        }
      }
      if (clearedAny) {
        onStaleTransactionsCleared?.call();
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

  Future<bool> _syncAndClearIosQueue({String? productId}) async {
    await _syncStoreKitIfAvailable();
    var clearedAny = false;
    clearedAny =
        await _finishUnfinishedStoreKit2Transactions(productId: productId) ||
            clearedAny;
    clearedAny =
        await _finishStoreKit1Transactions(productId: productId) || clearedAny;
    return clearedAny;
  }

  Future<void> _syncStoreKitIfAvailable() async {
    try {
      final addition = InAppPurchase.instance
          .getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await addition.sync();
    } catch (_) {}
  }

  Future<bool> _iosQueueHasProduct(String productId) async {
    try {
      final unfinished = await SK2Transaction.unfinishedTransactions();
      if (unfinished.any((txn) => txn.productId == productId)) {
        return true;
      }
    } catch (_) {}
    try {
      final transactions = await SKPaymentQueueWrapper().transactions();
      return transactions.any(
        (txn) =>
            txn.payment.productIdentifier == productId &&
            txn.transactionState !=
                SKPaymentTransactionStateWrapper.purchasing,
      );
    } catch (_) {}
    return false;
  }

  Future<bool> _finishStoreKit1Transactions({String? productId}) async {
    var clearedAny = false;
    final transactions = <SKPaymentTransactionWrapper>[];
    try {
      transactions.addAll(await SKPaymentQueueWrapper().transactions());
    } catch (_) {}
    for (final transaction in transactions) {
      if (transaction.transactionState ==
          SKPaymentTransactionStateWrapper.purchasing) {
        continue;
      }
      if (productId != null &&
          transaction.payment.productIdentifier != productId) {
        continue;
      }
      try {
        await SKPaymentQueueWrapper().finishTransaction(transaction);
        clearedAny = true;
      } catch (_) {}
    }
    return clearedAny;
  }

  /// StoreKit 2 keeps unfinished consumables in its own queue (not SK1).
  Future<bool> _finishUnfinishedStoreKit2Transactions({
    String? productId,
  }) async {
    var clearedAny = false;
    try {
      final unfinished = await SK2Transaction.unfinishedTransactions();
      final matching = productId == null
          ? unfinished
          : unfinished.where((txn) => txn.productId == productId);
      for (final transaction in [
        ...matching,
        if (productId != null)
          ...unfinished.where((txn) => txn.productId != productId),
      ]) {
        try {
          await SK2Transaction.finish(int.parse(transaction.id));
          clearedAny = true;
        } catch (_) {}
      }
    } catch (_) {}
    return clearedAny;
  }

  /// Method for Request to Purchase Consumable
  Future<void> buyConsumable({
    required PurchaseParam purchaseParam,
    required PurchaseHandler onPurchase,
  }) async {
    try {
      await prepareForPurchase(productId: purchaseParam.productDetails.id);
      _onPurchase = onPurchase;
      await InAppPurchase.instance.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: Platform.isIOS,
      );
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      _clearActivePurchaseHandler();
    }
  }

  /// Method for Request to Purchase Non Consumable
  void buyNonConsumable({
    required PurchaseParam purchaseParam,
    required ValueChanged<PurchaseDetails> onPurchase,
  }) {
    try {
      _onPurchase = (purchase) async => onPurchase(purchase);
      InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (_) {}
  }
}
