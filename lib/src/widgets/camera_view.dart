import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

/// Camera View Screen

class CameraScreenView extends StatefulWidget {
  const CameraScreenView({
    super.key,
    required this.isPhotoRequired,
    required this.isOnlyImage,
  });

  final bool isPhotoRequired;
  final bool isOnlyImage;
  @override
  State<CameraScreenView> createState() => _CameraScreenViewState();
}

class _CameraScreenViewState extends State<CameraScreenView> {
  late CameraController cameraControllerback;
  var isRecording = false;
  var flash = false;
  var isCameraFront = true;
  Timer? timer;
  var duration = const Duration();

  @override
  void initState() {
    startInit();
    super.initState();
  }

  void startInit() async {
    cameraControllerback = CameraController(
      IsmLiveUtility.cameras[0],
      ResolutionPreset.ultraHigh,
      imageFormatGroup: ImageFormatGroup.yuv420,
      enableAudio: true,
    );
    await cameraControllerback.initialize();
    flash = false;
    await cameraControllerback.setFlashMode(FlashMode.off);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    cameraControllerback.dispose();
    super.dispose();
  }

  void startTimer() async {
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        var seconds = duration.inSeconds + 1;
        duration = Duration(seconds: seconds);
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: cameraControllerback.value.isInitialized
                  ? CameraPreview(cameraControllerback)
                  : const CircularProgressIndicator.adaptive(),
            ),
            Container(
              height: Get.height,
              width: Get.width,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    IsmLiveColors.black.withOpacity(.6),
                    IsmLiveColors.black.withOpacity(.2),
                    IsmLiveColors.black.withOpacity(.2),
                    IsmLiveColors.black.withOpacity(.2),
                    IsmLiveColors.black.withOpacity(.2),
                    IsmLiveColors.black.withOpacity(.6),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: IsmLiveDimens.edgeInsets16,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: Get.back,
                      child: SvgPicture.asset(
                        IsmLiveAssetConstants.backRounded,
                      ),
                    ),
                    if (!isCameraFront)
                      InkWell(
                        onTap: () async {
                          await cameraControllerback.setFlashMode(
                            flash ? FlashMode.off : FlashMode.torch,
                          );
                          flash = !flash;
                          setState(() {});
                        },
                        child: Container(
                          height: IsmLiveDimens.forty,
                          width: IsmLiveDimens.forty,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: IsmLiveColors.white.withOpacity(.3),
                          ),
                          child: Icon(
                            flash ? Icons.flash_on : Icons.flash_off,
                            color: IsmLiveColors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    AnimatedOpacity(
                      opacity: isRecording ? 1 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: Container(
                        padding: IsmLiveDimens.edgeInsets4_8,
                        decoration: BoxDecoration(
                          color: IsmLiveColors.white.withOpacity(.3),
                          borderRadius: BorderRadius.circular(
                            IsmLiveDimens.twelve,
                          ),
                        ),
                        child: Text(
                          IsmLiveUtility.durationToString(duration: duration),
                          style: IsmLiveStyles.white12.copyWith(
                            color: IsmLiveColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    IsmLiveDimens.boxHeight10,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        InkWell(
                          onTap: () async {
                            final allowedExtensions = <String>[];
                            if (widget.isOnlyImage) {
                              allowedExtensions.clear();
                              allowedExtensions.addAll(
                                  List.from(IsmLiveUtility.imageTypeList));
                            } else {
                              allowedExtensions.clear();
                              allowedExtensions.addAll(
                                List.from(IsmLiveUtility.imageTypeList)
                                  ..addAll(
                                      List.from(IsmLiveUtility.videoTypeList)),
                              );
                            }
                            final pickedFile =
                                await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowMultiple: false,
                              allowCompression: true,
                              allowedExtensions: allowedExtensions,
                            );

                            if (pickedFile == null) return;
                            if (pickedFile.files.isEmpty) return;
                            if (pickedFile.files.first.path == null) return;
                            if (pickedFile.files.first.path?.isEmpty == true) {
                              return;
                            }

                            Get.back<XFile>(
                              result: XFile(pickedFile.files.first.path ?? ''),
                            );
                          },
                          child: SvgPicture.asset(
                            IsmLiveAssetConstants.galerryRoundedSvg,
                          ),
                        ),
                        GestureDetector(
                          onTap: widget.isPhotoRequired
                              ? () async {
                                  final picture =
                                      await cameraControllerback.takePicture();
                                  Get.back<XFile>(result: picture);
                                }
                              : () async {
                                  if (isRecording) {
                                    isRecording = false;
                                    timer?.cancel();
                                    setState(() {});
                                    final recording = await cameraControllerback
                                        .stopVideoRecording();
                                    Get.back<XFile>(result: recording);
                                  } else {
                                    await cameraControllerback
                                        .startVideoRecording();
                                    isRecording = true;
                                    startTimer();
                                    setState(() {});
                                  }
                                },
                          onLongPressStart: (_) {
                            if (widget.isOnlyImage) return;
                            cameraControllerback.startVideoRecording().then(
                              (value) {
                                isRecording = true;
                                startTimer();
                                setState(() {});
                              },
                            );
                          },
                          onLongPressEnd: (_) {
                            if (widget.isOnlyImage) return;
                            timer?.cancel();
                            setState(() {});
                            cameraControllerback.stopVideoRecording().then(
                              (value) {
                                Get.back<XFile>(result: value);
                              },
                            );
                          },
                          child: Container(
                            padding: IsmLiveDimens.edgeInsets4,
                            height: IsmLiveDimens.seventy,
                            width: IsmLiveDimens.seventy,
                            decoration: BoxDecoration(
                              color: IsmLiveColors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: IsmLiveColors.white,
                                width: IsmLiveDimens.two,
                              ),
                            ),
                            child: Container(
                              height: IsmLiveDimens.sixty,
                              width: IsmLiveDimens.sixty,
                              decoration: BoxDecoration(
                                color: isRecording
                                    ? IsmLiveColors.black
                                    : IsmLiveColors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            var cameraPos = isCameraFront ? 0 : 1;
                            isCameraFront = !isCameraFront;
                            cameraControllerback = CameraController(
                              IsmLiveUtility.cameras[cameraPos],
                              ResolutionPreset.high,
                            );
                            await cameraControllerback.initialize();
                            setState(() {});
                          },
                          child: SvgPicture.asset(
                              IsmLiveAssetConstants.switchCameraSvg),
                        ),
                      ],
                    ),
                    if (!widget.isOnlyImage)
                      Container(
                        margin: IsmLiveDimens.edgeInsets10_0,
                        padding: IsmLiveDimens.edgeInsets8_4,
                        decoration: BoxDecoration(
                          color: IsmLiveColors.white.withOpacity(.3),
                          borderRadius: BorderRadius.circular(
                            IsmLiveDimens.twelve,
                          ),
                        ),
                        child: Text(
                          isRecording
                              ? 'Tap To End Video'
                              : 'Tap to Start Video',
                          style: IsmLiveStyles.white10.copyWith(fontSize: 12),
                        ),
                      ),
                    IsmLiveDimens.boxHeight32,
                  ],
                ),
              ),
            ),
          ],
        ),
      );
}
