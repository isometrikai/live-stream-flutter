import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/models/my_meeting_model.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

class MeetingController extends GetxController {
  MeetingController(this.viewModel);
  List<MyMeetingModel> myMeetingList = [];
  final MeetingViewModel viewModel;

  Future<void> connectMeeting(
    String url,
    String token,
  ) async {
    var room = Room();
    const roomOptions = RoomOptions(
      adaptiveStream: true,
      dynacast: true,
    );

    await room.connect(url, token, roomOptions: roomOptions);
  }

  Future<void> getMeetingList(
      {required String token,
      required String licenseKey,
      required String appSecret}) async {
    var res = await viewModel.getMeetingsList(
        token: token, licenseKey: licenseKey, appSecret: appSecret);
    myMeetingList = res ?? [];
  }

  Future<String?> joinMeeting(
      {required String token,
      required String licenseKey,
      required String appSecret,
      required String meetingId}) async {
    var res = await viewModel.joinMeeting(
        token: token,
        licenseKey: licenseKey,
        appSecret: appSecret,
        meetingId: meetingId);
    if (res != null) {
      return res;
    }
    return null;
  }
}
