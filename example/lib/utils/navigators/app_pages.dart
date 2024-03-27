import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component_example/controllers/controllers.dart';
import 'package:appscrip_live_stream_component_example/views/views.dart';
import 'package:get/get.dart';

part 'app_routes.dart';

/// Contains the list of pages or routes taken across the whole application.
/// This will prevent us in using context for navigation. And also providing
/// the blocs required in the next named routes.
///
/// [pages] : will contain all the pages in the application as a route
/// and will be used in the material app.
/// Will be ignored for test since all are static values and would not change.
class AppPages {
  static var transitionDuration = const Duration(
    milliseconds: 350,
  );

  static const initial = AppRoutes.splash;

  static final pages = [
    GetPage<SplashView>(
      name: AppRoutes.splash,
      transitionDuration: transitionDuration,
      page: SplashView.new,
      binding: SplashBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<HomeView>(
      name: AppRoutes.home,
      transitionDuration: transitionDuration,
      page: HomeView.new,
      binding: HomeBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<LoginView>(
      name: AppRoutes.login,
      transitionDuration: transitionDuration,
      page: LoginView.new,
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<AgentPhoneView>(
      name: AppRoutes.agentPhone,
      transitionDuration: transitionDuration,
      page: AgentPhoneView.new,
      binding: AgentAuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<AgentOtpView>(
      name: AppRoutes.agentOtp,
      transitionDuration: transitionDuration,
      page: AgentOtpView.new,
      binding: AgentAuthBinding(),
      transition: Transition.rightToLeft,
    ),
    GetPage<RampUpView>(
      name: AppRoutes.rampUp,
      transitionDuration: transitionDuration,
      page: RampUpView.new,
      transition: Transition.rightToLeft,
    ),
    GetPage<SignupView>(
      name: AppRoutes.signup,
      transitionDuration: transitionDuration,
      page: SignupView.new,
      binding: AuthBinding(),
      transition: Transition.rightToLeft,
    ),
    ...IsmLivePages.pages,
  ];
}
