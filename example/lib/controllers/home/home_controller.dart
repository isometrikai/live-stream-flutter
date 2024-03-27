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

  @override
  void onInit() {
    super.onInit();

    user = UserDetailsModel.fromJson(dbWrapper.getStringValue(LocalKeys.user));
    agent =
        AgentDetailsModel.fromJson(dbWrapper.getStringValue(LocalKeys.user));
    userType = dbWrapper.getStringValue(LocalKeys.userType);
    navigation = IsmLiveNavigation.userTypr(userType);

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
        userToken: navigation.navigateToCalling
            ? agent.token.accessToken
            : user.userToken,
        userId: navigation.navigateToCalling ? agent.userId : user.userId,
        firstName: navigation.navigateToCalling ? agent.name : user.firstName,
        lastName: navigation.navigateToCalling ? agent.name : user.lastName,
        userEmail: navigation.navigateToCalling ? '' : user.email,
        userProfile: '',
      ),
      mqttConfig: const IsmLiveMqttConfig(
        hostName: AppConstants.mqttHost,
        port: AppConstants.mqttPort,
      ),
    );
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
    RouteManagement.goToRampup();
  }
}
