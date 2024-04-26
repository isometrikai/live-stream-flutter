import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveStreamHeader extends StatelessWidget {
  const IsmLiveStreamHeader({
    super.key,
    required this.name,
    required this.imageUrl,
    this.onTapExit,
    this.onTapViewers,
    this.onTapModerators,
    required this.description,
    required this.pk,
  });

  final String name;
  final String description;
  final String imageUrl;
  final bool pk;

  final Function()? onTapExit;
  final void Function(List<IsmLiveViewerModel>)? onTapViewers;
  final Function()? onTapModerators;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IsmLiveDimens.boxWidth10,
              IsmLiveHostDetail(
                imageUrl: imageUrl,
                name: name,
                description: description,
                isHost: Get.find<IsmLiveStreamController>().isHost,
              ),
              IsmLiveDimens.boxWidth10,
              IsmLiveModeratorCount(onTap: onTapModerators),
              IsmLiveDimens.boxWidth10,
              IsmLiveViewerCount(onTap: onTapViewers),
            ],
          ),
          IsmLiveDimens.boxHeight10,
          Padding(
            padding: IsmLiveDimens.edgeInsets10_0,
            child: _LiveTimer(
              onTapModerators: onTapModerators,
            ),
          ),
          IsmLiveDimens.boxHeight8,
          if (pk)
            name.isEmpty
                ? LinearProgressIndicator(
                    minHeight: IsmLiveDimens.ten,
                    backgroundColor: Colors.red,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.blue),
                    value: 0.5,
                  )
                : Container(
                    width: Get.width,
                    color: Colors.purple,
                    height: IsmLiveDimens.twenty,
                    child: Text(
                      'Congratulations to @taavi',
                      style: context.textTheme.bodySmall
                          ?.copyWith(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  )
          else
            Container(
              margin: IsmLiveDimens.edgeInsets10_0,
              width: Get.width * 0.6,
              child: Text(
                description,
                style:
                    context.textTheme.bodySmall?.copyWith(color: Colors.white),
              ),
            ),
        ],
      );
}

class IsmLiveModeratorCount extends StatelessWidget {
  const IsmLiveModeratorCount({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        builder: (controller) => (controller.isMember ||
                (controller.isCopublisher) ||
                (controller.isHost))
            ? IsmLiveTapHandler(
                onTap: onTap,
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
      );
}

class IsmLiveViewerCount extends StatelessWidget {
  const IsmLiveViewerCount({
    super.key,
    this.onTap,
  });

  final void Function(List<IsmLiveViewerModel>)? onTap;

  @override
  Widget build(BuildContext context) => IsmLiveTapHandler(
        onTap: () => onTap?.call(Get.find<IsmLiveStreamController>().streamViewersList),
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
      );
}

class IsmLiveEndStreamButton extends StatelessWidget {
  const IsmLiveEndStreamButton({
    super.key,
    this.onTapExit,
  });

  final VoidCallback? onTapExit;

  @override
  Widget build(BuildContext context) => SafeArea(
        key: key,
        child: Container(
          margin: IsmLiveDimens.edgeInsets10_0,
          child: IsmLiveTapHandler(
            onTap: onTapExit ?? IsmLiveApp.endStream,
            child: const Icon(
              Icons.close,
              color: IsmLiveColors.white,
            ),
          ),
        ),
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
          const IsmLiveLabel(),
          IsmLiveDimens.boxWidth10,
          const IsmLiveStreamTimer(),
          IsmLiveDimens.boxWidth10,
          IsmLiveStreamMemberCount(
            onTap: () => IsmLiveUtility.openBottomSheet(
              const IsmLiveMembersSheet(),
              isScrollController: true,
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

class IsmLiveStreamMemberCount extends StatelessWidget {
  const IsmLiveStreamMemberCount({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => IsmLiveTapHandler(
        onTap: onTap,
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
      );
}

class IsmLiveStreamTimer extends StatelessWidget {
  const IsmLiveStreamTimer({
    super.key,
  });

  @override
  Widget build(BuildContext context) => GetX<IsmLiveStreamController>(
        builder: (controller) => Text(
          controller.streamDuration.formattedTime,
          style: context.textTheme.labelMedium?.copyWith(
            color: IsmLiveColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}

class IsmLiveLabel extends StatelessWidget {
  const IsmLiveLabel({super.key});

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: IsmLiveApp.isMqttConnected
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
      );
}
