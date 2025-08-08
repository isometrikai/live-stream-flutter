import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component_example/data/data.dart';
import 'package:appscrip_live_stream_component_example/main.dart';
import 'package:appscrip_live_stream_component_example/models/models.dart';
import 'package:appscrip_live_stream_component_example/res/res.dart';
import 'package:appscrip_live_stream_component_example/utils/utils.dart';
import 'package:flutter/material.dart';
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
    IsmLiveApp.configureInterface(
      productionMode: true,
      productStream: false,
      enableFreeGift: false,
      restrictProfileSheetOnProfileClick: true,
      // Enable free gifts - amount will be sent as 0
      ecomConfigure: IsmLiveEcomConfigure(
        // onGoLiveClick:
        //     (context, isScheduledStream, streamDetails, goLiveData) async {
        //   // Example: Handle image scenario
        //   if (goLiveData.pickedImage != null) {
        //     IsmLiveLog.info(
        //         'User picked image: ${goLiveData.pickedImage!.path}');
        //   }
        // },
        onGoLiveDispose: () {
          // Example: Cleanup operations when GoLive view is disposed
          IsmLiveLog.info('GoLive view disposed - performing cleanup');
        },
        onPinProduct: (context, streamId, isHost, isPublishing) {},
        // Example pinned product builder that can be updated dynamically
        pinnedProductBuilder: (context, controller) {
          // This widget will appear below the controls for hosts when productStream is true
          // You can update this widget by calling IsmLiveDelegate.updatePinnedProductWidget()
          return Container(
            width: 150,
            height: 200,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Pinned Product Widget',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.favorite,
                          color: Colors.white, size: 16),
                      onPressed: () {
                        // Example action
                        IsmLiveLog.info(
                            'Pinned product widget action triggered');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.share,
                          color: Colors.white, size: 16),
                      onPressed: () {
                        // Example action
                        IsmLiveLog.info('Share action triggered');
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      // Custom GoLive button click handler with comprehensive data

      // paidStream: false
      hostOptions: [
        IsmLiveStreamOption.bars,
        IsmLiveStreamOption.share,
        IsmLiveStreamOption.product,
        IsmLiveStreamOption.rotateCamera,
        IsmLiveStreamOption.settings,
      ],
      viewersOptions: [
        IsmLiveStreamOption.gift,
        IsmLiveStreamOption.share,
        IsmLiveStreamOption.speaker,
        IsmLiveStreamOption.heart,
      ],
      // ismliveButtonConfig: IsmLiveButtonConfig(
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
      // addProductViewBuilder: (
      //   BuildContext context
      // ) {
      //   return MyCustomAddProductView(

      //   );
      // },
    );
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
