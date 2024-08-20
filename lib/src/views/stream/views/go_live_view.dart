import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class IsmGoLiveView extends StatelessWidget {
  const IsmGoLiveView({super.key});

  static const String updateId = 'ismlive-go-live';

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: updateId,
        initState: (state) async {
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
            controller.isHdBroadcast = false;
            controller.isRecordingBroadcast = false;
            controller.isSchedulingBroadcast = false;
            controller.isPremium = false;
            controller.isRestreamBroadcast = false;
          }
        },
        dispose: (state) {
          var controller = Get.find<IsmLiveStreamController>();
          if (controller.streamDetails == null) {
            controller.selectedProductsList.clear();
          }
          controller.cameraController?.dispose();
        },
        builder: (controller) => Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: IsmLiveColors.black,
          extendBody: true,
          bottomNavigationBar: const IsmGoLiveNavBar(),
          body: Stack(
            // alignment: Alignment.,
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
                  // final ratio1 = MediaQuery.of(context).size.aspectRatio;
                  final scale = MediaQuery.of(context).size.height /
                      MediaQuery.of(context).size.width;

                  return Transform.scale(
                    scale: scale,
                    child: CameraPreview(
                      controller.cameraController!,
                      child: SizedBox(
                        height: context.height,
                        width: context.width,
                        child: const ColoredBox(color: Colors.black38),
                      ),
                    ),
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
                    const _StreamTypes(),
                    IsmLiveDimens.boxHeight20,
                    Row(
                      children: [
                        const _StreamImage(),
                        IsmLiveDimens.boxWidth10,
                        Expanded(
                          child: IsmLiveInputField(
                            hintStyle: IsmLiveStyles.white16,
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
                    if (!(controller.streamDetails?.isScheduledStream ??
                        false)) ...[
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
                      const _Restream(),
                      if (controller.isRtmp) ...[
                        IsmLiveRadioListTile(
                          title: 'Use Persistent RTMP Stream Key',
                          onChange: controller.onChangePersistent,
                          value: controller.usePersistentStreamKey,
                        ),
                        const _PersistentStream(),
                      ],
                      _AddProduct(
                        selectedProducts: controller.selectedProductsList,
                        onRemoveProduct: (index) {
                          controller.selectedProductsList.removeAt(index);
                          controller.update([updateId]);
                        },
                      ),
                      IsmLiveRadioListTile(
                        title: 'Schedule Live',
                        onChange: controller.onChangeSchedule,
                        value: controller.isSchedulingBroadcast,
                      ),
                      const _ScheduleStream(),
                      const SizedBox(height: 120),
                    ]
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
                          style: context.textTheme.labelLarge?.copyWith(
                            color: !isSelected ? Colors.black : Colors.white,
                          ),
                        ),
                      ] else
                        Text(
                          e.value,
                          style: context.textTheme.labelLarge?.copyWith(
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
          child: (controller.streamDetails?.streamImage?.isEmpty ?? true) &&
                  (controller.pickedImage == null ||
                      controller.pickedImage!.path.isNullOrEmpty)
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
                    !(controller.streamDetails?.streamImage?.isEmpty ?? true)
                        ? IsmLiveImage.network(
                            controller.streamDetails?.streamImage ?? '',
                            name: 'U')
                        : IsmLiveImage.file(
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
                          controller.streamDetails?.copyWith(streamImage: null);
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
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: IsmLiveColors.white,
                  ),
                ),
                if (selectedProducts.isNotEmpty)
                  TextButton(
                    onPressed: IsmLiveRouteManagement.goToAddProduct,
                    child: Text(
                      '+Add',
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: IsmLiveColors.white,
                      ),
                    ),
                  ),
              ],
            ),
            IsmLiveDimens.boxHeight5,
            selectedProducts.isNotEmpty
                ? SizedBox(
                    height: Get.height * 0.2,
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
                      width: Get.width,
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
                              Icons.add_circle_outline_rounded,
                              color: context.liveTheme?.selectedTextColor,
                            ),
                            Text(
                              'Add products',
                              style: context.textTheme.labelMedium?.copyWith(
                                color: context.liveTheme?.selectedTextColor,
                              ),
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
                  ListTile(
                    contentPadding: IsmLiveDimens.edgeInsets0,
                    onTap: IsmLiveRouteManagement.goToRestreamView,
                    title: Text(
                      'Restream',
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: IsmLiveColors.white,
                      ),
                    ),
                    trailing: Icon(
                      Icons.keyboard_arrow_right_rounded,
                      color: context.liveTheme?.selectedTextColor,
                    ),
                  ),
                  const Divider(),
                ],
              ),
      );
}

class _ScheduleStream extends StatelessWidget {
  const _ScheduleStream();

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: IsmGoLiveView.updateId,
        builder: (controller) => !controller.isSchedulingBroadcast
            ? const SizedBox.shrink()
            : _InputField(
                label: 'Date & Time*',
                controller: TextEditingController(
                  text: controller.scheduleLiveDate.formattedDate,
                ),
                readOnly: true,
                onTap: () => controller.onChangeSchedule(true),
                suffixIcon: const UnconstrainedBox(
                  child: IsmLiveImage.svg(
                    IsmLiveAssetConstants.calendar,
                  ),
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
                    const TextSpan(
                      text:
                          'Please copy and paste the STREAM KEY and the STREAM URL into your RTMP streaming device. \nIf you want to create a new stream key in case you think your key is compromised ',
                      children: [
                        TextSpan(
                          text: 'click here.',
                          style: TextStyle(
                            decoration: TextDecoration.underline,
                            decorationColor: IsmLiveColors.white,
                          ),
                        ),
                      ],
                    ),
                    style: context.textTheme.labelMedium?.copyWith(
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
            style: context.textTheme.labelLarge?.copyWith(
              color: IsmLiveColors.white,
            ),
          ),
          IsmLiveDimens.boxHeight4,
          IsmLiveInputField(
            controller: controller,
            hintText: hint ?? 'Enter $label',
            hintStyle: context.textTheme.labelLarge?.copyWith(
              color: IsmLiveColors.white,
            ),
            style: context.textTheme.labelLarge?.copyWith(
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
