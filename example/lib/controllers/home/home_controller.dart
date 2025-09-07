import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component_example/data/data.dart';
import 'package:appscrip_live_stream_component_example/main.dart';
import 'package:appscrip_live_stream_component_example/models/models.dart';
import 'package:appscrip_live_stream_component_example/res/res.dart';
import 'package:appscrip_live_stream_component_example/utils/utils.dart';
import 'package:appscrip_live_stream_component_example/widgets/custom_input_field.dart';
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
      productStream: true,
      enableFreeGift: true,
      hostTopProfileClickCallback: (context, isHost, userIdentifier, name,
              imageUrl, description) async =>
          true,
      inputBuilder: (context, defaultMessageField) => LiveCustomInputField(
        defaultMessageField: defaultMessageField,
      ),

      restrictProfileSheetOnProfileClick: true,
      // streamViewLoadedCallback: (streamId, isHost, hostDetails) {
      //   IsmLiveLog.info('Stream_view_loaded: $streamId, $isHost, $hostDetails');
      // },
      // Custom Go Live header with host app branding
      // goLiveHeaderBuilder: _buildCustomGoLiveHeader,
      // Custom Go Live button with host app branding
      // goLiveButtonBuilder: _buildCustomGoLiveButton,
      // Configure dynamic font family - host app can provide their font name
      // fontFamily: 'Satoshi', // Example: Use Poppins font family
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
        buyNowButtonBuilder:
            (context, streamId, hasPinnedProduct, isHost, onTap) =>
                IsmLiveButton.secondary(
          label: 'Buy now',
          onTap: onTap,
        ),

        onGoLiveDispose: () {
          // Example: Cleanup operations when GoLive view is disposed
          IsmLiveLog.info('GoLive view disposed - performing cleanup');
        },
        onProductAction:
            (context, streamId, hasPinnedProduct, buttonLabel, isHost) {},
        hasPinnedProductGetter: () {
          // Return true if a product is currently pinned, false otherwise
          // This will be called every time the UI needs to check the pinned status
          return true; // Replace with your actual logic to check if product is pinned
        },
        pinnedProductBuilder: (context, controller) => SizedBox(
          width: 150,
          height: 200,
          child: Container(
            color: Colors.red,
          ),
        ),
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

  /// Simple custom Go Live header - close icon and highlighted text
  static Widget _buildCustomGoLiveHeader(
          BuildContext context, IsmLiveStreamController controller) =>
      Row(
        children: [
          // Close icon
          IconButton(
            icon: const Icon(
              Icons.close,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          // Highlighted text banner
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFCD0000),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Broadcasters under 18 are not permitted',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      );

  /// Custom Go Live button builder - only the button part (lines 15-120 equivalent)
  static Widget _buildCustomGoLiveButton(
    BuildContext context,
    IsmLiveStreamController controller,
    VoidCallback onGoLivePressed,
    bool isEnabled,
  ) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isEnabled
                  ? [const Color(0xFFFF6B6B), const Color(0xFFCD0000)]
                  : [Colors.grey[400]!, Colors.grey[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(25),
            boxShadow: isEnabled
                ? [
                    BoxShadow(
                      color: const Color(0xFFCD0000).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Custom styled Go Live button (equivalent to original lines 36-116)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isEnabled
                      ? Colors.white.withOpacity(0.1)
                      : Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isEnabled ? Colors.white : Colors.white54,
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(25),
                    onTap: isEnabled ? onGoLivePressed : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Live icon
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isEnabled
                                  ? Colors.white.withOpacity(0.2)
                                  : Colors.white.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.live_tv,
                              color: isEnabled ? Colors.white : Colors.white54,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Custom Go Live text with enabled state
                          Text(
                            isEnabled
                                ? 'Start Broadcasting'
                                : 'Enter description to continue',
                            style: TextStyle(
                              color: isEnabled ? Colors.white : Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Stream type indicator (only show when enabled)
                          if (isEnabled)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: controller.selectedGoLiveStream ==
                                        IsmLiveStreamTypes.premium
                                    ? Colors.amber.withOpacity(0.2)
                                    : Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                controller.selectedGoLiveStream.value
                                    .toUpperCase(),
                                style: TextStyle(
                                  color: controller.selectedGoLiveStream ==
                                          IsmLiveStreamTypes.premium
                                      ? Colors.amber
                                      : Colors.white70,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
