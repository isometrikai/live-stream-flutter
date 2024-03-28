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

    userType = dbWrapper.getStringValue(LocalKeys.userType);
    navigation = IsmLiveNavigation.userTypr(userType);
    if (navigation.isCalling) {
      agent = AgentDetailsModel.fromJson(dbWrapper.getStringValue(LocalKeys.user));
    } else {
      user = UserDetailsModel.fromJson(dbWrapper.getStringValue(LocalKeys.user));
    }

    configData = IsmLiveConfigData(
      projectConfig: IsmLiveProjectConfig(
        accountId: navigation.isCalling ? agent.accountId : AppConstants.accountId,
        appSecret: navigation.isCalling ? agent.appSecret : AppConstants.appSecret,
        userSecret: navigation.isCalling ? agent.userToken : AppConstants.userSecret,
        keySetId: navigation.isCalling ? agent.keysetId : AppConstants.keySetId,
        licenseKey: navigation.isCalling ? agent.licenseKey : AppConstants.licenseKey,
        projectId: navigation.isCalling ? agent.projectId : AppConstants.projectId,
        deviceId: navigation.isCalling ? '' : user.deviceId,
      ),
      userConfig: IsmLiveUserConfig(
        userToken: navigation.isCalling ? agent.token.accessToken : user.userToken,
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
