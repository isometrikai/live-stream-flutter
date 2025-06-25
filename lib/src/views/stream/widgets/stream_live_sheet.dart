import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StreamLiveSheet extends StatelessWidget {
  const StreamLiveSheet({
    super.key,
    this.onTap,
    this.buttonLable,
    required this.title,
    this.subTitle,
    this.widget,
  });
  final VoidCallback? onTap;
  final String? buttonLable;
  final String title;
  final String? subTitle;
  final Widget? widget;
  @override
  Widget build(BuildContext context) => Container(
        width: Get.width,
        padding: IsmLiveDimens.edgeInsets16,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: Get.back,
                icon: const Icon(Icons.close),
              ),
            ),
            widget ?? IsmLiveDimens.box0,
            IsmLiveDimens.boxHeight16,
            Text(
              title,
              style: IsmLiveStyles.blackBold16,
            ),
            if (subTitle != null) ...[
              IsmLiveDimens.boxHeight16,
              Text(
                subTitle ?? '',
                style: IsmLiveStyles.lightGrey14,
                textAlign: TextAlign.center,
              )
            ],
            if (onTap != null && buttonLable != null) ...[
              IsmLiveDimens.boxHeight16,
              IsmLiveButton(
                label: buttonLable!,
                onTap: onTap!,
              ),
            ],
          ],
        ),
      );
}
