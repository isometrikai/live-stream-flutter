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
          showLoader: showLoader);
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

  Future<IsmLiveCoinBalanceModel?> totalWalletCoins() async {
    try {
      var res = await _coinsPlansWalletRepository.totalWalletCoins();

      var data = jsonDecode(res.data)['data'];

      if (!res.hasError) {
        return IsmLiveCoinBalanceModel.fromMap(data);
      }
    } catch (e, st) {
      IsmLiveLog.error(e, st);
    }
    return null;
  }

  Future<List<IsmLiveCoinTransactionModel>> fetchTransactions(
      String txnType) async {
    try {
      var res = await _coinsPlansWalletRepository.fetchTransactions(txnType);

      if (!res.hasError) {
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
