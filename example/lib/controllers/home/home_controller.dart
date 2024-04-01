import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component_example/data/data.dart';
import 'package:appscrip_live_stream_component_example/main.dart';
import 'package:appscrip_live_stream_component_example/models/models.dart';
import 'package:appscrip_live_stream_component_example/res/res.dart';
import 'package:appscrip_live_stream_component_example/utils/utils.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  DBWrapper get dbWrapper => Get.find<DBWrapper>();

  late UserDetailsModel user;
  late AgentDetailsModel agent;

  late String userType;

  late IsmLiveConfigData configData;

  late IsmLiveNavigation navigation;

  AppConfig get _appConfig => Get.find();

  @override
  void onInit() {
    super.onInit();

    userType = dbWrapper.getStringValue(LocalKeys.userType);
    navigation = IsmLiveNavigation.userTypr(userType);
    if (navigation.isCalling) {
      agent = AgentDetailsModel.fromJson(dbWrapper.getStringValue(LocalKeys.agent));
    } else {
      user = UserDetailsModel.fromJson(dbWrapper.getStringValue(LocalKeys.user));
    }

    // TODO: Check for creds from login API

    configData = IsmLiveConfigData(
      projectConfig: IsmLiveProjectConfig(
        accountId: navigation.isCalling ? AppConstants.accountIdCallQwik : AppConstants.accountId,
        appSecret: navigation.isCalling ? AppConstants.appSecretCallQwik : AppConstants.appSecret,
        userSecret: navigation.isCalling ? AppConstants.userSecretCallQwik : AppConstants.userSecret,
        keySetId: navigation.isCalling ? AppConstants.keySetIdCallQwik : AppConstants.keySetId,
        licenseKey: navigation.isCalling ? AppConstants.licenseKeyCallQwik : AppConstants.licenseKey,
        projectId: navigation.isCalling ? AppConstants.projectIdCallQwik : AppConstants.projectId,
        deviceId: navigation.isCalling ? _appConfig.deviceId! : user.deviceId,
      ),
      userConfig: IsmLiveUserConfig(
        userToken: navigation.isCalling ? agent.userToken : user.userToken,
        userId: navigation.isCalling ? agent.userId : user.userId,
        firstName: navigation.isCalling ? agent.name : user.firstName,
        lastName: navigation.isCalling ? agent.name : user.lastName,
        userEmail: navigation.isCalling ? '' : user.email,
        userProfile: navigation.isCalling ? agent.userProfileUrl : '',
      ),
      mqttConfig: const IsmLiveMqttConfig(
        hostName: AppConstants.mqttHost,
        port: AppConstants.mqttPort,
      ),
    );

    IsmLiveApp.initialize(configData);
  }

  @override
  void onReady() {
    super.onReady();
    IsmLiveUtility.updateLater(() {
      kConfigData.value = configData;
    });
  }

  void logout() async {
    await dbWrapper.deleteAllSecuredValues();
    dbWrapper.deleteBox();
    RouteManagement.goToAuthWrapper();
  }
}
