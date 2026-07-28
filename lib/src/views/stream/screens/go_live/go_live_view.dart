import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class IsmGoLiveView extends StatelessWidget {
  const IsmGoLiveView({super.key});

  static const String updateId = 'ismlive-go-live';
  static const String cameraUpdateId = 'ismlive-go-live-camera';
  static const String buttonUpdateId = 'ismlive-go-live-button';

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

          // Build lightweight placeholder on first frame so transition doesn't stall (see builder).
          controller.goLiveContentReady = false;

          // Ensure stream is marked as inactive to prevent any dialogs from background lifecycle mixin
          // This prevents _showConnectionFailedDialog from showing when navigating from stream_view
          controller.setStreamActive(false, false);

          if (controller.streamDetails == null) {
            controller.cameraFuture = null;
            // Defer heavy camera and user initialization until after the first
            // frame so that the navigation transition stays smooth.
            IsmLiveUtility.updateLater(() {
              unawaited(controller.initializationOfGoLive());
              unawaited(controller.userDetails());
              controller.goLiveContentReady = true;
              controller.update([updateId]);
            });
            controller.premiumStreamCoinsController.clear();
            controller.selectedGoLiveStream = IsmLiveStreamTypes.free;
            controller.pickedImage = null;
            controller.descriptionController.text = IsmLiveDelegate
                    .goLiveScreenConfigure?.defaultBroadcastDescription ??
                IsmLiveDelegate.defaultBroadcastDescription ??
                '';
            controller.isHdBroadcast = IsmLiveDelegate
                    .goLiveScreenConfigure?.defaultHdBroadcastToggleValue ??
                IsmLiveDelegate.defaultHdBroadcast ??
                false;
            controller.isRecordingBroadcast = IsmLiveDelegate
                    .goLiveScreenConfigure?.defaultRecordBroadcastToggleValue ??
                IsmLiveDelegate.defaultRecordBroadcast ??
                false;
            controller.isSchedulingBroadcast = false;
            controller.isPremium = false;
            controller.isRestreamBroadcast = IsmLiveDelegate
                    .goLiveScreenConfigure
                    ?.defaultRestreamBroadcastToggleValue ??
                IsmLiveDelegate.defaultRestreamBroadcast ??
                false;
            controller.selectedVideoEffectPreset =
                IsmLiveVideoEffectPreset.none;
          } else if (controller.streamDetails?.isScheduledStream ?? false) {
            controller.premiumStreamCoinsController.clear();
            controller.cameraFuture = null;
            // Defer camera initialization for scheduled streams as well to
            // avoid blocking the route transition.
            IsmLiveUtility.updateLater(() {
              unawaited(controller.initializationOfGoLive());
              controller.goLiveContentReady = true;
              controller.update([updateId]);
            });
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
          } else {
            // streamDetails != null and not scheduled: still defer full build for smooth transition
            IsmLiveUtility.updateLater(() {
              controller.goLiveContentReady = true;
              controller.update([updateId]);
            });
          }
        },
        dispose: (state) {
          var controller = Get.find<IsmLiveStreamController>();
          // Always clear go-live data when disposing the go-live view
          // This ensures clean state for next time the screen opens
          // controller.streamDispose(
          //     false); // Don't call disposeAnimationController here
          controller.goLiveContentReady = false;

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

          // Defer delegate callback so it doesn't block the frame and leave transition
          final onDispose = IsmLiveDelegate.onGoLiveDispose;
          if (onDispose != null) {
            Future.microtask(onDispose);
          }
        },
        builder: (controller) {
          // First frame: lightweight body so enter transition doesn't stall
          if (!controller.goLiveContentReady) {
            return const Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: IsmLiveColors.black,
              extendBody: true,
              bottomNavigationBar: IsmGoLiveNavBar(),
              body: Center(child: IsmLiveLoader(isDialog: false)),
            );
          }
          return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: IsmLiveColors.black,
            extendBody: true,
            bottomNavigationBar: const IsmGoLiveNavBar(),
            body: Stack(
              fit: StackFit.expand,
              children: [
                const Positioned.fill(
                  child: _CameraPreviewBackground(),
                ),
                SingleChildScrollView(
                  padding: IsmLiveDimens.edgeInsets16,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IsmLiveDimens.boxHeight32,
                      // Use custom header builder if provided, otherwise use default header
                      IsmLiveDelegate.goLiveScreenConfigure?.goLiveHeaderBuilder
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
                                color:
                                    IsmLiveColors.white.withValues(alpha: 0.3),
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
                                hintText: IsmLiveStrings.enterDescription,
                                maxLength: 250,
                                onchange: (_) {
                                  controller.update([buttonUpdateId]);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      IsmLiveDimens.boxHeight10,
                      if (IsmLiveDelegate.hdStream ?? true)
                        IsmLiveRadioListTile(
                          title: IsmLiveStrings.hdBroadcast,
                          onChange: controller.onChangeHdBroadcast,
                          value: controller.isHdBroadcast,
                        ),
                      if (IsmLiveDelegate.recordeStream ?? true)
                        IsmLiveRadioListTile(
                          title: IsmLiveStrings.recordBroadcast,
                          onChange: controller.onChangeRecording,
                          value: controller.isRecordingBroadcast,
                        ),
                      if (IsmLiveDelegate.restreamStream ?? true)
                        IsmLiveRadioListTile(
                          title: IsmLiveStrings.restreamBroadcast,
                          onChange: controller.onChangeRestream,
                          value: controller.isRestreamBroadcast,
                        ),
                      if (IsmLiveDelegate.restreamStream ?? true)
                        const _Restream(),
                      if (controller.hasBuiltInVideoEffects) ...[
                        IsmLiveRadioListTile(
                          title: 'Video Effects',
                          value: controller.selectedVideoEffectPreset !=
                              IsmLiveVideoEffectPreset.none,
                          onChange: (enabled) async {
                            if (!enabled) {
                              await controller.selectVideoEffectPreset(
                                IsmLiveVideoEffectPreset.none,
                              );
                              return;
                            }
                            controller.videoEffectsSheet();
                          },
                        ),
                        const _VideoEffectsDetails(),
                      ],
                      if (controller.isRtmp) ...[
                        IsmLiveRadioListTile(
                          title: IsmLiveStrings.usePersistentRtmpStreamKey,
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
                                selectedProducts:
                                    controller.selectedProductsList,
                                onRemoveProduct: (index) {
                                  controller.selectedProductsList
                                      .removeAt(index);
                                  controller.update([updateId]);
                                },
                              ),
                      if (IsmLiveDelegate.scheduleStream ?? true)
                        Opacity(
                          opacity:
                              controller.streamDetails?.isScheduledStream ??
                                      false
                                  ? 0.5
                                  : 1.0,
                          child: IsmLiveRadioListTile(
                            title: IsmLiveStrings.scheduleLive,
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
                      SizedBox(height: IsmLiveDimens.twoHundred),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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
                        ? Colors.white.withValues(alpha: 0.2)
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
                          ' ${IsmLiveStrings.coinsCountFormat(controller.premiumStreamCoinsController.text)}',
                          style: context.dynamicTextTheme.labelLarge?.copyWith(
                            color: !isSelected ? Colors.black : Colors.white,
                          ),
                        ),
                      ] else
                        Text(
                          e.label,
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
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
      backgroundColor: context.liveTheme?.backgroundColor ??
          (isDarkMode ? const Color(0xFF121212) : Colors.white),
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
          controller.update([IsmGoLiveView.cameraUpdateId]);
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
            color: IsmLiveColors.white.withValues(alpha: 0.3),
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
                        IsmLiveStrings.addCover,
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
                  IsmLiveStrings.addProductRequired,
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
                      IsmLiveStrings.addPlus,
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
                              IsmLiveStrings.addProductsAction,
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
                          IsmLiveStrings.reStream,
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
                      label: IsmLiveStrings.dateAndTimeRequired,
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
                    label: IsmLiveStrings.rtmlUrl,
                    readOnly: true,
                    controller: controller.rtmlUrlDevice,
                    onTap: () => IsmLiveUtility.copyToClipboard(
                      controller.rtmlUrlDevice.text,
                    ),
                    suffixIcon: Icon(
                      Icons.copy,
                      color: IsmGoLiveView.getTextStyle(context, true).color,
                    ),
                  ),
                  IsmLiveDimens.boxHeight10,
                  _InputField(
                    label: IsmLiveStrings.streamKey,
                    hint: IsmLiveStrings.streamKeyHint,
                    readOnly: true,
                    controller: controller.streamKeyDevice,
                    onTap: () => IsmLiveUtility.copyToClipboard(
                      controller.streamKeyDevice.text,
                    ),
                    suffixIcon: Icon(
                      Icons.copy,
                      color: IsmGoLiveView.getTextStyle(context, true).color,
                    ),
                  ),
                  IsmLiveDimens.boxHeight10,
                  Text.rich(
                    TextSpan(
                      text: IsmLiveStrings.persistentRtmpStreamInstruction,
                      children: [
                        TextSpan(
                          text: IsmLiveStrings.clickHere,
                          style: IsmGoLiveView.getTextStyle(context, true)
                              .copyWith(
                            decoration: TextDecoration.underline,
                            decorationColor:
                                IsmGoLiveView.getTextStyle(context, true).color,
                          ),
                        ),
                      ],
                    ),
                    style: IsmGoLiveView.getTextStyle(context, true),
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
  Widget build(BuildContext context) {
    final fieldTextStyle = IsmGoLiveView.getTextStyle(context, true);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: fieldTextStyle,
        ),
        IsmLiveDimens.boxHeight4,
        IsmLiveInputField(
          controller: controller,
          hintText: hint ?? IsmLiveStrings.enterFieldFormat(label),
          hintStyle: fieldTextStyle.copyWith(
            color: fieldTextStyle.color?.withValues(alpha: 0.7),
          ),
          style: fieldTextStyle,
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
}

class _CameraPreviewBackground extends StatelessWidget {
  const _CameraPreviewBackground();

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: IsmGoLiveView.cameraUpdateId,
        builder: (controller) => RepaintBoundary(
          child: FutureBuilder(
            future: controller.cameraFuture,
            builder: (_, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const IsmLiveLoader(isDialog: false);
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    IsmLiveStrings.errorInitializingCamera,
                    style: context.dynamicTextTheme.bodyLarge?.copyWith(
                      color: IsmLiveColors.white,
                    ),
                  ),
                );
              }
              if (controller.cameraController == null) {
                return const SizedBox();
              }

              return controller.selectedGoLiveTabItem ==
                      IsmGoLiveTabItem.defaultLive
                  ? FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: controller
                            .cameraController!.value.previewSize!.height,
                        height: controller
                            .cameraController!.value.previewSize!.width,
                        child: CameraPreview(
                          controller.cameraController!,
                          child: const ColoredBox(color: Colors.black38),
                        ),
                      ),
                    )
                  : const SizedBox();
            },
          ),
        ),
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
            IsmLiveStrings.goLive,
            style: IsmLiveStyles.whiteBold16,
          ),
          const IconButton(
            icon: SizedBox.shrink(),
            onPressed: null,
          ),
        ],
      );
}

class _VideoEffectsDetails extends StatelessWidget {
  const _VideoEffectsDetails();

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: IsmGoLiveView.updateId,
        builder: (controller) {
          if (controller.selectedVideoEffectPreset ==
              IsmLiveVideoEffectPreset.none) {
            return const SizedBox.shrink();
          }
          return Column(
            children: [
              const Divider(),
              IsmLiveDimens.boxHeight5,
              InkWell(
                onTap: controller.videoEffectsSheet,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      controller.currentVideoEffectLabel,
                      style: IsmGoLiveView.getTextStyle(context, true),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_right_rounded,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              IsmLiveDimens.boxHeight5,
              const Divider(),
            ],
          );
        },
      );
}
