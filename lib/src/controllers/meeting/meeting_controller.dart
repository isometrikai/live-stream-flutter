import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

class MeetingController extends GetxController {
  void connecting(
    String url,
    String token,
  ) async {
    const roomOptions = RoomOptions(
      adaptiveStream: true,
      dynacast: true,
    );

    await Room().connect(url, token, roomOptions: roomOptions);
  }
}
