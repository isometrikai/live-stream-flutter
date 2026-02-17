import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component_example/data/data.dart';
import 'package:appscrip_live_stream_component_example/res/res.dart';
import 'package:appscrip_live_stream_component_example/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

final kNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  await _setup();
  runApp(const MyApp());
}

Rx<IsmLiveConfigData?> kConfigData = Rx<IsmLiveConfigData?>(null);

Future<void> _setup() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.lazyPut(SharedPreferencesManager.new);
  IsmLiveUtility.navigatorKey = kNavigatorKey;
  await Future.wait([
    Get.put<AppConfig>(AppConfig()).init(AppConstants.appName),
    Get.put<DBWrapper>(DBWrapper()).init(),
  ]);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }

  @override
  Widget build(BuildContext context) => ScreenUtilInit(
        useInheritedMediaQuery: true,
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) => child!,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: Utility.hideKeyboard,
          child: MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.0)),
            child: GetMaterialApp(
              navigatorKey: kNavigatorKey,
              debugShowCheckedModeBanner: false,
              themeMode: ThemeMode.system, // Follow system theme
              theme: ThemeData(
                primaryColor: Colors.black,
                brightness: Brightness.light,
                floatingActionButtonTheme: const FloatingActionButtonThemeData(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                extensions: const [
                  IsmLiveDataExtension(
                    theme: IsmLiveThemeData(
                      primaryColor: IsmLiveColors.blue,
                      secondaryColor: IsmLiveColors.secondary,
                      backgroundColor: IsmLiveColors.white,
                      borderColor: IsmLiveColors.border,
                      selectedTextColor: IsmLiveColors.white,
                      unselectedTextColor: IsmLiveColors.grey,
                      cardBackgroundColor: IsmLiveColors.white,
                      primaryButtonTheme: IsmLiveButtonThemeData(
                        backgroundColor: IsmLiveColors.black,
                        foregroundColor: IsmLiveColors.white,
                        disableColor: IsmLiveColors.grey,
                      ),
                      secondaryButtonTheme: IsmLiveButtonThemeData(
                        backgroundColor: IsmLiveColors.white,
                        foregroundColor: IsmLiveColors.black,
                        disableColor: IsmLiveColors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              // darkTheme: ThemeData(
              //   primaryColor: Colors.white,
              //   brightness: Brightness.dark,
              //   floatingActionButtonTheme: const FloatingActionButtonThemeData(
              //     backgroundColor: Colors.white,
              //     foregroundColor: Colors.black,
              //   ),
              //   extensions: const [
              //     IsmLiveDataExtension(
              //       theme: IsmLiveThemeData(
              //         primaryColor: IsmLiveColors.white,
              //         secondaryColor: IsmLiveColors.secondary,
              //         backgroundColor:
              //             Color(0xFF121212), // Material dark background
              //         borderColor: Color(0xFF1E1E1E), // Dark border
              //         selectedTextColor: IsmLiveColors.white,
              //         unselectedTextColor:
              //             Color(0xFFB0B0B0), // Light grey for dark theme
              //         cardBackgroundColor:
              //             Color(0xFF1E1E1E), // Dark card background
              //         primaryButtonTheme: IsmLiveButtonThemeData(
              //           backgroundColor: IsmLiveColors.white,
              //           foregroundColor: IsmLiveColors.black,
              //           disableColor:
              //               Color(0xFF424242), // Dark grey for disabled state
              //         ),
              //         secondaryButtonTheme: IsmLiveButtonThemeData(
              //           backgroundColor:
              //               Color(0xFF2C2C2C), // Dark secondary button
              //           foregroundColor: IsmLiveColors.white,
              //           disableColor: Color(0xFF424242),
              //         ),
              //       ),
              //     ),
              //   ],
              // ),
              builder: (context, child) => Obx(
                () => IsmLiveData(
                  // Automatically uses light/dark theme based on system brightness
                  // Themes are provided via Material Theme extensions above
                  themeMode: ThemeMode.system,
                  configurations: kConfigData.value,
                  child: child!,
                ),
              ),
              translations: TranslationsFile(),
              getPages: AppPages.pages,
              initialRoute: AppPages.initial,
            ),
          ),
        ),
      );
}
