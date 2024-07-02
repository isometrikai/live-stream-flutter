import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';

class CoinsPlansWalletRepository {
  CoinsPlansWalletRepository(this._apiWrapper);

  final IsmLiveApiWrapper _apiWrapper;

  /// to fetch the coins plans...
  Future<IsmLiveResponseModel> getCoinsPlans({
    required bool showLoader,
  }) async =>
      await _apiWrapper.makeRequest(
        IsmLiveApis.getCurrencyPlans,
        baseUrl: IsmLiveApis.baseUrlStream,
        type: IsmLiveRequestType.get,
        headers: IsmLiveUtility.tokenHeader(),
      );

  ///  for request to purchase the coins plans ...
  Future<IsmLiveResponseModel> purchaseCoinsPlans({
    required Map<String, dynamic> data,
  }) async =>
      await _apiWrapper.makeRequest(
        IsmLiveApis.purchaseCoinsPlans,
        baseUrl: IsmLiveApis.baseUrlStream,
        type: IsmLiveRequestType.post,
        headers: IsmLiveUtility.tokenHeader(),
        payload: data,
      );
}
