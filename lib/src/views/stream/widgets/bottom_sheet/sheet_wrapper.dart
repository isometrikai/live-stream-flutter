import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveScrollSheet extends StatelessWidget {
  const IsmLiveScrollSheet({
    super.key,
    required this.title,
    required this.itemCount,
    required this.itemBuilder,
    this.showSearchBar = false,
    this.showHeader = true,
    this.hintText,
    this.onchange,
    this.textEditingController,
    this.controller,
    this.trailing,
    this.showCancelIcon = false,
  });

  final String title;
  final bool showSearchBar;
  final bool showCancelIcon;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  final TextEditingController? textEditingController;
  final String? hintText;
  final Function(String)? onchange;
  final ScrollController? controller;
  final Widget? trailing;
  final bool showHeader;

  @override
  Widget build(BuildContext context) => Padding(
        padding: IsmLiveDimens.edgeInsetsT8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showHeader)
              ListTile(
                contentPadding: IsmLiveDimens.edgeInsets16_0,
                leading: Text(
                  title,
                  style: context.textTheme.bodyLarge!
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                trailing: trailing ??
                    CustomIconButton(
                      icon: const Icon(
                        Icons.cancel_rounded,
                        color: IsmLiveColors.grey,
                      ),
                      color: Colors.transparent,
                      onTap: Get.back,
                    ),
              ),
            if (showSearchBar)
              Padding(
                padding: IsmLiveDimens.edgeInsets16_0,
                child: IsmLiveInputField(
                  controller: textEditingController ?? TextEditingController(),
                  hintText: hintText,
                  onchange: onchange,
                ),
              ),
            if (showCancelIcon)
              Padding(
                padding: IsmLiveDimens.edgeInsets16_08_16_0,
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: CustomIconButton(
                    icon: const IsmLiveImage.svg(
                      IsmLiveAssetConstants.cancel,
                    ),
                    color: Colors.transparent,
                    onTap: Get.back,
                  ),
                ),
              ),
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                controller: controller,
                itemCount: itemCount,
                itemBuilder: itemBuilder,
                separatorBuilder: (context, index) => IsmLiveDimens.box0,
              ),
            ),
          ],
        ),
      );
}
