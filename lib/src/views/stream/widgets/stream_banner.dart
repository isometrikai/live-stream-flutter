import 'dart:ui';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveStreamBanner extends StatelessWidget {
  const IsmLiveStreamBanner(
    this.streamImage, {
    super.key,
    this.isSchedule = false,
  });

  final String? streamImage;
  final bool isSchedule;

  static int? _coverMemCacheWidth(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (!width.isFinite || width <= 0) {
      return null;
    }
    return (width * MediaQuery.devicePixelRatioOf(context)).round();
  }

  static int? _coverMemCacheHeight(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    if (!height.isFinite || height <= 0) {
      return null;
    }
    return (height * MediaQuery.devicePixelRatioOf(context)).round();
  }

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        builder: (controller) {
          final networkUrl = streamImage?.trim();
          final hasNetworkUrl = networkUrl != null && networkUrl.isNotEmpty;
          final memCacheWidth = _coverMemCacheWidth(context);
          final memCacheHeight = _coverMemCacheHeight(context);

          return SizedBox(
            height: MediaQuery.sizeOf(context).height,
            width: MediaQuery.sizeOf(context).width,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: isSchedule ? 0 : 10,
                sigmaY: isSchedule ? 0 : 10,
              ),
              child: hasNetworkUrl
                  ? IsmLiveImage.network(
                      networkUrl,
                      name: 'U',
                      isCoverImage: true,
                      showError: false,
                      memCacheWidth: memCacheWidth,
                      memCacheHeight: memCacheHeight,
                    )
                  : controller.pickedImage != null
                      ? IsmLiveImage.file(
                          controller.pickedImage!.path,
                        )
                      : ColoredBox(
                          color: context.liveTheme?.secondaryColor
                                  ?.withValues(alpha: 0.35) ??
                              IsmLiveColors.secondary.withValues(alpha: 0.35),
                        ),
            ),
          );
        },
      );
}

