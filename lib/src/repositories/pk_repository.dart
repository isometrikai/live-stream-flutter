import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';

class IsmLivePkRepository {
  const IsmLivePkRepository(this._api);
  final IsmLivePkApis _api;

  Future<IsmLiveResponseModel> getUsersToInviteForPK({
    required int skip,
    required int limit,
    String? searchTag,
  }) async =>
      await _api.getUsersToInviteForPK(
        limit: limit,
        skip: skip,
        searchTag: searchTag,
      );
}
