import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';

class CoinsPlansWalletViewMode {
  CoinsPlansWalletViewMode(this._coinsPlansWalletRepository);
  final CoinsPlansWalletRepository _coinsPlansWalletRepository;

  /// to get the coins plans
  Future<CoinsPlansWalletModel> getCoinsPlans({
    required bool showLoader,
  }) async {
    try {
      final res = await _coinsPlansWalletRepository.getCoinsPlans(
          showLoader: showLoader);
      if (res.hasError) return CoinsPlansWalletModel();
      return coinsPlansWalletModelFromJson(res.data);
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return CoinsPlansWalletModel();
    }
  }

  ///  for request to purchase the coins plans ...
  Future<bool> purchaseCoinsPlans({
    required Map<String, dynamic> data,
  }) async {
    final res =
        await _coinsPlansWalletRepository.purchaseCoinsPlans(data: data);
    if (res.hasError) return !res.hasError;
    return res.hasError;
  }
}
