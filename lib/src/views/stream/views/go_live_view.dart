import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/views/stream/widgets/your_live_sheet.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmGoLiveView extends StatelessWidget {
  const IsmGoLiveView({super.key});

  static const String updateId = 'go-live';

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: updateId,
        initState: (state) async {
          var controller = Get.find<IsmLiveStreamController>();
          controller.pickedImage = null;
          controller.descriptionController.clear();
          controller.isHdBroadcast = false;
          controller.isRecordingBroadcast = false;
          await controller.initializationOfGoLive();
        },
        dispose: (state) {
          Get.find<IsmLiveStreamController>().cameraController?.dispose();
        },
        builder: (controller) => Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: IsmLiveColors.black,
          bottomNavigationBar: Padding(
            padding: IsmLiveDimens.edgeInsets16,
            child: IsmLiveButton(
              label: 'Go Live',
              onTap: !controller.isGoLiveEnabled
                  ? null
                  : () {
                      IsmLiveUtility.openBottomSheet(
                        YourLiveSheet(onTap: controller.startStream),
                      );
                    },
            ),
          ),
          body: Stack(
            alignment: Alignment.center,
            fit: StackFit.loose,
            children: [
              FutureBuilder(
                future: controller.cameraFuture,
                builder: (_, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const IsmLiveLoader(isDialog: false);
                  }
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error while initializing Camera'),
                    );
                  }
                  if (controller.cameraController == null) {
                    return const SizedBox();
                  }
                  return CameraPreview(
                    controller.cameraController!,
                    child: SizedBox(
                      height: Get.height,
                      width: Get.width,
                      child: const ColoredBox(color: Colors.black38),
                    ),
                  );
                },
              ),
              Padding(
                padding: IsmLiveDimens.edgeInsets16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                          icon: SizedBox.shrink(),
                          onPressed: null,
                        ),
                      ],
                    ),
                    IsmLiveDimens.boxHeight20,
                    Row(
                      children: [
                        const _StreamImage(),
                        IsmLiveDimens.boxWidth10,
                        Expanded(
                          child: IsmLiveInputField(
                            hintStyle: IsmLiveStyles.white12,
                            minLines: 3,
                            maxLines: 3,
                            alignLabelWithHint: true,
                            cursorColor: IsmLiveColors.white,
                            style: IsmLiveStyles.white16,
                            borderColor: IsmLiveColors.white,
                            fillColor: IsmLiveColors.white.withOpacity(0.3),
                            controller: controller.descriptionController,
                            hintText: 'Enter description',
                            onchange: (_) {
                              controller.update([updateId]);
                            },
                          ),
                        ),
                      ],
                    ),
                    IsmLiveDimens.boxHeight32,
                    IsmLiveRadioListTile(
                      title: 'HD Broadcast',
                      onChange: controller.onChangeHdBroadcast,
                      value: controller.isHdBroadcast,
                    ),
                    IsmLiveDimens.boxHeight10,
                    IsmLiveRadioListTile(
                      title: 'Record Broadcast',
                      onChange: controller.onChangeRecording,
                      value: controller.isRecordingBroadcast,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _StreamImage extends StatelessWidget {
  const _StreamImage();

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: IsmGoLiveView.updateId,
        builder: (controller) => Container(
          height: IsmLiveDimens.hundred,
          width: IsmLiveDimens.eighty,
          decoration: BoxDecoration(
            color: IsmLiveColors.white.withOpacity(0.3),
            border: Border.all(color: IsmLiveColors.white),
            borderRadius: BorderRadius.circular(IsmLiveDimens.twelve),
          ),
          clipBehavior: Clip.antiAlias,
          child: controller.pickedImage == null || controller.pickedImage!.path.isNullOrEmpty
              ? IsmLiveTapHandler(
                  onTap: () {
                    IsmLiveUtility.openBottomSheet(
                      PickImageSheet(
                        beforePicking: () async {
                          await controller.cameraController?.dispose();
                          controller.cameraController = null;
                        },
                        afterPicking: (file) {
                          if (file != null) {
                            controller.pickedImage = file;
                            controller.update([IsmGoLiveView.updateId]);
                          }
                          controller.initializationOfGoLive();
                        },
                      ),
                    );
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.add,
                        color: IsmLiveColors.white,
                      ),
                      IsmLiveDimens.boxHeight10,
                      Text(
                        'Add Cover',
                        style: IsmLiveStyles.white12,
                      ),
                    ],
                  ),
                )
              : Stack(
                  fit: StackFit.expand,
                  children: [
                    IsmLiveImage.file(
                      controller.pickedImage!.path,
                      isProfileImage: false,
                      radius: IsmLiveDimens.twelve,
                    ),
                    Positioned(
                      right: -IsmLiveDimens.ten,
                      top: -IsmLiveDimens.ten,
                      child: IconButton(
                        icon: Icon(
                          Icons.close,
                          size: IsmLiveDimens.twenty,
                          color: IsmLiveColors.white,
                        ),
                        onPressed: () {
                          controller.pickedImage = null;
                          controller.update([IsmGoLiveView.updateId]);
                        },
                      ),
                    ),
                  ],
                ),
        ),
      );
}
