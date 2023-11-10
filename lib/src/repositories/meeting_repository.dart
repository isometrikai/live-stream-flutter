import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:http/http.dart' show Client;

class MeetingRepository {
  MeetingRepository(this.$client) : _apiWrapper = IsmLiveApiWrapper($client);

  final Client $client;
  final IsmLiveApiWrapper _apiWrapper;

  Future<IsmLiveResponseModel?> getMeetingsList(
      {required String token,
      required String licenseKey,
      required bool isLoading,
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
      required bool isLoading,
      required int skip,
      required int limit,
      required String searchTag}) async {
    try {
      var url = '/streaming/v2/users?skip=$skip&limit=$limit';
      var res = await _apiWrapper.makeRequest(
        url,
        type: IsmLiveRequestType.get,
        showLoader: isLoading,
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

  Future<IsmLiveResponseModel?> deleteMeeting({
    required String licenseKey,
    required String appSecret,
    required String userToken,
    required String meetingId,
    required bool isLoading,
  }) async {
    try {
      var url = '/meetings/v1/leave?meetingId=$meetingId';
      var res = await _apiWrapper.makeRequest(
        url,
        type: IsmLiveRequestType.delete,
        showLoader: isLoading,
        headers: IsmLiveUtility.commonHeader(
          token: userToken,
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
      required bool isLoading,
      required String deviceId,
      required String meetingId}) async {
    try {
      var url = '/meetings/v1/publish/start';
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
            'deviceId': deviceId,
          });

      return res;
    } catch (_) {
      return null;
    }
  }

  Future<IsmLiveResponseModel?> createMeeting({
    required String token,
    required String licenseKey,
    required String appSecret,
    required bool isLoading,
    required bool audioOnly,
    required String deviceId,
    required String meetingDescription,
    required List<String> members,
  }) async {
    try {
      var url = '/meetings/v1/meeting';
      var res = await _apiWrapper.makeRequest(url,
          showLoader: isLoading,
          type: IsmLiveRequestType.post,
          headers: IsmLiveUtility.commonHeader(
            token: token,
            licenseKey: licenseKey,
            appSecret: appSecret,
          ),
          payload: {
            'selfHosted': true,
            'pushNotifications': true,
            'metaData': {'open meeting': true},
            'members': members,
            'meetingImageUrl':
                'https://d1q6f0aelx0por.cloudfront.net/product-logos/cb773227-1c2c-42a4-a527-12e6f827c1d2-elixir.png',
            'meetingDescription': meetingDescription,
            'hdMeeting': false,
            'enableRecording': false,
            'deviceId': deviceId,
            'customType': audioOnly ? 'AudioCall' : 'VideoCall',
            'meetingType': 0,
            'autoTerminate': true,
            'audioOnly': audioOnly
          });

      return res;
    } catch (_) {
      return null;
    }
  }
}
