import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveScrollSheet extends StatelessWidget {
  const IsmLiveScrollSheet({
    super.key,
    required this.title,
    required this.itemCount,
    required this.itemBuilder,
    this.separatorBuilder,
    this.showSearchBar = false,
    this.showHeader = true,
    this.hintText,
    this.onchange,
    this.textEditingController,
    this.controller,
    this.trailing,
  });

  final String title;
  final bool showSearchBar;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final IndexedWidgetBuilder? separatorBuilder;
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
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                controller: controller,
                padding: IsmLiveDimens.edgeInsets0_8,
                itemCount: itemCount,
                itemBuilder: itemBuilder,
                separatorBuilder:
                    separatorBuilder ?? (_, __) => IsmLiveDimens.box0,
              ),
            ),
          ],
        ),
      );
}
