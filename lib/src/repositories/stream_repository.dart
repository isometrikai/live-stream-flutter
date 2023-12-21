import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';

class IsmLiveStreamRepository {
  const IsmLiveStreamRepository(this._apiWrapper);
  final IsmLiveApiWrapper _apiWrapper;

  Future<IsmLiveResponseModel> getUserDetails() async => _apiWrapper.makeRequest(
        IsmLiveApis.userDetails,
        type: IsmLiveRequestType.get,
        headers: IsmLiveUtility.tokenHeader(),
      );

  Future<IsmLiveResponseModel> subscribeUser({
    required bool isSubscribing,
  }) {
    var api = IsmLiveApis.userSubscription;
    if (!isSubscribing) {
      api = '$api?streamStartChannel=true';
    }
    return _apiWrapper.makeRequest(
      api,
      type: isSubscribing ? IsmLiveRequestType.put : IsmLiveRequestType.delete,
      payload: !isSubscribing
          ? null
          : {
              'streamStartChannel': true,
            },
      headers: IsmLiveUtility.tokenHeader(),
    );
  }

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
