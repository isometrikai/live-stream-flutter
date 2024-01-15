import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StreamHeader extends StatelessWidget {
  const StreamHeader({
    super.key,
    required this.name,
    required this.imageUrl,
    this.onTabCross,
    this.onTabViewers,
  });

  final String name;
  final String imageUrl;
  final Function()? onTabCross;
  final Function()? onTabViewers;
  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IsmLiveHostDetail(
                imageUrl: imageUrl,
                name: name,
              ),
              IsmLiveDimens.boxHeight10,
              const _LiveTimer(),
            ],
          ),
          IsmLiveDimens.boxWidth16,
          IsmLiveTapHandler(
            onTap: onTabViewers,
            child: const IsmLiveUsersAvatar(),
          ),
          IconButton(
            icon: const Icon(
              Icons.close,
              color: IsmLiveColors.white,
            ),
            onPressed: onTabCross,
          ),
        ],
      );
}

class _LiveTimer extends StatelessWidget {
  const _LiveTimer();

  @override
  Widget build(BuildContext context) => Row(
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: IsmLiveColors.red,
              borderRadius: BorderRadius.circular(IsmLiveDimens.four),
            ),
            child: Padding(
              padding: IsmLiveDimens.edgeInsets8_4,
              child: Text(
                'Live',
                style: context.textTheme.labelSmall?.copyWith(
                  color: IsmLiveColors.white,
                ),
              ),
            ),
          ),
          IsmLiveDimens.boxWidth10,
          GetX<IsmLiveStreamController>(
            builder: (controller) => Text(
              controller.streamDuration.formattedTime,
              style: context.textTheme.labelMedium?.copyWith(
                color: IsmLiveColors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
}
