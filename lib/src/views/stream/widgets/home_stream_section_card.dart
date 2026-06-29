import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

enum IsmLiveHomeStreamCardStyle {
  scheduled,
  live,
  pk,
  restream,
  recorded,
}

Color _homeScheduledBadgeBackground(Color primaryColor) => Color.alphaBlend(
      primaryColor.withValues(alpha: 0.72),
      Colors.black.withValues(alpha: 0.55),
    );

Color _homeViewerBadgeBackground(Color primaryColor) =>
    primaryColor.withValues(alpha: 0.42);

Color _homeCoinBadgeBackground() => Colors.black.withValues(alpha: 0.45);

class IsmLiveHomeStreamSectionCard extends StatelessWidget {
  const IsmLiveHomeStreamSectionCard({
    super.key,
    required this.stream,
    required this.style,
    this.onTap,
    this.isCreatedByMe = false,
  });

  final IsmLiveStreamDataModel stream;
  final IsmLiveHomeStreamCardStyle style;
  final VoidCallback? onTap;
  final bool isCreatedByMe;

  static const double cardWidth = 140;
  static const double cardHeight = 200;

  @override
  Widget build(BuildContext context) {
    final primaryColor =
        context.liveTheme?.primaryColor ?? IsmLiveColors.primary;

    return IsmLiveTapHandler(
      onTap: onTap,
      child: SizedBox(
        width: IsmLiveDimens.hundredFourty,
        height: IsmLiveDimens.twoHundred,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(IsmLiveDimens.sixteen),
            color: context.liveTheme?.cardBackgroundColor ?? Colors.black,
            image: DecorationImage(
              image: CachedNetworkImageProvider(stream.streamImage ?? ''),
              fit: BoxFit.cover,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              const SizedBox.expand(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black45,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: IsmLiveDimens.eight,
                left: IsmLiveDimens.eight,
                right: style == IsmLiveHomeStreamCardStyle.pk
                    ? IsmLiveDimens.forty
                    : IsmLiveDimens.eight,
                child: _TopBadges(
                  stream: stream,
                  style: style,
                  primaryColor: primaryColor,
                ),
              ),
              if (style == IsmLiveHomeStreamCardStyle.pk)
                Positioned(
                  top: IsmLiveDimens.eight,
                  right: IsmLiveDimens.eight,
                  child: _PkBadge(),
                ),
              if ((stream.isPaid ?? false) &&
                  !(stream.isBuy ?? stream.alreadyPaid ?? false))
                Center(
                  child: _PaidBadge(
                    amount: stream.amount ?? stream.paymentAmount ?? 0,
                  ),
                ),
              Positioned(
                left: IsmLiveDimens.eight,
                right: IsmLiveDimens.eight,
                bottom: IsmLiveDimens.eight,
                child: _UserInfo(stream: stream),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBadges extends StatelessWidget {
  const _TopBadges({
    required this.stream,
    required this.style,
    required this.primaryColor,
  });

  final IsmLiveStreamDataModel stream;
  final IsmLiveHomeStreamCardStyle style;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case IsmLiveHomeStreamCardStyle.scheduled:
        final scheduleTime =
            stream.scheduleStartTime ?? stream.startDateTime;
        if (scheduleTime == null) {
          return const SizedBox.shrink();
        }
        return _BadgePill(
          backgroundColor: _homeScheduledBadgeBackground(primaryColor),
          icon: Icons.access_time,
          label: scheduleTime.scheduleBadgeLabel,
        );
      case IsmLiveHomeStreamCardStyle.live:
        return Wrap(
          spacing: IsmLiveDimens.four,
          runSpacing: IsmLiveDimens.four,
          children: [
            const _BadgePill(
              backgroundColor: Colors.red,
              label: 'LIVE',
            ),
            _BadgePill(
              backgroundColor: _homeViewerBadgeBackground(primaryColor),
              icon: Icons.person_outline,
              label: '${stream.viewersCount ?? 0}',
            ),
          ],
        );
      case IsmLiveHomeStreamCardStyle.pk:
        return _BadgePill(
          backgroundColor: _homeViewerBadgeBackground(primaryColor),
          icon: Icons.person_outline,
          label: '${stream.viewersCount ?? 0}',
        );
      case IsmLiveHomeStreamCardStyle.restream:
        return Wrap(
          spacing: IsmLiveDimens.four,
          runSpacing: IsmLiveDimens.four,
          children: [
            _BadgePill(
              backgroundColor: _homeViewerBadgeBackground(primaryColor),
              icon: Icons.person_outline,
              label: '${stream.viewersCount ?? 0}',
            ),
            if ((stream.isPaid ?? false) ||
                (stream.paymentAmount ?? stream.amount ?? 0) > 0)
              _BadgePill(
                backgroundColor: _homeCoinBadgeBackground(),
                iconWidget: const IsmLiveImage.svg(
                  IsmLiveAssetConstants.coinSvg,
                  height: 12,
                  width: 12,
                ),
                label:
                    '${stream.paymentAmount ?? stream.amount ?? stream.coinsCount ?? 0}',
              ),
          ],
        );
      case IsmLiveHomeStreamCardStyle.recorded:
        return const SizedBox.shrink();
    }
  }
}

class _BadgePill extends StatelessWidget {
  const _BadgePill({
    required this.backgroundColor,
    required this.label,
    this.icon,
    this.iconWidget,
  });

  final Color backgroundColor;
  final String label;
  final IconData? icon;
  final Widget? iconWidget;

  @override
  Widget build(BuildContext context) => Container(
        padding: IsmLiveDimens.edgeInsets8_4,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(IsmLiveDimens.twenty),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconWidget != null) ...[
              iconWidget!,
              IsmLiveDimens.boxWidth4,
            ] else if (icon != null) ...[
              Icon(
                icon,
                size: IsmLiveDimens.twelve,
                color: IsmLiveColors.white,
              ),
              IsmLiveDimens.boxWidth4,
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: IsmLiveColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
}

class _PkBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        width: IsmLiveDimens.twentyFour,
        height: IsmLiveDimens.twentyFour,
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          color: IsmLiveColors.green,
          shape: BoxShape.circle,
        ),
        child: Text(
          'PK',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: IsmLiveColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      );
}

class _PaidBadge extends StatelessWidget {
  const _PaidBadge({required this.amount});

  final num amount;

  @override
  Widget build(BuildContext context) => Container(
        padding: IsmLiveDimens.edgeInsets8_4,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(IsmLiveDimens.twenty),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const IsmLiveImage.svg(
              IsmLiveAssetConstants.coinSvg,
              height: 14,
              width: 14,
            ),
            IsmLiveDimens.boxWidth4,
            Text(
              '$amount',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: IsmLiveColors.black,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
}

class _UserInfo extends StatelessWidget {
  const _UserInfo({required this.stream});

  final IsmLiveStreamDataModel stream;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IsmLiveImage.network(
                stream.userDetails?.userProfile ?? '',
                name: stream.userDetails?.name ?? 'U',
                dimensions: IsmLiveDimens.twentyFour,
                isProfileImage: true,
              ),
              IsmLiveDimens.boxWidth4,
              Expanded(
                child: Text(
                  stream.userDetails?.userName ?? 'U',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: context.liveTheme?.selectedTextColor ??
                        IsmLiveColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Text(
            stream.streamDescription ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.liveTheme?.selectedTextColor ??
                  IsmLiveColors.white,
            ),
          ),
        ],
      );
}
