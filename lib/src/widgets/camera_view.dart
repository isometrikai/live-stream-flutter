import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

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

class _CameraScreenViewState extends State<CameraScreenView>
    with WidgetsBindingObserver {
  CameraController? cameraControllerback;
  var isRecording = false;
  var flash = false;
  var isCameraFront = false;
  Timer? timer;
  var duration = const Duration();
  var _isInitializing = false;
  var _hasError = false;
  var _isPermissionDenied = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    startInit();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed || !_isPermissionDenied) {
      return;
    }
    unawaited(_retryIfCameraPermissionGranted());
  }

  Future<void> _retryIfCameraPermissionGranted() async {
    final status = await Permission.camera.status;
    if (!status.isGranted || !mounted) return;
    setState(() {
      _isPermissionDenied = false;
      _hasError = false;
    });
    await startInit();
  }

  bool _isCameraPermissionException(Object e) {
    if (e is! CameraException) return false;
    final code = e.code.toLowerCase();
    return code.contains('accessdenied') || code.contains('permission');
  }

  Future<void> startInit() async {
    if (_isInitializing || !mounted) return;

    _isInitializing = true;
    _hasError = false;
    _isPermissionDenied = false;

    try {
      final permissionStatus = await Permission.camera.request();
      if (!permissionStatus.isGranted) {
        if (mounted) {
          setState(() {
            _isPermissionDenied = true;
            _isInitializing = false;
          });
        }
        return;
      }

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
      // Lock camera orientation to portrait to prevent rotation on iOS
      await cameraControllerback!
          .lockCaptureOrientation(DeviceOrientation.portraitUp);

      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    } catch (e) {
      IsmLiveLog.error('Failed to initialize camera: $e');
      final permissionDenied = _isCameraPermissionException(e) ||
          !(await Permission.camera.status).isGranted;
      if (mounted) {
        setState(() {
          _isPermissionDenied = permissionDenied;
          _hasError = !permissionDenied;
          _isInitializing = false;
        });
      }
      cameraControllerback?.dispose();
      cameraControllerback = null;
    }
  }

  Future<void> _onErrorActionPressed() async {
    if (_isPermissionDenied) {
      // Do not call Permission.camera.request() here — on Android it can hang
      // forever after deny, so settings never open. Open app settings instead.
      final status = await Permission.camera.status;
      if (status.isGranted) {
        if (!mounted) return;
        setState(() {
          _isPermissionDenied = false;
          _hasError = false;
        });
        await startInit();
        return;
      }

      await IsmLiveAppSettings.open();
      return;
    }
    if (!mounted) return;
    setState(() {
      _hasError = false;
      _isPermissionDenied = false;
    });
    await startInit();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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
            if (!(_hasError || _isPermissionDenied))
              cameraControllerback?.value.isInitialized == true
                  ? SafeArea(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: CameraPreview(cameraControllerback!),
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator.adaptive(),
                    ),
            // Decorative only — must not block Turn On / Retry taps underneath.
            IgnorePointer(
              child: Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      IsmLiveColors.black.withValues(alpha: .6),
                      IsmLiveColors.black.withValues(alpha: .2),
                      IsmLiveColors.black.withValues(alpha: .2),
                      IsmLiveColors.black.withValues(alpha: .2),
                      IsmLiveColors.black.withValues(alpha: .2),
                      IsmLiveColors.black.withValues(alpha: .6),
                    ],
                  ),
                ),
              ),
            ),
            if (_hasError || _isPermissionDenied)
              Center(
                child: Padding(
                  padding: IsmLiveDimens.edgeInsets16,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isPermissionDenied
                            ? Icons.no_photography_outlined
                            : Icons.error_outline,
                        color: Colors.white,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _isPermissionDenied
                            ? IsmLiveStrings.cameraPermissionTurnedOff
                            : IsmLiveStrings.errorInitializingCamera,
                        textAlign: TextAlign.center,
                        style: IsmLiveStyles.white12.copyWith(
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _onErrorActionPressed,
                        child: Text(
                          _isPermissionDenied
                              ? IsmLiveStrings.turnOn
                              : IsmLiveStrings.retry,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: IsmLiveDimens.edgeInsets16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ismLiveBuildBackButton(
                        context,
                        color: Colors.white,
                      ),
                      if (!isCameraFront &&
                          cameraControllerback?.value.isInitialized == true)
                        InkWell(
                          onTap: () async {
                            if (cameraControllerback?.value.isInitialized !=
                                true) {
                              return;
                            }
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
            if (!(_hasError || _isPermissionDenied))
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.viewPaddingOf(context).bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedOpacity(
                      opacity: isRecording ? 1 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: Container(
                        padding: IsmLiveDimens.edgeInsets4_8,
                        decoration: BoxDecoration(
                          color: IsmLiveColors.white
                              .withValues(alpha: .3),
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
                              compressionQuality: 100,
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
                            height: IsmLiveDimens.thirtyFive,
                            width: IsmLiveDimens.thirtyFive,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.photo_library,
                              color: Colors.white,
                              size: IsmLiveDimens.thirtyFive,
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
                                          true) {
                                        return;
                                      }
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
                                          true) {
                                        return;
                                      }
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
                                    true) {
                              return;
                            }
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
                                    true) {
                              return;
                            }
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
                            height: IsmLiveDimens.sixty,
                            width: IsmLiveDimens.sixty,
                            decoration: BoxDecoration(
                              color: IsmLiveColors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: IsmLiveColors.white,
                                width: IsmLiveDimens.two,
                              ),
                            ),
                            child: Container(
                              height: IsmLiveDimens.fifty,
                              width: IsmLiveDimens.fifty,
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
                              // Lock camera orientation to portrait to prevent rotation on iOS
                              await cameraControllerback!
                                  .lockCaptureOrientation(
                                      DeviceOrientation.portraitUp);

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
                            height: IsmLiveDimens.thirtyFive,
                            width: IsmLiveDimens.thirtyFive,
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: IsmLiveDimens.thirtyFive,
                              height: IsmLiveDimens.thirtyFive,
                              child: Icon(
                                Icons.flip_camera_ios,
                                color: Colors.white,
                                size: IsmLiveDimens.thirtyFive,
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
                          color: IsmLiveColors.white
                              .withValues(alpha: .3),
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
