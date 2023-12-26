import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/views/stream/widgets/title_radio_button.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GoLiveView extends StatelessWidget {
  const GoLiveView({super.key});
  static const String update = 'go-live';
  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
      id: update,
      builder: (controller) => Scaffold(
            body: Stack(
              children: [
                Container(
                  color: Colors.amberAccent,
                  height: Get.height,
                  width: Get.width,
                ),
                Padding(
                  padding: IsmLiveDimens.edgeInsets16,
                  child: Column(
                    children: [
                      IsmLiveDimens.boxHeight32,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: IsmLiveColors.white,
                            ),
                            onPressed: Get.back,
                          ),
                          Text(
                            'Go Live',
                            style: IsmLiveStyles.whiteBold16,
                          ),
                          const IconButton(
                            icon: SizedBox(),
                            onPressed: null,
                          ),
                        ],
                      ),
                      IsmLiveDimens.boxHeight20,
                      Row(
                        children: [
                          Container(
                            height: IsmLiveDimens.hundred,
                            width: IsmLiveDimens.eighty,
                            decoration: BoxDecoration(
                              color: IsmLiveColors.white.withOpacity(0.3),
                              border: Border.all(
                                color: IsmLiveColors.white,
                                width: 0.5,
                              ),
                              borderRadius:
                                  BorderRadius.circular(IsmLiveDimens.ten),
                            ),
                            child: Column(
                              children: [
                                IconButton(
                                  padding: IsmLiveDimens.edgeInsets0,
                                  icon: const Icon(
                                    Icons.add,
                                    color: IsmLiveColors.white,
                                  ),
                                  onPressed: () {},
                                ),
                                Text(
                                  'Add Cover',
                                  style: IsmLiveStyles.white12,
                                ),
                              ],
                            ),
                          ),
                          IsmLiveDimens.boxWidth10,
                          Expanded(
                            child: IsmLiveInputField(
                              hintStyle: IsmLiveStyles.white12,
                              maxLines: 3,
                              alignLabelWithHint: true,
                              filled: true,
                              cursorColor: IsmLiveColors.white,
                              style: IsmLiveStyles.white16,
                              borderColor: IsmLiveColors.white,
                              fillColor: IsmLiveColors.white.withOpacity(0.3),
                              controller: controller.descriptionController,
                              hintText: 'Enter description',
                            ),
                          ),
                        ],
                      ),
                      IsmLiveDimens.boxHeight32,
                      TitleSwitchButton(
                        title: 'HD Broadcast',
                        onChange: controller.onChangeHdBroadcast,
                        value: controller.isHdBroadcast,
                      ),
                      IsmLiveDimens.boxHeight10,
                      TitleSwitchButton(
                        title: 'Record Broadcast',
                        onChange: controller.onChangeRecording,
                        value: controller.isRecordingBroadcast,
                      ),
                      const Spacer(),
                      IsmLiveButton(
                        label: 'Go Live',
                        onTap: () {
                          if (controller
                              .descriptionController.text.isNotEmpty) {
                            controller.startStream();
                          }
                        },
                      )
                    ],
                  ),
                ),
              ],
            ),
          ));
}
