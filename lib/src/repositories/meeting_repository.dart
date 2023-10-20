import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:http/http.dart' show Client;

class MeetingRepository {
  MeetingRepository(this.$client) : _apiWrapper = IsmLiveApiWrapper($client);

  final Client $client;
  final IsmLiveApiWrapper _apiWrapper;

  Future<IsmLiveResponseModel?> getMeetingsList(
      {required String token,
      required String licenseKey,
      required String appSecret}) async {
    try {
      var url = '/meetings/v1/meetings';
      var res = await _apiWrapper.makeRequest(
        url,
        type: IsmLiveRequestType.get,
        headers: IsmLiveUtility.commonHeader(
          token: token,
          licenseKey: licenseKey,
          appSecret: appSecret,
        ),
      );

      return res;
    } catch (_) {
      return null;
    }
  }

  Future<IsmLiveResponseModel?> getMembersList(
      {required String userSecret,
      required String licenseKey,
      required String appSecret,
      required int skip,
      required int limit,
      required String searchTag}) async {
    try {
      var url = '/streaming/v2/users?skip=$skip&limit=$limit';
      var res = await _apiWrapper.makeRequest(
        url,
        type: IsmLiveRequestType.get,
        headers: IsmLiveUtility.header(
          userSecret: userSecret,
          licenseKey: licenseKey,
          appSecret: appSecret,
        ),
      );

      return res;
    } catch (_) {
      return null;
    }
  }

  Future<IsmLiveResponseModel?> joinMeeting(
      {required String token,
      required String licenseKey,
      required String appSecret,
      required String meetingId}) async {
    try {
      var url = '/meetings/v1/join';
      var res = await _apiWrapper.makeRequest(url,
          type: IsmLiveRequestType.post,
          headers: IsmLiveUtility.commonHeader(
            token: token,
            licenseKey: licenseKey,
            appSecret: appSecret,
          ),
          payload: {'meetingId': meetingId});

      return res;
    } catch (_) {
      return null;
    }
  }
}
