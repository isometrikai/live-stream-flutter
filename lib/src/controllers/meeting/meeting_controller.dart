import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

class MeetingController extends GetxController {
  MeetingController(this.viewModel);

  final MeetingViewModel viewModel;
  void connectMeeting(
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
}
