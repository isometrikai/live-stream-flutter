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
  });

  final String title;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final IndexedWidgetBuilder? separatorBuilder;

  @override
  Widget build(BuildContext context) => Padding(
        padding: IsmLiveDimens.edgeInsets16.copyWith(top: IsmLiveDimens.eight),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: IsmLiveDimens.edgeInsets0,
              leading: Text(
                title,
                style: context.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
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
                itemCount: itemCount,
                itemBuilder: itemBuilder,
                separatorBuilder: separatorBuilder ?? (_, __) => IsmLiveDimens.box0,
              ),
            ),
          ],
        ),
      );
}
