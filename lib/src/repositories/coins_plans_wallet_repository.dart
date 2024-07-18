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
        showLoader: showLoader,
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

  Future<IsmLiveResponseModel> totalWalletCoins(String currency) {
    var payload = {
      'currency': currency.toUpperCase(),
    };
    return _apiWrapper.makeRequest(
      '${IsmLiveApis.fetchCoins}?${payload.makeQuery()}',
      baseUrl: IsmLiveApis.baseUrlStream,
      type: IsmLiveRequestType.get,
      headers: IsmLiveUtility.tokenHeader(),
      showLoader: false,
      showDialog: false,
    );
  }

  Future<IsmLiveResponseModel> fetchTransactions({
    required String txnType,
    required int skip,
    required int limit,
  }) {
    var payload = {
      'currency': 'COIN',
      'txnType': txnType,
      'txnSpecific': true,
      'skip': skip,
      'limit': limit,
    };
    return _apiWrapper.makeRequest(
      '${IsmLiveApis.fetchTransactions}?${payload.makeQuery()}',
      baseUrl: IsmLiveApis.baseUrlStream,
      type: IsmLiveRequestType.get,
      headers: IsmLiveUtility.tokenHeader(),
      showLoader: true,
      showDialog: false,
    );
  }
}
