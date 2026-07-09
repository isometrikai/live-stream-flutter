import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveAllStreamsListing extends StatelessWidget {
  const IsmLiveAllStreamsListing({
    super.key,
    required this.onStreamTap,
    required this.onViewAllTap,
  });

  final void Function(
    IsmLiveStreamDataModel stream,
    IsmLiveHomeStreamCardStyle style,
  ) onStreamTap;

  final void Function(IsmLiveStreamType type) onViewAllTap;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IsmLiveStreamController>();
    final homeStreams = controller.homeStreams;

    final sections = <_HomeStreamSection>[
      _HomeStreamSection(
        title: IsmLiveStrings.scheduled,
        streams: homeStreams.scheduled,
        style: IsmLiveHomeStreamCardStyle.scheduled,
        viewAllType: IsmLiveStreamType.scheduledStreams,
      ),
      _HomeStreamSection(
        title: IsmLiveStrings.liveStreams,
        streams: homeStreams.live,
        style: IsmLiveHomeStreamCardStyle.live,
        viewAllType: IsmLiveStreamType.live,
      ),
      _HomeStreamSection(
        title: IsmLiveStrings.pk.toUpperCase(),
        streams: homeStreams.pk,
        style: IsmLiveHomeStreamCardStyle.pk,
        viewAllType: IsmLiveStreamType.pk,
      ),
      _HomeStreamSection(
        title: IsmLiveStrings.reStream,
        streams: homeStreams.restream,
        style: IsmLiveHomeStreamCardStyle.restream,
        viewAllType: IsmLiveStreamType.restream,
      ),
      _HomeStreamSection(
        title: IsmLiveStrings.recorded,
        streams: homeStreams.recorded,
        style: IsmLiveHomeStreamCardStyle.recorded,
        viewAllType: IsmLiveStreamType.recorded,
      ),
    ].where((section) => section.streams.isNotEmpty).toList();

    if (sections.isEmpty) {
      return IsmLiveEmptyScreen(
        label: IsmLiveStrings.noStreams,
        placeHolder: IsmLiveAssetConstants.noStreamsPlaceholder,
      );
    }

    // Non-scrollable body so SmartRefresher owns vertical scrolling (same as
    // StaggeredGrid on other tabs). A nested ListView breaks pull-to-refresh.
    return Padding(
      padding: IsmLiveDimens.edgeInsets16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < sections.length; i++) ...[
            if (i > 0) IsmLiveDimens.boxHeight24,
            _HomeStreamSectionView(
              section: sections[i],
              onStreamTap: onStreamTap,
              onViewAllTap: onViewAllTap,
            ),
          ],
        ],
      ),
    );
  }
}

class _HomeStreamSection {
  const _HomeStreamSection({
    required this.title,
    required this.streams,
    required this.style,
    this.viewAllType,
  });

  final String title;
  final List<IsmLiveStreamDataModel> streams;
  final IsmLiveHomeStreamCardStyle style;
  final IsmLiveStreamType? viewAllType;
}

class _HomeStreamSectionView extends StatelessWidget {
  const _HomeStreamSectionView({
    required this.section,
    required this.onStreamTap,
    required this.onViewAllTap,
  });

  final _HomeStreamSection section;
  final void Function(
    IsmLiveStreamDataModel stream,
    IsmLiveHomeStreamCardStyle style,
  ) onStreamTap;
  final void Function(IsmLiveStreamType type) onViewAllTap;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<IsmLiveStreamController>();
    final primaryColor =
        context.liveTheme?.primaryColor ?? IsmLiveColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                section.title,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (section.viewAllType != null)
              IsmLiveTapHandler(
                onTap: () => onViewAllTap(section.viewAllType!),
                child: Text(
                  IsmLiveStrings.viewAll,
                  style: context.textTheme.titleSmall?.copyWith(
                    color: primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        IsmLiveDimens.boxHeight10,
        SizedBox(
          height: IsmLiveDimens.twoHundred,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var i = 0; i < section.streams.length; i++) ...[
                  if (i > 0) IsmLiveDimens.boxWidth12,
                  IsmLiveHomeStreamSectionCard(
                    stream: section.streams[i],
                    style: section.style,
                    isCreatedByMe:
                        section.streams[i].userId == controller.user?.userId,
                    onTap: () => onStreamTap(section.streams[i], section.style),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
