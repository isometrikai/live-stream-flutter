import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:get/get.dart';

class IsmLiveStreamController extends GetxController {
  IsmLiveStreamController(this._viewModel);
  var meetingController = Get.find<MeetingController>();
  final IsmLiveStreamViewModel _viewModel;

  Future<bool?> stopMeeting(
      {required bool isLoading, required String meetingId}) async {
    var res = await _viewModel.stopMeeting(
        token: meetingController.configuration?.userConfig.userToken ?? '',
        licenseKey:
            meetingController.configuration?.communicationConfig.licenseKey ??
                '',
        appSecret:
            meetingController.configuration?.communicationConfig.appSecret ??
                '',
        isLoading: isLoading,
        meetingId: meetingId);

    return res;
  }
}
