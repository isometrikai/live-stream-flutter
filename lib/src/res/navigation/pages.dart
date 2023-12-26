import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:get/get.dart';

part 'routes.dart';

class IsLivePages {
  static const transitionDuration = Duration(milliseconds: 300);

  static final pages = [
    GetPage<MyMeetingsView>(
      name: IsmLiveRoutes.myMeetingsView,
      transitionDuration: transitionDuration,
      page: MyMeetingsView.new,
      binding: MeetingBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<CreateMeetingScreen>(
      name: IsmLiveRoutes.createMeetingScreen,
      transitionDuration: transitionDuration,
      page: CreateMeetingScreen.new,
      // binding: MeetingBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<SearchUserScreen>(
      name: IsmLiveRoutes.searchUserScreen,
      transitionDuration: transitionDuration,
      page: SearchUserScreen.new,
      // binding: MeetingBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<RoomPage>(
      name: IsmLiveRoutes.roomPage,
      transitionDuration: transitionDuration,
      page: RoomPage.new,
      binding: IsmLiveCallingBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<IsmLiveStreamView>(
      name: IsmLiveStreamView.route,
      transitionDuration: transitionDuration,
      page: IsmLiveStreamView.new,
      binding: IsmLiveStreamBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<GoLiveView>(
      name: IsmLiveRoutes.goLive,
      transitionDuration: transitionDuration,
      page: GoLiveView.new,
      binding: IsmLiveStreamBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
