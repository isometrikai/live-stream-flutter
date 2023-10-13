import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/repositories/meeting_repository.dart';
import 'package:get/get.dart';

class MeetingBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MeetingController>(
      () => MeetingController(
        MeetingViewModel(
          MeetingRepository(),
        ),
      ),
    );
  }
}
