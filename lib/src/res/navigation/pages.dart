import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:get/get.dart';

part 'routes.dart';

class IsLivePages {
  static var transitionDuration = const Duration(
    milliseconds: 350,
  );

  static final pages = [
    GetPage<MyMeetingsView>(
      name: IsLiveRoutes.myMeetingsView,
      transitionDuration: transitionDuration,
      page: MyMeetingsView.new,
      binding: MeetingBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<CreateMeetingScreen>(
      name: IsLiveRoutes.createMeetingScreen,
      transitionDuration: transitionDuration,
      page: CreateMeetingScreen.new,
      // binding: MeetingBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<SearchUserScreen>(
      name: IsLiveRoutes.searchUserScreen,
      transitionDuration: transitionDuration,
      page: SearchUserScreen.new,
      // binding: MeetingBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<RoomPage>(
      name: IsLiveRoutes.roomPage,
      transitionDuration: transitionDuration,
      page: RoomPage.new,
      binding: IsmLiveStreamBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
