import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component_example/data/data.dart';
import 'package:appscrip_live_stream_component_example/main.dart';
import 'package:appscrip_live_stream_component_example/models/models.dart';
import 'package:appscrip_live_stream_component_example/res/res.dart';
import 'package:appscrip_live_stream_component_example/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  DBWrapper get dbWrapper => Get.find<DBWrapper>();

  late UserDetailsModel user;
  late AgentDetailsModel agent;

  late String userType;

  late IsmLiveConfigData configData;

  @override
  Future<void> onInit() async {
    super.onInit();
    try {
      setupStream();
    } catch (e, st) {
      // Use IsmLiveLog for error logging
      IsmLiveLog.error('Error in HomeController.onInit: $e', st);
    }
  }

  void setupStream() async {
    user = UserDetailsModel.fromJson(dbWrapper.getStringValue(LocalKeys.user));
    debugPrint('IsmLiveApp: setupStream:  stated $user');
    configData = IsmLiveConfigData(
      projectConfig: IsmLiveProjectConfig(
        accountId: AppConstants.accountId,
        appSecret: AppConstants.appSecret,
        userSecret: AppConstants.userSecret,
        keySetId: AppConstants.keySetId,
        licenseKey: AppConstants.licenseKey,
        projectId: AppConstants.projectId,
        deviceId: user.deviceId,
      ),
      userConfig: IsmLiveUserConfig(
        userToken: user.userToken,
        userId: user.userId,
        firstName: user.firstName,
        lastName: user.lastName,
        userEmail: user.email,
        userProfile: '',
      ),
      mqttConfig: const IsmLiveMqttConfig(
        hostName: AppConstants.mqttHost,
        port: AppConstants.mqttPort,
      ),
    );
    // await IsmLiveApp.initialize(configData, navigatorKey: kNavigatorKey);
    // IsmLiveApp.configureInterface(
    // hostOptions: [
    //   IsmLiveStreamOption.bars,
    //   IsmLiveStreamOption.share,
    //   IsmLiveStreamOption.rotateCamera,
    //   IsmLiveStreamOption.settings,
    // ],
    // viewersOptions: [
    //   IsmLiveStreamOption.gift,
    //   IsmLiveStreamOption.share,
    //   IsmLiveStreamOption.speaker,
    //   IsmLiveStreamOption.heart,
    // ],
    // ismLiveButtonConfig: IsmLiveButtonConfig(
    //   primaryBuilder: (context,
    //           {required label,
    //           onTap,
    //           required small,
    //           required showBorder,
    //           icon,
    //           required secondary}) =>
    //       CustomButton(
    //     title: label,
    //     onPress: onTap,
    //   ),
    //   secondaryBuilder: (context,
    //           {required label,
    //           onTap,
    //           required small,
    //           required showBorder,
    //           icon,
    //           required secondary}) =>
    //       CustomButton(title: label, onPress: onTap, onlyBorder: true),
    // ),
    //   streamOptionsBgGradient : const LinearGradient(
    //     begin: Alignment.bottomCenter,
    //     end: Alignment.topCenter,
    //     colors: [
    //       ColorsValue.gradientStart,
    //       ColorsValue.gradientEnd,
    //     ],
    //   ),
    // liveAnalyticsOptions: [
    //   IsmLiveAnalyticsOptions.hearts,
    //   IsmLiveAnalyticsOptions.viewers,
    //   IsmLiveAnalyticsOptions.followers,
    //   IsmLiveAnalyticsOptions.earnings,
    //   IsmLiveAnalyticsOptions.duration,
    // ]
    // logoWidget: SvgPicture.asset('assets/logo/iamat_logo.svg'),
    // );
  }

  @override
  void onReady() {
    super.onReady();
    IsmLiveUtility.updateLater(() {
      kConfigData.value = configData;
    });
  }

  void logout(BuildContext context) async {
    dbWrapper.deleteBox();

    await dbWrapper.deleteAllSecuredValues();

    RouteManagement.goToLogin(context);
  }
}
