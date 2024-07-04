import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/controllers/coins_plans_wallet_controller/coins_plans_wallet.dart';
import 'package:get/get.dart';

part 'routes.dart';

class IsmLivePages {
  static const transitionDuration = Duration(milliseconds: 300);

  static const String initialRoute = IsmLiveStreamListing.route;

  static final pages = [
    GetPage<IsmLiveStreamListing>(
      name: IsmLiveStreamListing.route,
      transitionDuration: transitionDuration,
      page: IsmLiveStreamListing.new,
      bindings: [
        IsmLiveStreamBinding(),
        IsmLiveMqttBinding(),
      ],
    ),
    GetPage<IsmLiveMeetingView>(
      name: IsmLiveRoutes.myMeetingsView,
      transitionDuration: transitionDuration,
      page: IsmLiveMeetingView.new,
      binding: IsmLiveMeetingBinding(),
    ),
    GetPage<CreateMeetingScreen>(
      name: IsmLiveRoutes.createMeetingScreen,
      transitionDuration: transitionDuration,
      page: CreateMeetingScreen.new,
    ),
    GetPage<SearchUserScreen>(
      name: IsmLiveRoutes.searchUserScreen,
      transitionDuration: transitionDuration,
      page: SearchUserScreen.new,
    ),
    GetPage<RoomPage>(
      name: IsmLiveRoutes.roomPage,
      transitionDuration: transitionDuration,
      page: RoomPage.new,
      binding: IsmLiveCallingBinding(),
    ),
    GetPage<IsmLiveStreamView>(
      name: IsmLiveStreamView.route,
      transitionDuration: transitionDuration,
      page: IsmLiveStreamView.new,
      bindings: [
        IsmLiveStreamBinding(),
        IsmLiveBroadcastBinding(),
      ],
    ),
    GetPage<IsmGoLiveView>(
      name: IsmLiveRoutes.goLive,
      transitionDuration: transitionDuration,
      page: IsmGoLiveView.new,
      binding: IsmLiveStreamBinding(),
    ),
    GetPage<IsmLiveEndStream>(
      name: IsmLiveRoutes.endStream,
      transitionDuration: transitionDuration,
      page: IsmLiveEndStream.new,
      bindings: [
        IsmLiveStreamBinding(),
        IsmLiveBroadcastBinding(),
      ],
    ),
    GetPage<IsmLiveRestreamView>(
      name: IsmLiveRoutes.restreamView,
      transitionDuration: transitionDuration,
      page: IsmLiveRestreamView.new,
      binding: IsmLiveStreamBinding(),
    ),
    GetPage<IsmLiveRestreamSettingsView>(
      name: IsmLiveRoutes.restreamSettingsView,
      transitionDuration: transitionDuration,
      page: IsmLiveRestreamSettingsView.new,
      binding: IsmLiveStreamBinding(),
    ),
    GetPage<IsmLiveAddProduct>(
      name: IsmLiveRoutes.addProduct,
      transitionDuration: transitionDuration,
      page: IsmLiveAddProduct.new,
      binding: IsmLiveStreamBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<IsmLiveTagProducts>(
      name: IsmLiveRoutes.tagProduct,
      transitionDuration: transitionDuration,
      page: IsmLiveTagProducts.new,
      binding: IsmLiveStreamBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<CoinsPlansWalletView>(
      name: IsmLiveRoutes.coinsPlansWalletView,
      transitionDuration: transitionDuration,
      page: CoinsPlansWalletView.new,
      binding: CoinsPlansWalletBinding(),
      transition: Transition.rightToLeft,
    ),
  ];
}
