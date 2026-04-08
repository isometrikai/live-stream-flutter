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

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        builder: (controller) => SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: isSchedule ? 0 : 10,
              sigmaY: isSchedule ? 0 : 10,
            ),
            child: streamImage != null
                ? IsmLiveImage.network(
                    streamImage!,
                    name: 'U',
                  )
                : controller.pickedImage != null
                    ? IsmLiveImage.file(
                        controller.pickedImage!.path,
                      )
                    : ColoredBox(
                        color: context.liveTheme?.secondaryColor
                                ?.withValues(alpha: 125 / 255) ??
                            IsmLiveColors.secondary.withValues(alpha: 125 / 255),
                      ),
          ),
        ),
      );
}
