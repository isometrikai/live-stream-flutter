import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Bottom sheet for follow/unfollow streamer.
class IsmLiveStreamRecordingFollowUserSheet extends StatefulWidget {
  const IsmLiveStreamRecordingFollowUserSheet({
    super.key,
    required this.recording,
    required this.config,
    required this.onClose,
  });

  final IsmLiveStreamRecordingItem recording;
  final IsmLiveStreamRecordingPlayerConfig config;
  final VoidCallback onClose;

  @override
  State<IsmLiveStreamRecordingFollowUserSheet> createState() =>
      _IsmLiveStreamRecordingFollowUserSheetState();
}

class _IsmLiveStreamRecordingFollowUserSheetState
    extends State<IsmLiveStreamRecordingFollowUserSheet> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = IsmLiveDelegate.bottomSheetBorderRadius ??
        const BorderRadius.vertical(top: Radius.circular(16));
    final recording = widget.recording;
    final onFollow = widget.config.onFollowUser;

    if (onFollow == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: borderRadius,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(28),
                  child: recording.userImageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: recording.userImageUrl!,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const Icon(
                            Icons.person,
                            size: 56,
                          ),
                          errorWidget: (_, __, ___) => const Icon(
                            Icons.person,
                            size: 56,
                          ),
                        )
                      : const Icon(Icons.person, size: 56),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recording.userName ?? 'Streamer',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (recording.userId != null)
                        Text(
                          recording.userId!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        final userId = recording.userId;
                        if (userId == null || userId.isEmpty) return;
                        setState(() => _isLoading = true);
                        try {
                          await onFollow(userId);
                          if (context.mounted) {
                            widget.onClose();
                            Navigator.of(context).pop();
                          }
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      },
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Follow'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
