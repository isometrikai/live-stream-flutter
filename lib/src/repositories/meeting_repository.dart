import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';

class MeetingRepository {
  MeetingRepository(this._apiWrapper);
  final IsmLiveApiWrapper _apiWrapper;

  Future<IsmLiveResponseModel?> getMeetingsList(
      {required String token,
      required String licenseKey,
      required String appSecret}) async {
    try {
      var url = '/meetings/v1/meetings';
      var res = await _apiWrapper
          .makeRequest(url, type: IsmLiveRequestType.get, headers: {
        'userToken': token,
        'licenseKey': licenseKey,
        'appSecret': appSecret,
      });

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
      var res = await _apiWrapper
          .makeRequest(url, type: IsmLiveRequestType.post, headers: {
        'userToken': token,
        'licenseKey': licenseKey,
        'appSecret': appSecret,
      }, payload: {
        'meetingId': meetingId
      });

      return res;
    } catch (_) {
      return null;
    }
  }
}
