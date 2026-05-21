import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

String _formatCompactCount(int value) {
  if (value < 0) return value.toString();
  if (value < 1000) return value.toString();

  String formatUnit(num n, String suffix) {
    // Show 1 decimal only for small numbers (e.g. 1.2k, 9.8k, 1.2m).
    final useOneDecimal = n < 10 && n != n.roundToDouble();
    final s = useOneDecimal ? n.toStringAsFixed(1) : n.round().toString();
    return '$s$suffix';
  }

  if (value < 1000000) {
    final n = value / 1000;
    return formatUnit(n, 'k');
  }
  if (value < 1000000000) {
    final n = value / 1000000;
    return formatUnit(n, 'm');
  }
  final n = value / 1000000000;
  return formatUnit(n, 'b');
}

class IsmLiveStreamHeader extends StatelessWidget {
  const IsmLiveStreamHeader({
    super.key,
    required this.name,
    required this.handle,
    required this.imageUrl,
    this.onTapExit,
    this.onTapViewers,
    this.onTapModerators,
    required this.description,
    required this.pkCompleted,
    required this.isBattleTie,
    this.winnerName,
    required this.streamCoins,
    required this.isPaidStream,
    required this.userIdentifier,
    required this.initials,
  });

  final String name;
  final String handle;
  final bool isPaidStream;
  final String? winnerName;
  final String description;
  final String imageUrl;
  final String streamCoins;
  final String userIdentifier;

  final bool pkCompleted;
  final bool isBattleTie;
  final String initials;
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
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IsmLiveDimens.boxWidth10,
              IsmLiveHostDetail(
                initials: initials,
                imageUrl: IsmLiveDelegate.getUserProfileUrl?.call(imageUrl) ??
                    imageUrl,
                name: name,
                handle: handle,
                description: description,
                isHost: Get.find<IsmLiveStreamController>().isHost,
                userIdentifier: userIdentifier,
              ),
              IsmLiveDimens.boxWidth10,
              IsmLiveModeratorCount(onTap: onTapModerators),
              GetX<IsmLiveStreamController>(
                builder: (c) {
                  if (c.streamViewersDisplayCount <= 0) {
                    return IsmLiveDimens.box0;
                  }
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IsmLiveDimens.boxWidth10,
                      IsmLiveViewerCount(onTap: onTapViewers),
                    ],
                  );
                },
              ),
              IsmLiveDimens.boxWidth10,
              // Cart icon - use custom builder if provided, otherwise use default
              IsmLiveDelegate.cartBuilder?.call(
                    context,
                    Get.find<IsmLiveStreamController>(),
                  ) ??
                  const IsmLiveCartIcon(),
            ],
          ),
          IsmLiveDimens.boxHeight10,
          Padding(
            padding: IsmLiveDimens.edgeInsets10_0,
            child: _LiveTimer(
              streamCoins: streamCoins,
              isPaidStream: isPaidStream,
            ),
          ),
          IsmLiveDimens.boxHeight8,
          if (pkCompleted)
            Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.blue,
              height: IsmLiveDimens.twenty,
              child: Text(
                isBattleTie
                    ? 'Congratulations to @$winnerName'
                    : 'It\'s a Draw!',
                style: context.textTheme.bodySmall?.copyWith(
                    color: Colors.white, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            )
          else
            Container(
              margin: IsmLiveDimens.edgeInsets10_0,
              child: _ExpandableDescription(
                description: description,
                textStyle:
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
        builder: (controller) {
          final isScheduled =
              controller.streamDetails?.isScheduledStream ?? false;
          final streamIdOkForScheduled =
              !isScheduled || IsmLiveStreamId.isValid(controller.streamId);
          final showShield =
              (/*controller.isMember ||
                  (controller.isCopublisher) ||*/
                      (controller.isHost) || (controller.isModerator)) &&
                  !controller.isPk &&
                  streamIdOkForScheduled;
          return showShield
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
              : IsmLiveDimens.box0;
        },
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
        onTap: () =>
            onTap?.call(Get.find<IsmLiveStreamController>().streamViewersList),
        child: Container(
          padding: IsmLiveDimens.edgeInsets4,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(IsmLiveDimens.twelve),
            color: Colors.white24,
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
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
                    _formatCompactCount(controller.streamViewersDisplayCount),
                    style: IsmLiveStyles.white12,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class IsmLiveCartIcon extends StatelessWidget {
  const IsmLiveCartIcon({
    super.key,
    this.onTap,
  });

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        builder: (controller) {
          // Only show cart icon if:
          // 1. User is not host, AND
          // 2. Stream is  productStream
          final shouldShow =
              !controller.isHost && (IsmLiveDelegate.productStream ?? false);

          if (!shouldShow) {
            return IsmLiveDimens.box0;
          }

          return IsmLiveTapHandler(
            onTap: onTap,
            child: Container(
              padding: IsmLiveDimens.edgeInsets4,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white24,
              ),
              child: Icon(
                Icons.shopping_cart_rounded,
                color: IsmLiveColors.white,
                size: IsmLiveDimens.sixteen,
              ),
            ),
          );
        },
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
            onTap: onTapExit,
            child: const Icon(
              Icons.close,
              color: IsmLiveColors.white,
            ),
          ),
        ),
      );
}

class _LiveTimer extends StatelessWidget {
  _LiveTimer({
    required this.streamCoins,
    required this.isPaidStream,
  });
  final String streamCoins;
  final bool isPaidStream;

  final controller = Get.find<IsmLiveStreamController>();

  @override
  Widget build(BuildContext context) {
    final trailingWidget = IsmLiveDelegate
        .streamScreenConfigure.streamHeaderTimerTrailingWidgetBuilder
        ?.call(
      context,
      controller.streamId ?? '',
      controller.isHost,
      streamCoins,
      isPaidStream,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (controller.streamTimer != null) ...[
          const IsmLiveLabel(),
          IsmLiveDimens.boxWidth10,
          const IsmLiveStreamTimer()
        ],
        IsmLiveDimens.boxWidth10,
        // IsmLiveStreamMemberCount(
        //   onTap: () => IsmLiveUtility.openBottomSheet(
        //     const IsmLiveMembersSheet(),
        //     isScrollController: true,
        //   ),
        // ),
        if (isPaidStream) ...[
          IsmLiveDimens.boxWidth10,
          IsmLiveCoins(
            coins: streamCoins,
          ),
        ],
        if (trailingWidget != null) ...[
          IsmLiveDimens.boxWidth10,
          trailingWidget,
        ],
      ],
    );
  }
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

class IsmLiveScheduleStreamTime extends StatelessWidget {
  const IsmLiveScheduleStreamTime({
    super.key,
    this.scheduleTime,
  });
  final DateTime? scheduleTime;

  @override
  Widget build(BuildContext context) => Container(
        padding: IsmLiveDimens.edgeInsets8_4,
        decoration: BoxDecoration(
          color: context.liveTheme?.primaryColor ?? IsmLiveColors.primary,
          borderRadius: BorderRadius.circular(IsmLiveDimens.eight),
        ),
        child: scheduleTime != null
            ? Text(
                scheduleTime!.formattedDate,
                style: context.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                ),
              )
            : null,
      );
}

class IsmLiveLabel extends StatelessWidget {
  const IsmLiveLabel({super.key});

  @override
  Widget build(BuildContext context) => Obx(
        () => DecoratedBox(
          decoration: BoxDecoration(
            color: IsmLiveApp.isMqttConnectedRx.value
                ? IsmLiveColors.green
                : IsmLiveColors.red,
            borderRadius: BorderRadius.circular(IsmLiveDimens.six),
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
      );
}

class _ExpandableDescription extends StatefulWidget {
  const _ExpandableDescription({
    required this.description,
    this.textStyle,
  });

  final String description;
  final TextStyle? textStyle;

  @override
  State<_ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<_ExpandableDescription> {
  bool _isExpanded = false;

  @override
  void didUpdateWidget(_ExpandableDescription oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.description != oldWidget.description ||
        widget.textStyle != oldWidget.textStyle) {
      _isExpanded = false;
    }
  }

  /// True when the description needs more than two lines at [maxWidth].
  bool _textExceedsTwoLines(double maxWidth, BuildContext context) {
    if (widget.description.isEmpty || maxWidth <= 0 || !maxWidth.isFinite) {
      return false;
    }
    final painter = TextPainter(
      text: TextSpan(text: widget.description, style: widget.textStyle),
      textDirection: Directionality.of(context),
      maxLines: 2,
      textScaler: MediaQuery.textScalerOf(context),
      locale: Localizations.maybeLocaleOf(context),
    );
    painter.layout(maxWidth: maxWidth);
    return painter.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) {
          final showToggle =
              _textExceedsTwoLines(constraints.maxWidth, context);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.description,
                style: widget.textStyle,
                maxLines: _isExpanded ? null : 2,
                overflow:
                    _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
              if (showToggle) ...[
                IsmLiveDimens.boxHeight4,
                IsmLiveTapHandler(
                  onTap: () {
                    setState(() {
                      _isExpanded = !_isExpanded;
                    });
                  },
                  child: Text(
                    _isExpanded ? 'View less' : 'View more',
                    style: widget.textStyle?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          );
        },
      );
}
