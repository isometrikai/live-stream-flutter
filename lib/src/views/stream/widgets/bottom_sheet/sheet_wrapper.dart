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
    this.controller,
  });

  final String title;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final IndexedWidgetBuilder? separatorBuilder;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) => Padding(
        padding: IsmLiveDimens.edgeInsetsT8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: IsmLiveDimens.edgeInsets16_0,
              leading: Text(
                title,
                style: context.textTheme.bodyLarge!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              trailing: CustomIconButton(
                icon: const Icon(
                  Icons.cancel_rounded,
                  color: IsmLiveColors.grey,
                ),
                color: Colors.transparent,
                onTap: Get.back,
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
