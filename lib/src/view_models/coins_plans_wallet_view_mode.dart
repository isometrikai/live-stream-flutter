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
}
