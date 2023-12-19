import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';

class IsmLiveStreamViewModel {
  const IsmLiveStreamViewModel(this._repository);
  final IsmLiveStreamRepository _repository;

  Future<bool> stopMeeting({
    required String token,
    required String licenseKey,
    required String appSecret,
    required bool isLoading,
    required String meetingId,
  }) async {
    try {
      var res = await _repository.stopMeeting(
        token: token,
        licenseKey: licenseKey,
        appSecret: appSecret,
        isLoading: isLoading,
        meetingId: meetingId,
      );

      if (res?.hasError ?? true) {
        return false;
      }
      return true;
    } catch (e, st) {
      IsmLiveLog.error(e, st);
      return false;
    }
  }
}
