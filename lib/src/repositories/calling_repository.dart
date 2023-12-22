import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';

class IsmLiveCallingRepository {
  const IsmLiveCallingRepository(this._apiWrapper);
  final IsmLiveApiWrapper _apiWrapper;

  Future<IsmLiveResponseModel?> stopMeeting({
    required bool isLoading,
    required String meetingId,
  }) async {
    try {
      var url = '/meetings/v1/publish/stop';
      var res = await _apiWrapper.makeRequest(
        url,
        showLoader: isLoading,
        type: IsmLiveRequestType.post,
        headers: IsmLiveUtility.tokenHeader(),
        payload: {
          'meetingId': meetingId,
        },
      );

      return res;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return null;
    }
  }
}
