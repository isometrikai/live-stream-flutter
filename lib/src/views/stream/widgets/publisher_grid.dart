import 'dart:math';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

String _participantProfileImageUrl(
    IsmLiveStreamController controller, int index) {
  for (final element in controller.streamMembersList) {
    if (element.userId ==
        controller.participantList[index].participant.identity) {
      return element.userProfileImageUrl;
    }
  }
  return '';
}

String _participantFullName(IsmLiveStreamController controller, int index) {
  final participant = controller.participantList[index].participant;
  return ParticipantWidget.resolvedDisplayNameForParticipant(participant);
}

String _profileImageUrlForIdentity(
  IsmLiveStreamController controller,
  String identity,
) {
  for (final element in controller.streamMembersList) {
    if (element.userId == identity) {
      return element.userProfileImageUrl;
    }
  }
  return '';
}

bool _isSameParticipantTrack(
  IsmLiveParticipantTrack a,
  IsmLiveParticipantTrack b,
) =>
    a.participant.identity == b.participant.identity &&
    a.isScreenShare == b.isScreenShare;

/// RTMP gamer layout: game / host feed on top, co-publishers below.
IsmLiveParticipantTrack? _rtmpMainTrack(IsmLiveStreamController controller) {
  final tracks = controller.participantTracks;
  if (tracks.isEmpty) {
    return null;
  }

  final hostId = controller.hostDetails?.userId;

  if (hostId != null) {
    for (final track in tracks) {
      if (track.participant.identity == hostId && track.isScreenShare) {
        return track;
      }
    }
  }

  for (final track in tracks) {
    if (track.isScreenShare) {
      return track;
    }
  }

  if (hostId != null) {
    for (final track in tracks) {
      if (track.participant.identity == hostId && !track.isScreenShare) {
        return track;
      }
    }
  }

  return tracks.first;
}

List<IsmLiveParticipantTrack> _rtmpCoPublisherTracks(
  IsmLiveStreamController controller,
  IsmLiveParticipantTrack mainTrack,
) =>
    controller.participantTracks
        .where((track) => !_isSameParticipantTrack(track, mainTrack))
        .toList();

String _rtmpProfileImageUrl(
  IsmLiveStreamController controller,
  IsmLiveParticipantTrack track,
) {
  final hostId = controller.hostDetails?.userId;
  if (hostId != null && track.participant.identity == hostId) {
    return controller.hostDetails?.userProfileImageUrl ?? '';
  }
  return _profileImageUrlForIdentity(controller, track.participant.identity);
}

Widget _multiParticipantTile(
  IsmLiveStreamController controller,
  int index, {
  required int participantCount,
}) {
  final base = ParticipantWidget.widgetFor(
    controller.participantList[index],
    imageUrl: _participantProfileImageUrl(controller, index),
    isFirstIndex: index == 0,
    isViewer: !(controller.userRole?.isHost ?? false) &&
        !(controller.userRole?.isPkGuest ?? false) &&
        (controller.pkStages?.isPkStart ?? false),
    isHost: index == 0,
    showStatsLayer: controller.isPk,
    isWinner: controller.pkWinnerId ==
        controller.participantList[index].participant.identity,
    isbattleFinish: (controller.pkStages?.isPkStop ?? false) &&
        controller.pkWinnerId != null,
  );

  final showName = IsmLiveDelegate.showParticipantFullNamesInPublisherGrid &&
      participantCount > 1 &&
      !controller.isPk;
  if (!showName) {
    return base;
  }

  final fullName = _participantFullName(controller, index);
  if (fullName.isEmpty) {
    return base;
  }

  return Stack(
    fit: StackFit.expand,
    clipBehavior: Clip.hardEdge,
    children: [
      base,
      Positioned(
        left: IsmLiveDimens.eight,
        right: IsmLiveDimens.eight,
        bottom: IsmLiveDimens.eight,
        child: Align(
          alignment: Alignment.bottomLeft,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(IsmLiveDimens.four),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: IsmLiveDimens.eight,
                vertical: IsmLiveDimens.four,
              ),
              child: Text(
                fullName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: IsmLiveDimens.twelve,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

class IsmLivePublisherGrid extends StatelessWidget {
  const IsmLivePublisherGrid({
    super.key,
    required this.streamImage,
    this.isInteractive = false,
    this.isSchedule = false,
  });

  final String streamImage;
  final bool isInteractive;
  final bool isSchedule;

  static const String updateId = 'publisher-grid';

  /// Lower bound on grid height as a fraction of available viewport below the top inset.
  /// Pairs with 16:9 intrinsic sizing: common live apps use large tiles for few hosts
  /// (side-by-side ~half screen for 2) and scale up as the grid grows (2×2, 3×3, …).
  static double _minHeightFractionForParticipantCount(int count) {
    assert(count >= 2);
    if (count == 2) return 0.5;
    if (count == 3) return 1.0 / 3.0;
    if (count == 4) return 0.48;
    if (count <= 6) return 0.52;
    if (count <= 9) return 0.58;
    return 0.68;
  }

  /// Extra top inset so the multi-participant grid clears the stream header
  /// description. [IsmLiveDimens.hundred] already reserves host row + timer +
  /// ~one description line; add height for additional collapsed lines only.
  static double extraTopPaddingForStreamDescription(
    BuildContext context,
    String description,
    double layoutWidth,
  ) {
    final text = description.trim();
    if (text.isEmpty || layoutWidth <= 0) {
      return 0;
    }

    final style = Theme.of(context).textTheme.bodySmall;
    if (style == null) {
      return 0;
    }

    final textDirection = Directionality.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final locale = Localizations.maybeLocaleOf(context);
    // Matches [_ExpandableDescription] horizontal margin in stream header.
    final contentWidth = max(1.0, layoutWidth - IsmLiveDimens.ten * 2);

    double measureHeight(String sample, {int? maxLines}) {
      final painter = TextPainter(
        text: TextSpan(text: sample, style: style),
        textDirection: textDirection,
        maxLines: maxLines,
        textScaler: textScaler,
        locale: locale,
      );
      painter.layout(maxWidth: contentWidth);
      return painter.height;
    }

    // Header shows up to two lines before "View more".
    final descriptionHeight = measureHeight(text, maxLines: 2);
    final singleLineHeight = measureHeight('Ag', maxLines: 1);
    final extraLines = descriptionHeight - singleLineHeight;
    if (extraLines <= 0) {
      return 0;
    }

    // Small buffer for spacing between timer row and description block.
    return extraLines + IsmLiveDimens.eight;
  }

  /// [Align.alignment] Y for overlays centered in the video region below the
  /// stream header (0 = screen center, positive = slightly lower).
  static double contentCenterAlignmentY(
    BuildContext context, {
    required String description,
    required double layoutHeight,
    required double layoutWidth,
  }) {
    if (layoutHeight <= 0) {
      return 0;
    }
    final descriptionExtra = IsmLiveApp.showHeader
        ? extraTopPaddingForStreamDescription(
            context,
            description,
            layoutWidth,
          )
        : 0.0;
    final topInset = IsmLiveDimens.eighty + descriptionExtra;
    return (topInset / layoutHeight).clamp(0.0, 0.5);
  }

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: updateId,
        builder: (controller) => Obx(
          () {
            late final Widget child;
            if (controller.isRtmp) {
              child = controller.participantTracks.isNotEmpty
                  ? const _RtmlView()
                  : NoVideoWidget(
                      imageUrl: controller.hostDetails?.image ?? streamImage,
                      name: controller.hostDetails?.name ?? '',
                      showConnectingState: controller.isViewerJoiningStream,
                      connectingText: context.liveTranslations
                              ?.streamTranslations?.connectingToLiveStream ??
                          IsmLiveStrings.connectingToLiveStream,
                      initials: controller.hostDetails?.profileInitials,
                    );
            } else if (controller.participantTracks.isEmpty) {
              final streamIdOkForScheduled =
                  !isSchedule || IsmLiveStreamId.isValid(controller.streamId);
              child = streamIdOkForScheduled
                  ? NoVideoWidget(
                      imageUrl: controller.hostDetails?.image ?? streamImage,
                      name: controller.hostDetails?.name ?? '',
                      showConnectingState: controller.isViewerJoiningStream,
                      connectingText: context.liveTranslations
                              ?.streamTranslations?.connectingToLiveStream ??
                          IsmLiveStrings.connectingToLiveStream,
                      initials: controller.hostDetails?.profileInitials,
                    )
                  : const SizedBox.shrink();
            } else if (controller.participantTracks.length == 1) {
              child = InteractiveViewer(
                maxScale: isInteractive ? 3 : 1,
                panEnabled: isInteractive,
                scaleEnabled: isInteractive,
                child: SizedBox.expand(
                  child: ParticipantWidget.widgetFor(
                    controller.participantTracks.first,
                    imageUrl: controller.hostDetails?.userProfileImageUrl,
                    showStatsLayer: false,
                    showFullVideo: isInteractive,
                  ),
                ),
              );
            } else {
              child = LayoutBuilder(
                builder: (context, constraints) {
                  final participantCount = controller.participantTracks.length;

                  if (!IsmLiveDelegate.useGridLayoutForMultipleParticipants) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: List<Widget>.generate(
                        participantCount,
                        (index) => Expanded(
                          child: _multiParticipantTile(
                            controller,
                            index,
                            participantCount: participantCount,
                          ),
                        ),
                      ),
                    );
                  }

                  final descriptionExtraTopPad = IsmLiveApp.showHeader
                      ? extraTopPaddingForStreamDescription(
                          context,
                          controller.descriptionController.text,
                          constraints.maxWidth,
                        )
                      : 0.0;
                  final topPad =
                      IsmLiveDimens.hundredTen + descriptionExtraTopPad;

                  final mq = MediaQuery.of(context);
                  final imeBottom = mq.viewInsets.bottom;
                  final viewportCap =
                      max(1.0, mq.size.height - mq.viewPadding.vertical);
                  // Ancestors may shrink [constraints.maxHeight] when the IME is open.
                  // Use full-viewport height for grid math so tiles match the full-bleed
                  // video layer; [UnconstrainedBox] below lets this paint past the
                  // shrunk layout box when needed (stream Stack uses [Clip.none]).
                  final layoutViewportHeight = min(
                    constraints.maxHeight + imeBottom,
                    viewportCap,
                  );

                  final maxGridHeight = max(1.0, layoutViewportHeight - topPad);
                  final crossCount = participantCount < 3 ? 2 : 3;
                  final rowCount =
                      (participantCount + crossCount - 1) ~/ crossCount;
                  const crossSpacing = 0.0;
                  const mainSpacing = 0.0;
                  final crossExtent =
                      (constraints.maxWidth - (crossCount - 1) * crossSpacing) /
                          crossCount;
                  // Prefer 16:9 tiles, but enforce a minimum grid height by participant
                  // count so 1×2 / 2×2 / 3×3 style layouts stay readable on phones.
                  const videoTileAspectRatio = 16.0 / 9.0;
                  final idealMainExtent = crossExtent / videoTileAspectRatio;
                  final intrinsicGridHeight =
                      rowCount * idealMainExtent + (rowCount - 1) * mainSpacing;
                  final minDesiredHeight = maxGridHeight *
                      _minHeightFractionForParticipantCount(participantCount);
                  final gridHeight = min(
                    max(intrinsicGridHeight, minDesiredHeight),
                    maxGridHeight,
                  );
                  final mainExtent =
                      (gridHeight - (rowCount - 1) * mainSpacing) / rowCount;
                  // childAspectRatio = cross/main. An upper clamp (e.g. 4.0) made
                  // cells taller than [mainExtent], clipping the last row when
                  // height is tight (IME). Keep only a small positive floor.
                  final aspectRatio = max(crossExtent / mainExtent, 0.02);

                  return Align(
                    alignment: Alignment.topCenter,
                    child: UnconstrainedBox(
                      constrainedAxis: Axis.horizontal,
                      clipBehavior: Clip.none,
                      child: SizedBox(
                        width: constraints.maxWidth,
                        height: layoutViewportHeight,
                        child: Padding(
                          padding: EdgeInsets.only(top: topPad),
                          child: SizedBox(
                            width: constraints.maxWidth,
                            height: gridHeight,
                            child: GridView.builder(
                              restorationId: '',
                              itemCount: participantCount,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossCount,
                                mainAxisSpacing: mainSpacing,
                                crossAxisSpacing: crossSpacing,
                                childAspectRatio: aspectRatio,
                              ),
                              itemBuilder: (_, index) => _multiParticipantTile(
                                controller,
                                index,
                                participantCount: participantCount,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
            return SizedBox.expand(child: child);
          },
        ),
      );
}

class _RtmlView extends StatelessWidget {
  const _RtmlView();

  /// Backend publisher cap; UI fits all co-publishers in one row.
  static const int _maxCoPublishers = 5;

  static const double _videoAspectRatio = 16 / 9;

  /// Main stage height cap when stacked with the co-publisher row.
  static const double _mainStageMaxHeightFraction = 0.58;

  /// Vertical bias for stacked layout: 0 = center, negative = slightly above center.
  static const double _stackedLayoutVerticalBias = -0.35;

  Widget _mainVideo(
    BuildContext context,
    IsmLiveStreamController controller,
    IsmLiveParticipantTrack? mainTrack,
  ) {
    if (mainTrack == null) {
      return NoVideoWidget(
        imageUrl: controller.hostDetails?.image ?? '',
        name: controller.hostDetails?.name ?? '',
        showConnectingState: controller.isViewerJoiningStream,
        connectingText: context
                .liveTranslations?.streamTranslations?.connectingToLiveStream ??
            IsmLiveStrings.connectingToLiveStream,
        initials: controller.hostDetails?.profileInitials,
      );
    }

    return ParticipantWidget.widgetFor(
      mainTrack,
      imageUrl: _rtmpProfileImageUrl(controller, mainTrack),
      showStatsLayer: false,
      showFullVideo: true,
    );
  }

  Widget _coPublisherTile(
    IsmLiveStreamController controller,
    IsmLiveParticipantTrack track,
  ) =>
      ClipRRect(
        borderRadius: BorderRadius.circular(IsmLiveDimens.four),
        child: ParticipantWidget.widgetFor(
          track,
          imageUrl: _rtmpProfileImageUrl(controller, track),
          showStatsLayer: false,
          showFullVideo: false,
        ),
      );

  /// Single row of equal-width co-publisher tiles (max [_maxCoPublishers]).
  Widget _coPublisherRow(
    IsmLiveStreamController controller,
    List<IsmLiveParticipantTrack> coPublishers,
  ) {
    final tiles = coPublishers.take(_maxCoPublishers).toList();
    if (tiles.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        IsmLiveDimens.eight,
        IsmLiveDimens.eight,
        IsmLiveDimens.eight,
        IsmLiveDimens.four,
      ),
      child: Row(
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) SizedBox(width: IsmLiveDimens.eight),
            Expanded(
              child: AspectRatio(
                aspectRatio: _videoAspectRatio,
                child: _coPublisherTile(controller, tiles[i]),
              ),
            ),
          ],
        ],
      ),
    );
  }

  double _coPublisherRowHeight(double layoutWidth, int tileCount) {
    if (tileCount <= 0) {
      return 0;
    }
    final horizontalPad = IsmLiveDimens.eight * 2;
    final gaps = IsmLiveDimens.eight * (tileCount - 1);
    final tileWidth = (layoutWidth - horizontalPad - gaps) / tileCount;
    final tileHeight = tileWidth / _videoAspectRatio;
    return tileHeight + IsmLiveDimens.eight + IsmLiveDimens.four;
  }

  double _mainStageHeight(
    double width,
    double maxHeight, {
    required double coPublisherRowHeight,
  }) {
    final aspectHeight = width / _videoAspectRatio;
    final maxMainByViewport = max(
      1.0,
      (maxHeight - coPublisherRowHeight) * _mainStageMaxHeightFraction,
    );
    return min(aspectHeight, maxMainByViewport);
  }

  Widget _rtmpStackedLayout({
    required double width,
    required double mainHeight,
    required Widget mainVideo,
    required IsmLiveStreamController controller,
    required List<IsmLiveParticipantTrack> coPublishers,
  }) =>
      Align(
        alignment: const Alignment(0, _stackedLayoutVerticalBias),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: width,
              height: mainHeight,
              child: mainVideo,
            ),
            _coPublisherRow(controller, coPublishers),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => GetX<IsmLiveStreamController>(
        builder: (controller) {
          final mainTrack = _rtmpMainTrack(controller);
          final coPublishers = mainTrack == null
              ? const <IsmLiveParticipantTrack>[]
              : _rtmpCoPublisherTracks(controller, mainTrack);
          final mainVideo = _mainVideo(context, controller, mainTrack);

          return ColoredBox(
            color: Colors.black,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                if (coPublishers.isEmpty) {
                  return Center(
                    child: SizedBox(
                      width: width,
                      height: constraints.maxHeight,
                      child: mainVideo,
                    ),
                  );
                }

                final coCount = min(coPublishers.length, _maxCoPublishers);
                final coRowHeight = _coPublisherRowHeight(width, coCount);
                final mainHeight = _mainStageHeight(
                  width,
                  constraints.maxHeight,
                  coPublisherRowHeight: coRowHeight,
                );

                return _rtmpStackedLayout(
                  width: width,
                  mainHeight: mainHeight,
                  mainVideo: mainVideo,
                  controller: controller,
                  coPublishers: coPublishers,
                );
              },
            ),
          );
        },
      );
}
