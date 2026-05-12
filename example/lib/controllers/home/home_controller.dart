import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/controllers/mqtt/wrapper/models/event_model.dart';
import 'package:appscrip_live_stream_component_example/data/data.dart';
import 'package:appscrip_live_stream_component_example/main.dart';
import 'package:appscrip_live_stream_component_example/models/models.dart';
import 'package:appscrip_live_stream_component_example/res/res.dart';
import 'package:appscrip_live_stream_component_example/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class _ExampleAnalyticsDelegate extends IsmLiveAnalyticsDelegate {
  const _ExampleAnalyticsDelegate();

  @override
  void trackEventModel(IsmLiveAnalyticsEventModel analyticsEventModel) {
    IsmLiveLog.info(
      'SDK analytics: ${analyticsEventModel.eventName} enum=${analyticsEventModel.eventType} category=${analyticsEventModel.category.value} props=${analyticsEventModel.properties}',
    );
  }
}

class HomeController extends GetxController {
  DBWrapper get dbWrapper => Get.find<DBWrapper>();

  late UserDetailsModel user;
  late AgentDetailsModel agent;

  late String userType;

  late IsmLiveConfigData configData;
  bool _isLoggingOut = false;
  StreamSubscription<EventModel>? _streamSubscription;

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
      useGridLayoutForMultipleParticipants : false,
      productionMode: true,
      // Remove `const` if you uncomment builders or callbacks below.
      goLiveScreenConfigure: const IsmLiveGoLiveScreenConfigure(
        isProductStreamFeatureEnabled: true,
        isScheduleStreamFeatureEnabled: true,
        defaultBroadcastDescription: "Hey dubly!"
        // Feature flags:
        // isHdStreamFeatureEnabled: true,
        // isRtmpStreamFeatureEnabled: true,
        // isRestreamStreamFeatureEnabled: true,
        // isPaidStreamFeatureEnabled: false,
        // isMultiLiveStreamFeatureEnabled: true,
        // isRecordedStreamFeatureEnabled: true,
        //
        // Default toggles for a fresh Go Live flow (ignored when editing a stream):
        // defaultHdBroadcastToggleValue: false,
        // defaultRecordBroadcastToggleValue: false,
        // defaultRestreamBroadcastToggleValue: false,
        //
        // goLiveHeaderBuilder: HomeController._buildCustomGoLiveHeader,
        // goLiveButtonBuilder: HomeController._buildCustomGoLiveButton,
        //
        // onGoLiveButtonTap:
        //     (context, isScheduledStream, streamDetails, goLiveData) async {
        //   if (goLiveData.pickedImage != null) {
        //     IsmLiveLog.info(
        //       'User picked image: ${goLiveData.pickedImage!.path}',
        //     );
        //   }
        // },
        // onGoLiveViewDispose: () {},
      ),
      enableFreeGift: false,
      analyticsDelegate: const _ExampleAnalyticsDelegate(),
      scheduleStreamCenterOverlayBuilder: _buildScheduleCenterOverlay,
      enabledAnalyticsEventTypes: {
        ...IsmLiveAnalyticsEvent.allTypes,
        IsmLiveAnalyticsEventType.streamInitializeAndJoinSuccess,
      },
      hostTopProfileClickCallback: (context, isHost, userIdentifier, name,
              imageUrl, description) async =>
          true,
      // inputBuilder: (context, defaultMessageField) => LiveCustomInputField(
      //   defaultMessageField: defaultMessageField,
      // ),

      restrictProfileSheetOnProfileClick: true,

      // chatMessageBuilder: (context, message, defaultChild) {
      //   // Change background color for host messages

      //   return defaultChild; // Use default for others
      // },
      // chatItemBgColorCallback: (message) {
      //   // ✅ New name
      //   if (message.sentByHost) {
      //     return Colors.red.withValues(alpha: 0.4);
      //   }
      //   return null;
      // },

      // messageProcessCallback: (message, streamId, isMqtt, isHost) => message,
      // cartBuilder: (context, controller) => Container(
      //   padding: const EdgeInsets.all(8),
      //   decoration: const BoxDecoration(
      //     shape: BoxShape.circle,
      //     color: Colors.white24,
      //   ),
      //   child: const Icon(
      //     Icons.shopping_cart_outlined,
      //     color: Colors.white,
      //     size: 16,
      //   ),
      // ),
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
      streamRecordingPlayerConfig: IsmLiveStreamRecordingPlayerConfig(
        onControlOption: (context, option, recording) async {
          await showModalBottomSheet<void>(
            context: context,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            builder: (sheetContext) => Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Dummy bottom sheet text',
                    style: Theme.of(sheetContext).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Clicked option: ${option.name}',
                    style: Theme.of(sheetContext).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Recording id: ${recording.streamId}',
                    style: Theme.of(sheetContext).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),

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
        buyNowButtonBuilder:
            (context, streamId, hasPinnedProduct, isHost, onTap) => SizedBox(
          width: IsmLiveDimens.oneHundredTwenty,
          height: IsmLiveDimens.fifty,
          child: IsmLiveButton.secondary(
            label: 'Buy it',
            onTap: onTap,
          ),
        ),
        hostArrowButtonsSize: 56,
        pinItemCallback: (direction, context) {},
        // Replace with real pinned-product state; invoked whenever the UI refreshes.
        hasPinnedProductGetter: () => true,
        // pinnedProductBuilder: (context, controller) => SizedBox(
        //   width: 150,
        //   height: 200,
        //   child: Container(
        //     color: Colors.red,
        //   ),
        // ),
        // addProductViewBuilder: (context) => MyCustomAddProductView(),
      ),
      sideIconsConfigure: const IsmLiveSideIconsConfigure(
        hostOptions: [
          IsmLiveStreamOption.bars,
          IsmLiveStreamOption.share,
          IsmLiveStreamOption.vs,
          IsmLiveStreamOption.rotateCamera,
          IsmLiveStreamOption.settings,
          IsmLiveStreamOption.multiLive,
        ],
        // rtmpOptions: [
        //   IsmLiveStreamOption.bars,
        //   IsmLiveStreamOption.share,
        //   IsmLiveStreamOption.product,
        // ],
        viewersOptions: [
          IsmLiveStreamOption.gift,
          IsmLiveStreamOption.share,
          IsmLiveStreamOption.speaker,
          IsmLiveStreamOption.heart,
        ],
        // Must live under sideIconsConfigure (not on configureInterface):
        // controlOptionCallback:
        //     (context, option, streamId, isHost, isCopublishing) async {
        //   if (option == IsmLiveStreamOption.gift) {
        //     // await yourCustomGiftFlow(context);
        //     return true; // handled
        //   }
        //   return false; // use SDK default
        // },
        // controlWidgetBuilder:
        //     (context, option, onTap, isHost, isCopublishing, streamId) {
        //   if (option == IsmLiveStreamOption.gift) {
        //     return IconButton(icon: const Icon(Icons.card_giftcard), onTap: onTap);
        //   }
        //   return null; // SDK default widget
        // },
        // productStreamSideOptionsBottomMargin: (context) {
        //   final h = MediaQuery.sizeOf(context).height;
        //   return h * 0.45; // or null for SDK default (~28% of height)
        // },
      ),

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
      // Paid / HD / RTMP toggles belong in goLiveScreenConfigure → see flags above.
      // addProductViewBuilder lives inside ecomConfigure → see commented line there.
      // tokenExpiredCallback: () async {
      //   IsmLiveLog.info('Token expired');
      //   return 'SFMyNTY.g2gDbQAAABg2NWVhZmY2NjgzN2QwNTAwMDE3MTJiZmJuBgCY7lV2nQFiAAFRgA.ZCN7AnyTUBMp2v3ctOt9N3FlgbYklOZLLo9aIAsd1hA';
      // },
    );

    // Set up listener for MQTT events from IsmLiveApp
    // _streamSubscription = IsmLiveApp.addListener((event) {
    //   // Forward MQTT events to chat SDK for processing
    //   IsmChat.i.listenMqttEvent(event);
    // });
  }

  @override
  void onReady() {
    super.onReady();
    IsmLiveUtility.updateLater(() {
      kConfigData.value = configData;
    });
  }

  @override
  void onClose() {
    _streamSubscription?.cancel();
    _streamSubscription = null;
    super.onClose();
  }

  void logout(BuildContext context) async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;

    // Reset live-stream component singletons/controllers (otherwise previous
    // user state can remain in memory after logout).
    //
    // Important: dispose() triggers the package onLogout callback. In this
    // example, onLogout is wired to call this same method, so we pass a noop
    // callback to avoid re-entrant navigation loops.
    await IsmLiveApp.dispose(isLoading: false, logoutCallback: () {});

    // Ensure next login doesn't reuse the previous user's config.
    kConfigData.value = null;

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
                        color: const Color(0xFFCD0000).withValues(alpha: 0.3),
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
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.white.withValues(alpha: 0.05),
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
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : Colors.white.withValues(alpha: 0.1),
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
                                      ? Colors.amber.withValues(alpha: 0.2)
                                      : Colors.white.withValues(alpha: 0.1),
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
      width: IsmLiveDimens.oneHundredFifty,
      margin: const EdgeInsets.only(bottom: 4),
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

  static Widget _buildScheduleCenterOverlay(
    BuildContext context,
    IsmLiveStreamController controller,
  ) {
    final show = controller.streamDetails?.eventId?.isNotEmpty == true &&
        controller.streamId.isNullOrEmpty;
    final scheduleTime = controller.streamDetails?.scheduleStartTime;
    final scheduledText = scheduleTime != null
        ? _formatScheduleTime(scheduleTime)
        : 'No schedule selected';
    final screenWidth = MediaQuery.of(context).size.width;

    return show
        ? Container(
            width: screenWidth,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_month,
                      color: Colors.white, size: 24),
                  const SizedBox(height: 8),
                  const Text(
                    'Center Overlay Demo',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    scheduledText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          )
        : Container();
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
