import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:http/http.dart' show Client;

class IsmLiveStreamRepository {
  IsmLiveStreamRepository(this.$client)
      : _apiWrapper = IsmLiveApiWrapper($client);

  final Client $client;
  final IsmLiveApiWrapper _apiWrapper;

  Future<IsmLiveResponseModel?> stopMeeting(
      {required String token,
      required String licenseKey,
      required String appSecret,
      required bool isLoading,
      required String meetingId}) async {
    try {
      var url = '/meetings/v1/publish/stop';
      var res = await _apiWrapper.makeRequest(url,
          showLoader: isLoading,
          type: IsmLiveRequestType.post,
          headers: IsmLiveUtility.commonHeader(
            token: token,
            licenseKey: licenseKey,
            appSecret: appSecret,
          ),
          payload: {
            'meetingId': meetingId,
          });

      return res;
    } catch (_) {
      return null;
    }
  }
}
