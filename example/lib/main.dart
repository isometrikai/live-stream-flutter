import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component_example/data/data.dart';
import 'package:appscrip_live_stream_component_example/res/res.dart';
import 'package:appscrip_live_stream_component_example/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  await _setup();
  runApp(const MyApp());
}

Rx<IsmLiveConfigData?> kConfigData = Rx<IsmLiveConfigData?>(null);

Future<void> _setup() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.lazyPut(SharedPreferencesManager.new);
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
          child: GetMaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primaryColor: Colors.black,
              textTheme: GoogleFonts.getTextTheme('Roboto'),
              floatingActionButtonTheme: const FloatingActionButtonThemeData(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              extensions: [
                IsmLiveDataExtension(),
              ],
            ),
            // builder: (context, child) => Obx(
            //   () => IsmLiveData(
            //     configurations: kConfigData.value,
            //     child: child!,
            //   ),
            // ),
            translations: TranslationsFile(),
            getPages: AppPages.pages,
            initialRoute: AppPages.initial,
          ),
        ),
      );
}
