import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component_example/controllers/home/custom_button.dart';
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
      goLiveSmallButtonBuilder: _buildCustomGoLiveSmallButton,
      goLiveScreenConfigure: IsmLiveGoLiveScreenConfigure(
        goLiveButtonBuilder: _buildCustomGoLiveButton,
        //   goLiveHeaderBuilder: _buildCustomGoLiveHeader,
      ),
      cartBuilder: (context, controller) => Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white24,
        ),
        child: const Icon(
          Icons.shopping_cart_outlined,
          color: Colors.white,
          size: 16,
        ),
      ),
      // customBottomSheetBuilder:
      //     (context, title, leftLabel, rightLabel, onLeft, onRight) {
      //   return Container(
      //     padding: EdgeInsets.all(20),
      //     decoration: BoxDecoration(
      //       color: Colors.white,
      //       borderRadius: BorderRadius.circular(20),
      //     ),
      //     child: Column(
      //       mainAxisSize: MainAxisSize.min,
      //       children: [
      //         Text(
      //           title,
      //           style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      //         ),
      //         SizedBox(height: 20),
      //         Row(
      //           children: [
      //             Expanded(
      //               child: ElevatedButton(
      //                 onPressed: onLeft,
      //                 child: Text(leftLabel),
      //               ),
      //             ),
      //             SizedBox(width: 10),
      //             Expanded(
      //               child: ElevatedButton(
      //                 onPressed: onRight,
      //                 child: Text(rightLabel),
      //               ),
      //             ),
      //           ],
      //         ),
      //       ],
      //     ),
      //   );
      // },
      bottomSheetBorderRadius:
          const BorderRadius.vertical(top: Radius.circular(12)),

      // moderatorsListCallback: (context, streamId, isHost, isModerator,
      //     moderatorsList, hostDetails) async {
      //   // Custom moderators list implementation
      //   return true;
      // },

      // topViewersListCallback: (context, viewerList, streamId, isHost,
      //     isModerator, streamViewersList) async {
      //   // Simple temporary viewers list implementation
      //   showModalBottomSheet(
      //     context: context,
      //     shape: const RoundedRectangleBorder(
      //       borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      //     ),
      //     builder: (context) => Container(
      //       padding: const EdgeInsets.all(16),
      //       child: Column(
      //         mainAxisSize: MainAxisSize.min,
      //         children: [
      //           // Header
      //           Container(
      //             width: 40,
      //             height: 4,
      //             decoration: BoxDecoration(
      //               color: Colors.grey[300],
      //               borderRadius: BorderRadius.circular(2),
      //             ),
      //           ),
      //           const SizedBox(height: 16),
      //           Text(
      //             'Viewers (${streamViewersList.length})',
      //             style: const TextStyle(
      //               fontSize: 18,
      //               fontWeight: FontWeight.bold,
      //             ),
      //           ),
      //           const SizedBox(height: 16),
      //           // Viewers list
      //           Flexible(
      //             child: ListView.builder(
      //               shrinkWrap: true,
      //               itemCount: streamViewersList.length,
      //               itemBuilder: (context, index) {
      //                 final viewer = streamViewersList[index];
      //                 return ListTile(
      //                   leading: CircleAvatar(
      //                     child: viewer.imageUrl?.isEmpty != false
      //                         ? Text(viewer.userName
      //                                 .substring(0, 1)
      //                                 .toUpperCase() ??
      //                             'U')
      //                         : null,
      //                   ),
      //                   title: Text(viewer.userName ?? 'Unknown User'),
      //                   subtitle: Text(viewer.name ?? ''),
      //                   trailing: ElevatedButton(
      //                     onPressed: () {
      //                       // Simple action - you can customize this
      //                       if (isHost || isModerator) {
      //                         Get.find<IsmLiveStreamController>().kickoutViewer(
      //                           streamId: streamId,
      //                           viewerId: viewer?.userId ?? '',
      //                         );
      //                         Navigator.pop(context);
      //                       }
      //                     },
      //                     style: ElevatedButton.styleFrom(
      //                       backgroundColor: Colors.red,
      //                       foregroundColor: Colors.white,
      //                       minimumSize: const Size(60, 30),
      //                     ),
      //                     child: Text(
      //                       (isHost || isModerator) ? 'Kick' : 'View',
      //                       style: const TextStyle(fontSize: 12),
      //                     ),
      //                   ),
      //                 );
      //               },
      //             ),
      //           ),
      //           const SizedBox(height: 16),
      //         ],
      //       ),
      //     ),
      //   );

      //   return true; // Prevent default viewers sheet
      // },

      // streamViewLoadedCallback: (streamId, isHost, hostDetails) {
      //   IsmLiveLog.info('Stream_view_loaded: $streamId, $isHost, $hostDetails');
      // },
      // Custom Go Live header with host app branding
      // Custom Go Live button with host app branding
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
        // buyNowButtonBuilder:
        //     (context, streamId, hasPinnedProduct, isHost, onTap) =>
        //         IsmLiveButton.secondary(
        //   label: 'Buy now',
        //   onTap: onTap,
        // ),
        hostArrowButtonsHeight: 56,
        onProductAction:
            (context, streamId, hasPinnedProduct, buttonLabel, isHost) {},
        hasPinnedProductGetter: () {
          // Return true if a product is currently pinned, false otherwise
          // This will be called every time the UI needs to check the pinned status
          return true; // Replace with your actual logic to check if product is pinned
        },
        // pinnedProductBuilder: (context, controller) => SizedBox(
        //   width: 150,
        //   height: 200,
        //   child: Container(
        //     color: Colors.red,
        //   ),
        // ),
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
      rtmpOptions: [
        IsmLiveStreamOption.bars,
        IsmLiveStreamOption.share,
        IsmLiveStreamOption.product,
      ],
      viewersOptions: [
        IsmLiveStreamOption.gift,
        IsmLiveStreamOption.share,
        IsmLiveStreamOption.speaker,
        IsmLiveStreamOption.heart,
      ],
      ismLiveButtonConfig: IsmLiveButtonConfig(
        primaryBuilder: (context,
                {required label,
                onTap,
                required small,
                required showBorder,
                icon,
                required secondary}) =>
            CustomButton(
          title: label,
          onPress: onTap,
        ),
        secondaryBuilder: (context,
                {required label,
                onTap,
                required small,
                required showBorder,
                icon,
                required secondary}) =>
            CustomButton(title: label, onPress: onTap, onlyBorder: true),
      ),
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
      Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Padding(
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
                                color:
                                    isEnabled ? Colors.white : Colors.white54,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Custom Go Live text with enabled state
                            Text(
                              controller.isSchedulingBroadcast
                                  ? 'Schedule Stream'
                                  : 'Go Live',
                              style: TextStyle(
                                color:
                                    isEnabled ? Colors.white : Colors.white70,
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
        ),
      );

  static Widget _buildCustomGoLiveSmallButton(
    BuildContext context,
    IsmLiveStreamController controller,
    VoidCallback onGoLivePressed,
    bool isEnabled,
  ) {
    final scheduleTime = controller.streamDetails?.scheduleStartTime;
    final isTimePassed = _isScheduleTimePassed(scheduleTime);
    final formattedTime = scheduleTime != null
        ? _formatScheduleTime(scheduleTime)
        : 'No time set';
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B6B), Color(0xFFCD0000)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: isTimePassed ? onGoLivePressed : null,
          child: Container(
            height: IsmLiveDimens.fifty,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(
              child: Text(
                isTimePassed ? 'Go Live' : formattedTime,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Formats schedule time to "22 Sept, 04:15 PM" format
  static String _formatScheduleTime(DateTime scheduleTime) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sept',
      'Oct',
      'Nov',
      'Dec'
    ];

    final day = scheduleTime.day;
    final month = months[scheduleTime.month - 1];
    final hour = scheduleTime.hour;
    final minute = scheduleTime.minute.toString().padLeft(2, '0');

    // Convert to 12-hour format
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);

    return '$day $month, ${displayHour.toString().padLeft(2, '0')}:$minute $period';
  }

  /// Determines if the scheduled time has passed
  static bool _isScheduleTimePassed(DateTime? scheduleTime) {
    if (scheduleTime == null) return true;
    return DateTime.now().isAfter(scheduleTime);
  }
}
