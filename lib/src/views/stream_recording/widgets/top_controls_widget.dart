import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

/// Top bar aligned with stream view: profile (same UI + click flow), view count, cart, close.
class IsmLiveStreamRecordingTopControls extends StatelessWidget {
  const IsmLiveStreamRecordingTopControls({
    super.key,
    required this.recording,
    required this.config,
    required this.onClose,
  });

  final IsmLiveStreamRecordingItem recording;
  final IsmLiveStreamRecordingPlayerConfig config;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final name = recording.userName ?? 'U';
    final imageUrl = IsmLiveDelegate.getUserProfileUrl?.call(
          recording.userImageUrl ?? '',
        ) ??
        recording.userImageUrl ??
        '';
    final userIdentifier = recording.userId ?? '';
    final description = '';

    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.paddingOf(context).top + 8,
        left: IsmLiveDimens.eight,
        right: IsmLiveDimens.eight,
        bottom: IsmLiveDimens.eight,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black54, Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IsmLiveDimens.boxWidth10,
          _RecordingProfileChip(
            name: name,
            imageUrl: imageUrl,
            description: description,
            userIdentifier: userIdentifier,
            recording: recording,
            config: config,
          ),
          IsmLiveDimens.boxWidth10,
          if (recording.recordViewCount > 0) ...[
            _RecordingViewCount(count: recording.recordViewCount),
            IsmLiveDimens.boxWidth10,
          ],
          const Spacer(),
          SafeArea(
            top: false,
            child: IsmLiveTapHandler(
              onTap: onClose,
              child: Padding(
                padding: IsmLiveDimens.edgeInsets10_0,
                child: const Icon(
                  Icons.close,
                  color: IsmLiveColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Profile chip matching [IsmLiveHostDetail] look; uses same click flow as stream view
/// (hostTopProfileClickCallback then StreamLiveSheet with View Profile).
class _RecordingProfileChip extends StatelessWidget {
  const _RecordingProfileChip({
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.userIdentifier,
    required this.recording,
    required this.config,
  });

  final String name;
  final String imageUrl;
  final String description;
  final String userIdentifier;
  final IsmLiveStreamRecordingItem recording;
  final IsmLiveStreamRecordingPlayerConfig config;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final pillColor = context.liveTheme?.primaryColor ??
        (isDarkMode ? Colors.white : Colors.black);
    final pillFillColor = isDarkMode
        ? Colors.white.withValues(alpha: 0.2)
        : Colors.black.withValues(alpha: 0.2);
    final textColor =
        pillColor.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return IsmLiveTapHandler(
        onTap: () async {
          config.onControlOption?.call(
            context,
            IsmLiveStreamRecordingControlOption.openUserProfile,
            recording,
          );
        },
        child: Container(
          width: IsmLiveDimens.hundredFourty,
          decoration: BoxDecoration(
            color: pillFillColor,
            borderRadius: BorderRadius.circular(IsmLiveDimens.hundred),
            border: Border.all(color: pillColor),
          ),
          padding: IsmLiveDimens.edgeInsets2,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IsmLiveImage.network(
                imageUrl,
                name: name,
                isProfileImage: true,
                height: IsmLiveDimens.forty,
                width: IsmLiveDimens.forty,
                border: Border.all(color: pillColor),
              ),
              IsmLiveDimens.boxWidth4,
              SizedBox(
                width: IsmLiveDimens.seventy,
                child: Text(
                  '@$name',
                  style: IsmLiveStyles.white12.copyWith(color: textColor),
                  maxLines: 1,
                ),
              ),
            ],
          ),
        ),
      );
  }
}

/// View count chip matching [IsmLiveViewerCount] style (recording has no tap sheet).
class _RecordingViewCount extends StatelessWidget {
  const _RecordingViewCount({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) => Container(
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
              Text(
                _formatCount(count),
                style: IsmLiveStyles.white12,
              ),
            ],
          ),
        ),
      );

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}
