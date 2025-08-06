import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmGoLiveNavBar extends StatelessWidget {
  const IsmGoLiveNavBar({super.key});

  @override
  Widget build(BuildContext context) => SafeArea(
        child: GetBuilder<IsmLiveStreamController>(
          id: IsmGoLiveView.updateId,
          builder: (controller) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: IsmLiveDimens.edgeInsets16_0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: IsmLiveColors.red,
                    borderRadius:
                        BorderRadius.circular(IsmLiveDimens.twentyFive),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: IsmLiveDimens.edgeInsets4,
                        child: Text(
                          'Broadcasters under 18 are not permitted',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IsmLiveButton(
                        label: 'Go Live',
                        showBorder: true,
                        onTap: () async {
                          final isScheduledStream =
                              controller.streamDetails?.isScheduledStream ??
                                  false;

                          if (IsmLiveDelegate.ecomConfigure?.onGoLiveClick !=
                              null) {
                            // Handle image scenario similar to join_mixin.dart logic
                            if (controller.pickedImage == null) {
                              // Try to take picture from camera first
                              final file = await controller.cameraController
                                  ?.takePicture();
                              if (file != null) {
                                controller.pickedImage = file;
                                controller.update([IsmGoLiveView.updateId]);
                              } else {
                                // If camera fails, pick from gallery
                                var file = await FileManager.pickGalleryImage();
                                if (file != null) {
                                  controller.pickedImage = file;
                                  controller.update([IsmGoLiveView.updateId]);
                                }
                              }
                            }

                            // Create comprehensive data object with all user-entered details
                            final goLiveData = IsmLiveGoLiveData(
                              isScheduledStream: isScheduledStream,
                              streamDetails: controller.streamDetails,
                              description:
                                  controller.descriptionController.text,
                              pickedImage: controller
                                  .pickedImage, // Use the final pickedImage (either picked from gallery or taken from camera)
                              isHdBroadcast: controller.isHdBroadcast,
                              isRecordingBroadcast:
                                  controller.isRecordingBroadcast,
                              isRestreamBroadcast:
                                  controller.isRestreamBroadcast,
                              isPremium: controller.isPremium,
                              isSchedulingBroadcast:
                                  controller.isSchedulingBroadcast,
                              usePersistentStreamKey:
                                  controller.usePersistentStreamKey,
                              isRtmp: controller.isRtmp,
                              selectedGoLiveTabItem:
                                  controller.selectedGoLiveTabItem,
                              selectedGoLiveStream:
                                  controller.selectedGoLiveStream,
                              scheduleLiveDate: controller.scheduleLiveDate,
                              premiumStreamCoins:
                                  controller.premiumStreamCoinsController.text,
                              restreamFacebook: controller.restreamFacebook,
                              restreamYoutube: controller.restreamYoutube,
                              restreamInstagram: controller.restreamInstagram,
                              rtmpUrl: controller.rtmlUrl.text,
                              streamKey: controller.streamKey.text,
                              rtmpUrlDevice: controller.rtmlUrlDevice.text,
                              streamKeyDevice: controller.streamKeyDevice.text,
                            );

                            await IsmLiveDelegate.ecomConfigure!.onGoLiveClick!(
                              context,
                              isScheduledStream,
                              controller.streamDetails,
                              goLiveData,
                            );
                            return;
                          }

                          // Default behavior
                          if (isScheduledStream) {
                            controller.editScheduleStream(context);
                            return;
                          }

                          controller.startStream(context: context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
              if (!(controller.streamDetails?.isScheduledStream ?? false) &&
                  (IsmLiveDelegate.multiLiveStream ?? true))
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: IsmGoLiveTabItem.values.map((e) {
                    final isSelected = controller.selectedGoLiveTabItem == e;
                    return Expanded(
                      child: IsmLiveTapHandler(
                        onTap: () {
                          controller.selectedGoLiveTabItem = e;

                          controller.onChangeRtmp(
                              controller.selectedGoLiveTabItem ==
                                  IsmGoLiveTabItem.liveFromDevice);
                          controller.onChangePersistent(false);

                          controller.update([IsmGoLiveView.updateId]);
                        },
                        child: Padding(
                          padding: IsmLiveDimens.edgeInsets0_4,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                e.label,
                                style: context.textTheme.labelLarge?.copyWith(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.white54,
                                ),
                              ),
                              if (isSelected) ...[
                                IsmLiveDimens.boxHeight4,
                                Container(
                                  height: 2,
                                  width:
                                      MediaQuery.of(context).size.width * 0.25,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      );
}
