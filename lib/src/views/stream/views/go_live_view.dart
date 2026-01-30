import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class IsmGoLiveView extends StatelessWidget {
  const IsmGoLiveView({super.key});

  static const String updateId = 'ismlive-go-live';

  /// Get the appropriate text style for "Add Cover" and similar action text based on configuration
  static TextStyle _getAddCoverTextStyle(BuildContext context) {
    // Check if custom add cover text style is provided in GoLive screen configuration
    final goLiveScreenConfigure = IsmLiveDelegate.goLiveScreenConfigure;
    if (goLiveScreenConfigure?.addCoverTextStyle != null) {
      return goLiveScreenConfigure!.addCoverTextStyle!;
    }

    // Fallback to default style
    return IsmLiveStyles.white12;
  }

  /// Get the appropriate text style based on configuration and theme
  static TextStyle getTextStyle(BuildContext context, bool isDark) {
    // Check if custom radio tile text style is provided in GoLive screen configuration
    final goLiveScreenConfigure = IsmLiveDelegate.goLiveScreenConfigure;
    if (goLiveScreenConfigure?.radioTileTextStyle != null) {
      return goLiveScreenConfigure!.radioTileTextStyle!(context, isDark);
    }

    // Fallback to default style
    return context.dynamicTextTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w400,
          color: isDark ? IsmLiveColors.white : IsmLiveColors.black,
        ) ??
        const TextStyle();
  }

  /// Get the appropriate icon for "Add" actions based on configuration
  static IconData _getAddIcon(BuildContext context) {
    // Check if custom add icon is provided in GoLive screen configuration
    final goLiveScreenConfigure = IsmLiveDelegate.goLiveScreenConfigure;
    if (goLiveScreenConfigure?.addIcon != null) {
      return goLiveScreenConfigure!.addIcon!;
    }

    // Fallback to default icon
    return Icons.add_circle_outline_rounded;
  }

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: updateId,
        initState: (state) {
          var controller = Get.find<IsmLiveStreamController>();

          if (controller.streamDetails == null) {
            controller.cameraFuture = null;
            unawaited(controller.initializationOfGoLive());
            unawaited(controller.userDetails());
            controller.premiumStreamCoinsController.clear();
            controller.selectedGoLiveStream = IsmLiveStreamTypes.free;
            controller.pickedImage = null;
            controller.descriptionController.clear();
            controller.isHdBroadcast = false;
            controller.isRecordingBroadcast = false;
            controller.isSchedulingBroadcast = false;
            controller.isPremium = false;
            controller.isRestreamBroadcast = false;
          } else if (controller.streamDetails?.isScheduledStream ?? false) {
            controller.premiumStreamCoinsController.clear();
            unawaited(controller.initializationOfGoLive());
            controller.selectedGoLiveStream = IsmLiveStreamTypes.free;
            controller.pickedImage = null;
            controller.descriptionController.text =
                controller.streamDetails?.streamDescription ?? '';
            controller.isHdBroadcast =
                controller.streamDetails?.hdBroadcast ?? false;
            controller.isRecordingBroadcast =
                controller.streamDetails?.isRecorded ?? false;
            controller.isSchedulingBroadcast =
                controller.streamDetails?.isScheduledStream ?? false;
            controller.isPremium = false;
            controller.isRestreamBroadcast =
                controller.streamDetails?.restream ?? false;
          }
        },
        dispose: (state) {
          var controller = Get.find<IsmLiveStreamController>();
          // Always clear go-live data when disposing the go-live view
          // This ensures clean state for next time the screen opens
          // controller.streamDispose(
          //     false); // Don't call disposeAnimationController here

          // Store camera controller reference before clearing
          // This prevents the UI from trying to use it during disposal
          final cameraController = controller.cameraController;

          // Clear references immediately to prevent UI from using the camera
          // This is critical for smooth navigation on iOS
          controller.cameraController = null;
          controller.cameraFuture = null;

          // Dispose camera asynchronously in a non-blocking way
          // This prevents UI freezing on iOS during navigation
          if (cameraController != null) {
            unawaited(
              cameraController.dispose().catchError((error) {
                // Log error but don't block navigation
                IsmLiveLog.error('Error disposing camera controller: $error');
              }),
            );
          }

          controller.streamDetails = null;
          controller.pickedImage = null;
          // Call the dispose callback if provided
          IsmLiveDelegate.onGoLiveDispose?.call();
        },
        builder: (controller) => Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: IsmLiveColors.black,
          extendBody: true,
          bottomNavigationBar: const IsmGoLiveNavBar(),
          body: Stack(
            fit: StackFit.loose,
            children: [
              FutureBuilder(
                future: controller.cameraFuture,
                builder: (_, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const IsmLiveLoader(isDialog: false);
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error while initializing Camera',
                        style: context.dynamicTextTheme.bodyLarge?.copyWith(
                          color: IsmLiveColors.white,
                        ),
                      ),
                    );
                  }
                  if (controller.cameraController == null) {
                    return const SizedBox();
                  }

                  final scale = MediaQuery.of(context).size.height /
                      MediaQuery.of(context).size.width;

                  return Transform.scale(
                    scale: scale,
                    child: controller.selectedGoLiveTabItem ==
                            IsmGoLiveTabItem.defaultLive
                        ? CameraPreview(
                            controller.cameraController!,
                            child: SizedBox(
                              height: context.height,
                              width: context.width,
                              child: const ColoredBox(color: Colors.black38),
                            ),
                          )
                        : null,
                  );
                },
              ),
              SingleChildScrollView(
                padding: IsmLiveDimens.edgeInsets16,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IsmLiveDimens.boxHeight32,
                    // Use custom header builder if provided, otherwise use default header
                    IsmLiveDelegate.goLiveHeaderBuilder
                            ?.call(context, controller) ??
                        const _DefaultGoLiveHeader(),
                    if (!(controller.streamDetails?.isScheduledStream ??
                            false) &&
                        (IsmLiveDelegate.paidStream ?? true))
                      const _StreamTypes(),
                    IsmLiveDimens.boxHeight20,
                    Row(
                      children: [
                        const _StreamImage(),
                        IsmLiveDimens.boxWidth10,
                        Expanded(
                          child: Container(
                            height: IsmLiveDimens
                                .hundred, // Fixed height to match _StreamImage
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(IsmLiveDimens.twelve),
                              border: Border.all(color: IsmLiveColors.white),
                              color: IsmLiveColors.white.withOpacity(0.3),
                            ),
                            child: IsmLiveInputField(
                              hintStyle: getTextStyle(context, true),
                              minLines: 4,
                              maxLines: 4,
                              alignLabelWithHint: true,
                              cursorColor: IsmLiveColors.white,
                              style: getTextStyle(context, true),
                              borderColor: Colors
                                  .transparent, // Remove border since Container has it
                              radius: IsmLiveDimens.twelve,
                              fillColor: Colors
                                  .transparent, // Remove fill since Container has it
                              controller: controller.descriptionController,
                              hintText: 'Enter description',
                              onchange: (_) {
                                controller.update([updateId]);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    IsmLiveDimens.boxHeight10,
                    if (IsmLiveDelegate.hdStream ?? true)
                      IsmLiveRadioListTile(
                        title: 'HD Broadcast',
                        onChange: controller.onChangeHdBroadcast,
                        value: controller.isHdBroadcast,
                      ),
                    if (IsmLiveDelegate.recordeStream ?? true)
                      IsmLiveRadioListTile(
                        title: 'Record Broadcast',
                        onChange: controller.onChangeRecording,
                        value: controller.isRecordingBroadcast,
                      ),
                    if (IsmLiveDelegate.restreamStream ?? true)
                      IsmLiveRadioListTile(
                        title: 'Restream Broadcast',
                        onChange: controller.onChangeRestream,
                        value: controller.isRestreamBroadcast,
                      ),
                    if (IsmLiveDelegate.restreamStream ?? true)
                      const _Restream(),
                    if (controller.isRtmp) ...[
                      IsmLiveRadioListTile(
                        title: 'Use Persistent RTMP Stream Key',
                        onChange: controller.onChangePersistent,
                        value: controller.usePersistentStreamKey,
                      ),
                      const _PersistentStream(),
                    ],
                    if (IsmLiveDelegate.productStream ?? true)
                      IsmLiveDelegate.ecomConfigure?.addProductViewBuilder !=
                              null
                          ? IsmLiveDelegate
                              .ecomConfigure!.addProductViewBuilder!(context)
                          : _AddProduct(
                              selectedProducts: controller.selectedProductsList,
                              onRemoveProduct: (index) {
                                controller.selectedProductsList.removeAt(index);
                                controller.update([updateId]);
                              },
                            ),
                    if (IsmLiveDelegate.scheduleStream ?? true)
                      Opacity(
                        opacity:
                            controller.streamDetails?.isScheduledStream ?? false
                                ? 0.5
                                : 1.0,
                        child: IsmLiveRadioListTile(
                          title: 'Schedule Live',
                          onChange: controller
                                      .streamDetails?.isScheduledStream ??
                                  false
                              ? (_) {} // Do nothing when editing scheduled stream
                              : controller.onChangeSchedule,
                          value: controller.isSchedulingBroadcast,
                        ),
                      ),
                    _ScheduleStream(
                      isEditable:
                          !(controller.streamDetails?.isScheduledStream ??
                              false),
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _StreamTypes extends StatelessWidget {
  const _StreamTypes();

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: IsmGoLiveView.updateId,
        builder: (controller) => Row(
          children: IsmLiveStreamTypes.values.map((e) {
            final isSelected = controller.selectedGoLiveStream == e;

            controller.isPremium =
                controller.selectedGoLiveStream == IsmLiveStreamTypes.premium;

            return Expanded(
              child: IsmLiveTapHandler(
                onTap: () {
                  controller.selectedGoLiveStream = e;

                  if (!controller.isPremium) {
                    controller.premiumStreamSheet();
                  }

                  controller.update([IsmGoLiveView.updateId]);
                },
                child: Container(
                  margin: IsmLiveDimens.edgeInsets2,
                  height: IsmLiveDimens.fifty,
                  width: IsmLiveDimens.hundred,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(IsmLiveDimens.eight),
                    border: isSelected
                        ? null
                        : Border.all(color: Colors.white, width: 0.5),
                    color: !isSelected
                        ? Colors.white.withOpacity(0.2)
                        : Colors.black,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (controller.premiumStreamCoinsController.isEmpty &&
                          e == IsmLiveStreamTypes.premium)
                        const Icon(
                          Icons.diamond,
                          color: Colors.white,
                        ),
                      if (controller.premiumStreamCoinsController.isNotEmpty &&
                          e == IsmLiveStreamTypes.premium) ...[
                        const IsmLiveImage.svg(IsmLiveAssetConstants.coinSvg),
                        Text(
                          ' ${controller.premiumStreamCoinsController.text} coins',
                          style: context.dynamicTextTheme.labelLarge?.copyWith(
                            color: !isSelected ? Colors.black : Colors.white,
                          ),
                        ),
                      ] else
                        Text(
                          e.value,
                          style: context.dynamicTextTheme.labelLarge?.copyWith(
                            color: !isSelected ? Colors.black : Colors.white,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
}

class _StreamImage extends StatelessWidget {
  const _StreamImage();

  Future<void> _showCoverPhotoOptions(
    BuildContext context,
    IsmLiveStreamController controller,
  ) async {
    final result = await IsmLiveUtility.openBottomSheet<bool>(
      IsmLiveCoverPhotoOptionsSheet(
        onCameraTap: () async {
          IsmLiveRoute.pop(true); // Pass true to indicate camera was selected
        },
        onGalleryTap: () async {
          IsmLiveRoute.pop(
              false); // Pass false to indicate gallery was selected
        },
      ),
      backgroundColor: IsmLiveColors.white,
    );

    if (result != null) {
      // Store the current camera controller state
      final existingController = controller.cameraController;

      // Dispose the background camera controller before opening camera screen
      // to prevent conflicts
      if (existingController != null &&
          existingController.value.isInitialized) {
        try {
          await existingController.dispose();
          controller.cameraController = null;
          controller.cameraFuture = null;
          controller.update([IsmGoLiveView.updateId]);
          // Wait a bit for camera to be fully released
          await Future.delayed(const Duration(milliseconds: 300));
        } catch (e) {
          IsmLiveLog.error('Error disposing camera controller: $e');
        }
      }

      XFile? file;
      if (result) {
        // Camera was selected
        file = await FileManager.pickCameraImage();
        // Wait for camera_view.dart to fully release the camera before reinitializing
        // This prevents "No cameras available" errors
        await Future.delayed(const Duration(milliseconds: 500));
      } else {
        // Gallery was selected
        file = await FileManager.pickGalleryImage();
      }

      // Reinitialize the background camera preview after returning
      if (file != null) {
        controller.pickedImage = file;
        controller.update([IsmGoLiveView.updateId]);
      }

      // Reinitialize the background camera preview only if controller is null
      // and we're still on the go-live screen
      if (controller.cameraController == null && context.mounted) {
        // Wait a bit more to ensure camera is fully available
        await Future.delayed(const Duration(milliseconds: 200));
        if (context.mounted && controller.cameraController == null) {
          unawaited(controller.initializationOfGoLive());
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: IsmGoLiveView.updateId,
        builder: (controller) => Container(
          width: IsmLiveDimens.eighty,
          height: IsmLiveDimens.hundred, // Fixed height to match input field
          decoration: BoxDecoration(
            color: IsmLiveColors.white.withOpacity(0.3),
            border: Border.all(color: IsmLiveColors.white),
            borderRadius: BorderRadius.circular(IsmLiveDimens.twelve),
          ),
          clipBehavior: Clip.antiAlias,
          child: (controller.streamDetails?.streamImage?.isEmpty ?? true) &&
                  (controller.pickedImage == null ||
                      controller.pickedImage!.path.isNullOrEmpty)
              ? IsmLiveTapHandler(
                  onTap: () => _showCoverPhotoOptions(context, controller),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        IsmGoLiveView._getAddIcon(context),
                        color: IsmLiveColors.white,
                      ),
                      IsmLiveDimens.boxHeight10,
                      Text(
                        'Add Cover',
                        style: IsmGoLiveView._getAddCoverTextStyle(context),
                      ),
                    ],
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(IsmLiveDimens.twelve),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      !(controller.streamDetails?.streamImage?.isEmpty ?? true)
                          ? IsmLiveImage.network(
                              controller.streamDetails?.streamImage ?? '',
                              name: 'U',
                            )
                          : IsmLiveImage.file(
                              controller.pickedImage!.path,
                              isProfileImage: false,
                              radius: IsmLiveDimens.twelve,
                            ),
                      Positioned(
                        right: IsmLiveDimens.two,
                        top: IsmLiveDimens.two,
                        child: InkWell(
                          child: IsmLiveImage.svg(
                            IsmLiveAssetConstants.close_rounded_fill,
                            height: IsmLiveDimens.twenty,
                            width: IsmLiveDimens.twenty,
                          ),
                          onTap: () {
                            controller.streamDetails = controller.streamDetails
                                ?.copyWith(streamImage: '');
                            controller.pickedImage = null;
                            controller.update([IsmGoLiveView.updateId]);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      );
}

class _AddProduct extends StatelessWidget {
  const _AddProduct({
    required this.selectedProducts,
    required this.onRemoveProduct,
  });
  final List<IsmLiveProductModel> selectedProducts;
  final Function(int index) onRemoveProduct;

  @override
  Widget build(BuildContext context) => Padding(
        padding: IsmLiveDimens.edgeInsets10,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add product*',
                  style: context.dynamicTextTheme.bodyMedium?.copyWith(
                    color: IsmLiveColors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (selectedProducts.isNotEmpty)
                  TextButton(
                    onPressed: IsmLiveRouteManagement.goToAddProduct,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.transparent,
                    ),
                    child: Text(
                      '+Add',
                      style: context.dynamicTextTheme.bodyMedium?.copyWith(
                        color: IsmLiveColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            IsmLiveDimens.boxHeight10,
            selectedProducts.isNotEmpty
                ? SizedBox(
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      separatorBuilder: (_, __) => IsmLiveDimens.boxWidth10,
                      itemBuilder: (_, index) {
                        var product = selectedProducts[index];

                        return IsmLiveProductContainer(
                          imageUrl: product.metadata.productImageUrl ?? '',
                          currencyIcon: product.metadata.currencySymbol ?? '',
                          price: product.metadata.price ?? 0,
                          productName: product.productName,
                          productDisc: product.metadata.description ?? '',
                          onPress: () {
                            onRemoveProduct(index);
                          },
                        );
                      },
                      itemCount: selectedProducts.length,
                    ),
                  )
                : IsmLiveTapHandler(
                    onTap: IsmLiveRouteManagement.goToAddProduct,
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: IsmLiveDimens.hundred,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white30,
                          border: Border.all(color: IsmLiveColors.white),
                          borderRadius:
                              BorderRadius.circular(IsmLiveDimens.sixteen),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              IsmGoLiveView._getAddIcon(context),
                              color: IsmLiveColors.white,
                            ),
                            Text(
                              'Add products',
                              style:
                                  IsmGoLiveView._getAddCoverTextStyle(context),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      );
}

class _Restream extends StatelessWidget {
  const _Restream();

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: IsmGoLiveView.updateId,
        builder: (controller) => !controller.isRestreamBroadcast
            ? const SizedBox.shrink()
            : Column(
                children: [
                  const Divider(),
                  IsmLiveDimens.boxHeight5,
                  InkWell(
                    onTap: IsmLiveRouteManagement.goToRestreamView,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Restream',
                          style: IsmGoLiveView.getTextStyle(context, true),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_right_rounded,
                          color: Colors.white,
                        )
                      ],
                    ),
                  ),
                  IsmLiveDimens.boxHeight5,
                  const Divider(),
                ],
              ),
      );
}

class _ScheduleStream extends StatelessWidget {
  const _ScheduleStream({this.isEditable = true});

  final bool isEditable;

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: IsmGoLiveView.updateId,
        builder: (controller) => !controller.isSchedulingBroadcast
            ? const SizedBox.shrink()
            : Opacity(
                opacity: isEditable ? 1.0 : 0.5,
                child: Column(
                  children: [
                    _InputField(
                      label: 'Date & Time*',
                      controller: TextEditingController(
                        text: controller.scheduleLiveDate.formattedDate,
                      ),
                      readOnly: true,
                      onTap: isEditable
                          ? () => controller.onChangeSchedule(true)
                          : null,
                      suffixIcon: isEditable
                          ? const UnconstrainedBox(
                              child: IsmLiveImage.svg(
                                IsmLiveAssetConstants.calendar,
                              ),
                            )
                          : const UnconstrainedBox(
                              child: IsmLiveImage.svg(
                                IsmLiveAssetConstants.calendar,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                    IsmLiveDimens.boxHeight50,
                  ],
                ),
              ),
      );
}

class _PersistentStream extends StatelessWidget {
  const _PersistentStream();

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: IsmGoLiveView.updateId,
        builder: (controller) => !controller.usePersistentStreamKey
            ? const SizedBox.shrink()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InputField(
                    label: 'RTML URL',
                    readOnly: true,
                    controller: controller.rtmlUrlDevice,
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(text: controller.rtmlUrlDevice.text),
                      );
                    },
                    suffixIcon: const Icon(Icons.copy),
                  ),
                  IsmLiveDimens.boxHeight10,
                  _InputField(
                    label: 'Stream Key',
                    hint: 'Key will be generated after you start a new stream',
                    readOnly: true,
                    controller: controller.streamKeyDevice,
                    onTap: () {
                      Clipboard.setData(
                        ClipboardData(text: controller.streamKeyDevice.text),
                      );
                    },
                    suffixIcon: const Icon(Icons.copy),
                  ),
                  IsmLiveDimens.boxHeight10,
                  Text.rich(
                    TextSpan(
                      text:
                          'Please copy and paste the STREAM KEY and the STREAM URL into your RTMP streaming device. \nIf you want to create a new stream key in case you think your key is compromised ',
                      children: [
                        TextSpan(
                          text: 'click here.',
                          style: context.dynamicTextTheme.labelMedium?.copyWith(
                            decoration: TextDecoration.underline,
                            decorationColor: IsmLiveColors.white,
                          ),
                        ),
                      ],
                    ),
                    style: context.dynamicTextTheme.labelMedium?.copyWith(
                      color: IsmLiveColors.white,
                    ),
                  )
                ],
              ),
      );
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.label,
    this.hint,
    required this.controller,
    this.readOnly = false,
    this.suffixIcon,
    this.onTap,
  });

  final String label;
  final String? hint;
  final TextEditingController controller;
  final bool readOnly;
  final Widget? suffixIcon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.dynamicTextTheme.labelLarge?.copyWith(
              color: IsmLiveColors.white,
            ),
          ),
          IsmLiveDimens.boxHeight4,
          IsmLiveInputField(
            controller: controller,
            hintText: hint ?? 'Enter $label',
            hintStyle: context.dynamicTextTheme.labelLarge?.copyWith(
              color: IsmLiveColors.white,
            ),
            style: context.dynamicTextTheme.labelLarge?.copyWith(
              color: IsmLiveColors.white,
            ),
            onTap: onTap,
            readOnly: readOnly,
            fillColor: Colors.white30,
            radius: IsmLiveDimens.twelve,
            borderColor: IsmLiveColors.white,
            suffixIcon: suffixIcon,
          ),
        ],
      );
}

class _DefaultGoLiveHeader extends StatelessWidget {
  const _DefaultGoLiveHeader();

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const IconButton(
            icon: Icon(
              Icons.close,
              color: IsmLiveColors.white,
            ),
            onPressed: IsmLiveRoute.pop,
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
      );
}
