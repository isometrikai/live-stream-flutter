import 'dart:async';
import 'dart:io';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

class InAppManager {
  InAppManager._() {
    _initialize();
  }

  static final _service = InAppManager._();

  static InAppManager get i => _service;

  static StreamSubscription<List<PurchaseDetails>>? _purchaseStream;

  static ValueChanged<PurchaseDetails>? _onPurchase;

  /// Method for Initialize In App Purchase
  void _initialize() async {
    unawaited(_finishPastPurchases());
    try {
      await _purchaseStream?.cancel();
    } catch (_) {}
    _purchaseStream = null;
    _purchaseStream =
        InAppPurchase.instance.purchaseStream.listen((purchaseLists) {
      for (final purchase in purchaseLists) {
        switch (purchase.status) {
          case PurchaseStatus.pending:
            IsmLiveUtility.showLoader();
            break;
          case PurchaseStatus.purchased:
            IsmLiveUtility.closeDialog();
            _onPurchase?.call(purchase);
            _onPurchase = null;
            break;
          case PurchaseStatus.error:
            InAppPurchase.instance.completePurchase(purchase);
            IsmLiveUtility.closeDialog();
            IsmLiveUtility.showAlertDialog(
              message: purchase.error?.message ?? '',
            );
            break;
          case PurchaseStatus.restored:
            break;
          case PurchaseStatus.canceled:
            IsmLiveUtility.closeDialog();
            InAppPurchase.instance.completePurchase(purchase);
            break;
        }
      }
    });
  }

  /// Method for Finish Past Purchases
  Future<void> _finishPastPurchases() async {
    if (GetPlatform.isIOS) {
      final transactions = <SKPaymentTransactionWrapper>[];
      try {
        await SKPaymentQueueWrapper().transactions().then((value) {
          transactions.clear();
          transactions.addAll(value);
        });
      } catch (_) {}
      for (final transaction in transactions) {
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

  /// Method for Request to Purchase Consumable
  void buyConsumable({
    required PurchaseParam purchaseParam,
    required ValueChanged<PurchaseDetails> onPurchase,
  }) {
    try {
      _onPurchase = onPurchase;
      InAppPurchase.instance.buyConsumable(
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
