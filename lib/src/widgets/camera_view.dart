import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  CameraController? cameraControllerback;
  var isRecording = false;
  var flash = false;
  var isCameraFront = false;
  Timer? timer;
  var duration = const Duration();
  var _isInitializing = false;
  var _hasError = false;

  @override
  void initState() {
    super.initState();
    startInit();
  }

  Future<void> startInit() async {
    if (_isInitializing || !mounted) return;

    _isInitializing = true;
    _hasError = false;

    try {
      // Wait for cameras to be initialized if they're still loading
      if (IsmLiveUtility.camerasInitializationFuture != null) {
        await IsmLiveUtility.camerasInitializationFuture;
      }

      // Check if cameras are available
      if (IsmLiveUtility.cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _hasError = true;
            _isInitializing = false;
          });
        }
        return;
      }

      // Use front camera (index 1) if available, otherwise use back camera (index 0)
      final cameraIndex = IsmLiveUtility.cameras.length > 1 ? 1 : 0;
      isCameraFront = cameraIndex == 1;

      cameraControllerback = CameraController(
        IsmLiveUtility.cameras[cameraIndex],
        ResolutionPreset.ultraHigh,
        imageFormatGroup: ImageFormatGroup.yuv420,
        enableAudio: true,
      );

      await cameraControllerback!.initialize();
      flash = false;
      await cameraControllerback!.setFlashMode(FlashMode.off);

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      IsmLiveLog.error('Failed to initialize camera: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isInitializing = false;
        });
      }
      cameraControllerback?.dispose();
      cameraControllerback = null;
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    _disposeCamera();
    super.dispose();
  }

  void _disposeCamera() {
    if (cameraControllerback != null) {
      if (cameraControllerback!.value.isInitialized) {
        cameraControllerback!.dispose();
      }
      cameraControllerback = null;
    }
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
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              color: Colors.black,
            ),
            Center(
              child: _hasError
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to initialize camera',
                          style: IsmLiveStyles.white12.copyWith(
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _hasError = false;
                            });
                            startInit();
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    )
                  : cameraControllerback?.value.isInitialized == true
                      ? SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.7,
                          child: CameraPreview(cameraControllerback!),
                        )
                      : const CircularProgressIndicator.adaptive(),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: IsmLiveDimens.edgeInsets16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: IsmLiveRoute.pop,
                        child: Container(
                          height: IsmLiveDimens.forty,
                          width: IsmLiveDimens.forty,
                          alignment: Alignment.center,
                          child: SvgPicture.asset(
                            IsmLiveAssetConstants.backRounded,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      if (!isCameraFront &&
                          cameraControllerback?.value.isInitialized == true)
                        InkWell(
                          onTap: () async {
                            if (cameraControllerback?.value.isInitialized !=
                                true) return;
                            try {
                              await cameraControllerback!.setFlashMode(
                                flash ? FlashMode.off : FlashMode.torch,
                              );
                              if (mounted) {
                                setState(() {
                                  flash = !flash;
                                });
                              }
                            } catch (e) {
                              IsmLiveLog.error('Failed to toggle flash: $e');
                            }
                          },
                          child: Container(
                            height: IsmLiveDimens.forty,
                            width: IsmLiveDimens.forty,
                            alignment: Alignment.center,
                            child: Icon(
                              flash ? Icons.flash_on : Icons.flash_off,
                              color: IsmLiveColors.white,
                              size: 24,
                            ),
                          ),
                        ),
                    ],
                  ),
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

                            IsmLiveRoute.pop<XFile>(
                                XFile(pickedFile.files.first.path ?? ''));
                          },
                          child: Container(
                            height: IsmLiveDimens.forty,
                            width: IsmLiveDimens.forty,
                            alignment: Alignment.center,
                            child: SvgPicture.asset(
                              IsmLiveAssetConstants.galerryRoundedSvg,
                              width: 45,
                              height: 45,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                Icons.photo_library,
                                color: Colors.white,
                                size: 45,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: cameraControllerback?.value.isInitialized !=
                                  true
                              ? null
                              : widget.isPhotoRequired
                                  ? () async {
                                      if (cameraControllerback
                                              ?.value.isInitialized !=
                                          true) return;
                                      try {
                                        final picture =
                                            await cameraControllerback!
                                                .takePicture();
                                        if (mounted) {
                                          IsmLiveRoute.pop<XFile>(picture);
                                        }
                                      } catch (e) {
                                        IsmLiveLog.error(
                                            'Failed to take picture: $e');
                                      }
                                    }
                                  : () async {
                                      if (cameraControllerback
                                              ?.value.isInitialized !=
                                          true) return;
                                      try {
                                        if (isRecording) {
                                          isRecording = false;
                                          timer?.cancel();
                                          if (mounted) {
                                            setState(() {});
                                          }
                                          final recording =
                                              await cameraControllerback!
                                                  .stopVideoRecording();
                                          if (mounted) {
                                            IsmLiveRoute.pop<XFile>(recording);
                                          }
                                        } else {
                                          await cameraControllerback!
                                              .startVideoRecording();
                                          if (mounted) {
                                            setState(() {
                                              isRecording = true;
                                            });
                                            startTimer();
                                          }
                                        }
                                      } catch (e) {
                                        IsmLiveLog.error(
                                            'Failed to record video: $e');
                                        if (mounted) {
                                          setState(() {
                                            isRecording = false;
                                          });
                                        }
                                        timer?.cancel();
                                      }
                                    },
                          onLongPressStart: (_) {
                            if (widget.isOnlyImage ||
                                cameraControllerback?.value.isInitialized !=
                                    true) return;
                            cameraControllerback!.startVideoRecording().then(
                              (value) {
                                if (mounted) {
                                  setState(() {
                                    isRecording = true;
                                  });
                                  startTimer();
                                }
                              },
                            ).catchError((e) {
                              IsmLiveLog.error(
                                  'Failed to start video recording: $e');
                            });
                          },
                          onLongPressEnd: (_) {
                            if (widget.isOnlyImage ||
                                cameraControllerback?.value.isInitialized !=
                                    true) return;
                            timer?.cancel();
                            if (mounted) {
                              setState(() {});
                            }
                            cameraControllerback!.stopVideoRecording().then(
                              (value) {
                                if (mounted) {
                                  IsmLiveRoute.pop<XFile>(value);
                                }
                              },
                            ).catchError((e) {
                              IsmLiveLog.error(
                                  'Failed to stop video recording: $e');
                            });
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
                            if (IsmLiveUtility.cameras.length < 2) return;
                            if (_isInitializing) return;

                            _isInitializing = true;

                            try {
                              // Stop any ongoing recording
                              if (isRecording) {
                                timer?.cancel();
                                await cameraControllerback
                                    ?.stopVideoRecording();
                                isRecording = false;
                              }

                              // Dispose old controller
                              _disposeCamera();

                              // Switch camera
                              final cameraPos = isCameraFront ? 0 : 1;
                              isCameraFront = !isCameraFront;

                              cameraControllerback = CameraController(
                                IsmLiveUtility.cameras[cameraPos],
                                ResolutionPreset.high,
                                imageFormatGroup: ImageFormatGroup.yuv420,
                                enableAudio: true,
                              );

                              await cameraControllerback!.initialize();
                              flash = false;
                              await cameraControllerback!
                                  .setFlashMode(FlashMode.off);

                              if (mounted) {
                                setState(() {
                                  _isInitializing = false;
                                });
                              }
                            } catch (e) {
                              IsmLiveLog.error('Failed to switch camera: $e');
                              _disposeCamera();
                              if (mounted) {
                                setState(() {
                                  _hasError = true;
                                  _isInitializing = false;
                                });
                              }
                            }
                          },
                          child: Container(
                            height: IsmLiveDimens.forty,
                            width: IsmLiveDimens.forty,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: IsmLiveColors.white.withOpacity(.3),
                            ),
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: 45,
                              height: 45,
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: SvgPicture.asset(
                                  IsmLiveAssetConstants.switchCameraSvg,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Icon(
                                    Icons.flip_camera_ios,
                                    color: Colors.white,
                                    size: 45,
                                  ),
                                ),
                              ),
                            ),
                          ),
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
