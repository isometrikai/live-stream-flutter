import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StreamHeader extends StatelessWidget {
  const StreamHeader({
    super.key,
    required this.name,
    required this.imageUrl,
    this.onTapCross,
    this.onTapViewers,
    this.onTapModerators,
    required this.description,
  });

  final String name;
  final String description;
  final String imageUrl;
  final Function()? onTapCross;
  final Function()? onTapViewers;
  final Function()? onTapModerators;
  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
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
              _LiveTimer(
                onTapModerators: onTapModerators,
              ),
              IsmLiveDimens.boxHeight8,
              SizedBox(
                width: Get.width * 0.7,
                child: Text(
                  description,
                  style: context.textTheme.bodySmall
                      ?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
          const Spacer(),
          GetBuilder<IsmLiveStreamController>(
            builder: (controller) =>
                (controller.isMember || (controller.isCopublisher ?? false))
                    ? IsmLiveTapHandler(
                        onTap: onTapModerators,
                        child: Container(
                          padding: IsmLiveDimens.edgeInsets4,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white24,
                          ),
                          child: Icon(
                            Icons.local_police_rounded,
                            color: IsmLiveColors.white,
                            size: IsmLiveDimens.sixteen,
                          ),
                        ),
                      )
                    : IsmLiveDimens.box0,
          ),
          IsmLiveDimens.boxWidth10,
          IsmLiveTapHandler(
            onTap: onTapViewers,
            child: Container(
              padding: IsmLiveDimens.edgeInsets4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(IsmLiveDimens.twelve),
                color: Colors.white24,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.remove_red_eye,
                    color: IsmLiveColors.white,
                    size: IsmLiveDimens.sixteen,
                  ),
                  IsmLiveDimens.boxWidth4,
                  GetX<IsmLiveStreamController>(
                    builder: (controller) => Text(
                      controller.streamViewersList.length.toString(),
                      style: IsmLiveStyles.white12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // IsmLiveTapHandler(
          //   onTap: onTapViewers,
          //   child: const IsmLiveUsersAvatar(),
          // ),
          Container(
            margin: IsmLiveDimens.edgeInsets10_0,
            child: IsmLiveTapHandler(
              onTap: onTapCross,
              child: const Icon(
                Icons.close,
                color: IsmLiveColors.white,
              ),
            ),
          ),
        ],
      );
}

class _LiveTimer extends StatelessWidget {
  const _LiveTimer({
    this.onTapModerators,
  });

  final Function()? onTapModerators;
  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: Get.find<IsmLiveMqttController>().isConnected
                  ? IsmLiveColors.green
                  : IsmLiveColors.red,
              borderRadius: BorderRadius.circular(IsmLiveDimens.ten),
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

          IsmLiveTapHandler(
            onTap: () => IsmLiveUtility.openBottomSheet(
              const IsmLiveMembersSheet(),
              isScrollController: true,
            ),
            child: Container(
              padding: IsmLiveDimens.edgeInsets4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(IsmLiveDimens.eight),
                color: Colors.black12,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person,
                    color: IsmLiveColors.white,
                    size: IsmLiveDimens.sixteen,
                  ),
                  IsmLiveDimens.boxWidth2,
                  GetX<IsmLiveStreamController>(
                    builder: (controller) => Text(
                      controller.streamMembersList.length.toString(),
                      style: IsmLiveStyles.white12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // IsmLiveDimens.boxWidth8,
          // GetBuilder<IsmLiveStreamController>(
          //   builder: (controller) => (controller.isMember || (controller.isCopublisher ?? false))
          //       ? IsmLiveTapHandler(
          //           onTap: onTapModerators,
          //           child: Container(
          //             padding: IsmLiveDimens.edgeInsets4,
          //             decoration: const BoxDecoration(
          //               shape: BoxShape.circle,
          //               color: Colors.black12,
          //             ),
          //             child: Icon(
          //               Icons.local_police_rounded,
          //               color: IsmLiveColors.white,
          //               size: IsmLiveDimens.sixteen,
          //             ),
          //           ),
          //         )
          //       : IsmLiveDimens.box0,
          // ),
        ],
      );
}
