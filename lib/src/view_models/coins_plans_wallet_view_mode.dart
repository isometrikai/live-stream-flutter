import 'dart:convert';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';

class CoinsPlansWalletViewMode {
  CoinsPlansWalletViewMode(this._coinsPlansWalletRepository);
  final CoinsPlansWalletRepository _coinsPlansWalletRepository;

  /// to get the coins plans
  Future<CoinPlansModel> getCoinsPlans({
    required bool showLoader,
  }) async {
    try {
      final res = await _coinsPlansWalletRepository.getCoinsPlans(
        showLoader: showLoader,
      );
      if (res.hasError) return const CoinPlansModel();
      return coinsPlansWalletModelFromJson(res.data);
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return const CoinPlansModel();
    }
  }

  ///  for request to purchase the coins plans ...
  Future<IsmLiveResponseModel?> purchaseCoinsPlans({
    required Map<String, dynamic> data,
  }) async {
    try {
      final res =
          await _coinsPlansWalletRepository.purchaseCoinsPlans(data: data);
      if (res.hasError) {
        await IsmLiveUtility.showInfoDialog(res);
      } else {
        return res;
      }
    } catch (_) {}
    return null;
  }

  /// iOS-only helper: get `appAccountToken` required by your backend.
  ///
  /// If the API fails, this shows an error popup and returns null.
  Future<String?> getAccountPurchaseToken({
    bool showLoader = true,
  }) async {
    try {
      final res = await _coinsPlansWalletRepository.getAccountPurchaseToken(
        showLoader: showLoader,
      );
      if (res.hasError) {
        await IsmLiveUtility.showInfoDialog(res);
        return null;
      }

      final decoded = jsonDecode(res.data) as Map<String, dynamic>;
      final data = decoded['data'];
      if (data is Map<String, dynamic>) {
        final token = data['appAccountToken']?.toString().trim();
        if (token != null && token.isNotEmpty) return token;
      }

      IsmLiveUtility.showAlertDialog(
        message: IsmLiveStrings.unableToFetchAccountToken,
      );
      return null;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      IsmLiveUtility.showAlertDialog(
        message: IsmLiveStrings.unableToFetchAccountToken,
      );
      return null;
    }
  }

  Future<IsmLiveVirtualToBaseCurrencyModel?> virtualToBase({
    required num amount,
  }) async {
    try {
      final res =
          await _coinsPlansWalletRepository.virtualToBase(amount: amount);
      if (res.hasError) return null;
      final data = jsonDecode(res.data)['data'];
      if (data is Map<String, dynamic>) {
        return IsmLiveVirtualToBaseCurrencyModel.fromMap(data);
      }
    } catch (e, st) {
      IsmLiveLog.error(e, st);
    }
    return null;
  }

  Future<IsmLiveCoinBalanceModel?> totalWalletCoins(String currency) async {
    try {
      var res = await _coinsPlansWalletRepository.totalWalletCoins(currency);

      var data = jsonDecode(res.data)['data'];

      if (!res.hasError) {
        return IsmLiveCoinBalanceModel.fromMap(data);
      }
    } catch (e, st) {
      IsmLiveLog.error(e, st);
    }
    return null;
  }

  Future<List<IsmLiveCoinTransactionModel>> fetchTransactions({
    String? txnType,
    required int skip,
    required int limit,
  }) async {
    try {
      var res = await _coinsPlansWalletRepository.fetchTransactions(
          limit: limit, skip: skip, txnType: txnType);

      if (!res.hasError && res.statusCode != 204) {
        List data = jsonDecode(res.data)['data'];
        return data
            .map((e) =>
                IsmLiveCoinTransactionModel.fromMap(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e, st) {
      IsmLiveLog.error(e, st);
    }
    return [];
  }
}
