import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

/// More options: Delete (own stream) or Report (others).
class IsmLiveStreamRecordingMoreOptionsSheet extends StatelessWidget {
  const IsmLiveStreamRecordingMoreOptionsSheet({
    super.key,
    required this.recording,
    required this.config,
    required this.onClose,
  });

  final IsmLiveStreamRecordingItem recording;
  final IsmLiveStreamRecordingPlayerConfig config;
  final VoidCallback onClose;

  bool get _isOwnStream {
    final currentUserId = config.getCurrentUserId?.call();
    final streamerUserId = recording.userId;
    if (currentUserId == null || streamerUserId == null) return false;
    return currentUserId == streamerUserId;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final borderRadius = IsmLiveDelegate.bottomSheetBorderRadius ??
        const BorderRadius.vertical(top: Radius.circular(16));

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: borderRadius,
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.close),
              title: Text(
                IsmLiveStrings.moreOptions,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: onClose,
            ),
            if (_isOwnStream && config.onControlOption != null)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: Text(
                  IsmLiveStrings.delete,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  config.onControlOption!(
                    context,
                    IsmLiveStreamRecordingControlOption.deleteStream,
                    recording,
                  );
                  if (context.mounted) {
                    onClose();
                    Navigator.of(context).pop();
                  }
                },
              ),
            if (!_isOwnStream && config.onControlOption != null)
              ListTile(
                leading: const Icon(Icons.flag_outlined, color: Colors.orange),
                title: Text(
                  IsmLiveStrings.report,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: () {
                  config.onControlOption!(
                    context,
                    IsmLiveStreamRecordingControlOption.reportStream,
                    recording,
                  );
                  if (context.mounted) {
                    onClose();
                    Navigator.of(context).pop();
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
