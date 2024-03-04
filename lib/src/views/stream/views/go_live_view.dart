import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmGoLiveView extends StatelessWidget {
  const IsmGoLiveView({super.key});

  static const String updateId = 'ismlive-go-live';

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: updateId,
        initState: (state) async {
          var controller = Get.find<IsmLiveStreamController>();
          controller.cameraFuture = null;
          unawaited(controller.initializationOfGoLive());
          controller.pickedImage = null;
          controller.descriptionController.clear();
          controller.isHdBroadcast = false;
          controller.isRecordingBroadcast = false;
        },
        dispose: (state) {
          Get.find<IsmLiveStreamController>().cameraController?.dispose();
        },
        builder: (controller) => Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: IsmLiveColors.black,
          extendBody: true,
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: IsmLiveDimens.edgeInsets16,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: IsmLiveColors.red,
                  borderRadius: BorderRadius.circular(IsmLiveDimens.twentyFive),
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
                      onTap: controller.startStream,
                    ),
                  ],
                ),
              ),
            ),
          ),
          body: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
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
                  return Transform.scale(
                    scale: controller.cameraController?.value.aspectRatio ?? 1,
                    child: CameraPreview(
                      controller.cameraController!,
                      child: SizedBox(
                        height: Get.height,
                        width: Get.width,
                        child: const ColoredBox(color: Colors.black38),
                      ),
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
                            radius: IsmLiveDimens.twelve,
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
                    IsmLiveDimens.boxHeight10,
                    IsmLiveRadioListTile(
                      title: 'HD Broadcast',
                      onChange: controller.onChangeHdBroadcast,
                      value: controller.isHdBroadcast,
                    ),
                    IsmLiveRadioListTile(
                      title: 'Record Broadcast',
                      onChange: controller.onChangeRecording,
                      value: controller.isRecordingBroadcast,
                    ),
                    IsmLiveRadioListTile(
                      title: 'Restream Broadcast',
                      onChange: controller.onChangeRestream,
                      value: controller.isRestreamBroadcast,
                    ),
                    const _AddProduct(),
                    IsmLiveRadioListTile(
                      title: 'Schedule Live',
                      onChange: controller.onChangeSchedule,
                      value: controller.isSchedulingBroadcast,
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
          child: controller.pickedImage == null ||
                  controller.pickedImage!.path.isNullOrEmpty
              ? IsmLiveTapHandler(
                  onTap: () async {
                    var file = await FileManager.pickGalleryImage();
                    unawaited(controller.initializationOfGoLive());
                    if (file != null) {
                      controller.pickedImage = file;
                      controller.update([IsmGoLiveView.updateId]);
                    }
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

class _AddProduct extends StatelessWidget {
  const _AddProduct();

  @override
  Widget build(BuildContext context) => Padding(
        padding: IsmLiveDimens.edgeInsets10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Add product*',
              style: context.textTheme.bodyLarge?.copyWith(
                color: IsmLiveColors.white,
              ),
            ),
            IsmLiveDimens.boxHeight5,

            SizedBox(
              height: Get.height * 0.25,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                separatorBuilder: (context, index) => IsmLiveDimens.boxWidth10,
                itemBuilder: (context, index) =>
                    const IsmLiveProductContainer(),
                itemCount: 5,
              ),
            )
            // IsmLiveTapHandler(
            //   onTap: IsmLiveRouteManagement.goToAddProduct,
            //   child: SizedBox(
            //     width: Get.width,
            //     height: IsmLiveDimens.hundred,
            //     child: DecoratedBox(
            //       decoration: BoxDecoration(
            //         color: Colors.white30,
            //         border: Border.all(color: IsmLiveColors.white),
            //         borderRadius: BorderRadius.circular(IsmLiveDimens.sixteen),
            //       ),
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.center,
            //         mainAxisSize: MainAxisSize.min,
            //         mainAxisAlignment: MainAxisAlignment.center,
            //         children: [
            //           Icon(
            //             Icons.add_circle_outline_rounded,
            //             color: context.liveTheme.selectedTextColor,
            //           ),
            //           Text(
            //             'Add products',
            //             style: context.textTheme.labelMedium?.copyWith(
            //               color: context.liveTheme.selectedTextColor,
            //             ),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      );
}
