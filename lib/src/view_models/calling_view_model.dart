import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';

class IsmLiveCallingViewModel {
  const IsmLiveCallingViewModel(this._repository);
  final IsmLiveCallingRepository _repository;

  Future<bool> stopMeeting({
    required bool isLoading,
    required String meetingId,
  }) async {
    try {
      var res = await _repository.stopMeeting(
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
