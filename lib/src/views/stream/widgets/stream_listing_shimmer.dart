import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/widgets/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

/// Skeleton loader matching `IsmLiveStreamListing` grid UI.
class IsmLiveStreamListingShimmer extends StatelessWidget {
  const IsmLiveStreamListingShimmer({
    super.key,
    this.itemCount = 6,
    this.topSpaceFactor = 0.25,
  });

  final int itemCount;
  final double topSpaceFactor;

  @override
  Widget build(BuildContext context) {
    final background = Theme.of(context).scaffoldBackgroundColor;

    return ColoredBox(
      color: background,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final factor = topSpaceFactor.clamp(0.0, 0.6);
            final topSpace = constraints.maxHeight * factor;
            return IsmLiveShimmer(
              child: Column(
                children: [
                  SizedBox(height: topSpace),
                  Expanded(
                    child: Padding(
                      padding: IsmLiveDimens.edgeInsets16,
                      child: StaggeredGrid.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: IsmLiveDimens.eight,
                        mainAxisSpacing: IsmLiveDimens.eight,
                        children: List.generate(
                          itemCount,
                          (_) => const _StreamTileSkeleton(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StreamTileSkeleton extends StatelessWidget {
  const _StreamTileSkeleton();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(IsmLiveDimens.sixteen),
      child: SizedBox(
        height: IsmLiveDimens.twoHundredTwenty, // matches `IsmLiveStreamCard`
        child: Stack(
          children: [
            const Positioned.fill(
              child: IsmLiveSkeletonBox(
                height: double.infinity,
                width: double.infinity,
                radius: 16,
              ),
            ),
            Positioned(
              left: IsmLiveDimens.eight,
              right: IsmLiveDimens.eight,
              bottom: IsmLiveDimens.eight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IsmLiveSkeletonCircle(size: IsmLiveDimens.thirtyTwo),
                      IsmLiveDimens.boxWidth10,
                      const Expanded(
                        child: IsmLiveSkeletonBox(
                          height: 14,
                          width: double.infinity,
                          radius: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const IsmLiveSkeletonBox(height: 12, width: 110, radius: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

