import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

/// Right rail: Products, Share, More.
class IsmLiveStreamRecordingRightControls extends StatelessWidget {
  const IsmLiveStreamRecordingRightControls({
    super.key,
    required this.config,
    required this.recording,
    required this.products,
    required this.onAllProducts,
    required this.onMore,
    required this.onFollow,
  });

  final IsmLiveStreamRecordingPlayerConfig config;
  final IsmLiveStreamRecordingItem recording;
  final List<IsmLiveStreamRecordingProduct> products;
  final VoidCallback onAllProducts;
  final VoidCallback onMore;
  final VoidCallback onFollow;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ActionButton(
            icon: Icons.grid_view_rounded,
            label: 'Products',
            count: products.length,
            onTap: onAllProducts,
          ),
          if (config.onShare != null)
            _ActionButton(
              icon: Icons.share_rounded,
              label: 'Share',
              onTap: () => config.onShare!(null, recording),
            ),
          _ActionButton(
            icon: Icons.more_horiz_rounded,
            label: 'More',
            onTap: onMore,
          ),
          if (recording.userId != null &&
              recording.userId!.isNotEmpty &&
              config.onFollowUser != null)
            _ActionButton(
              icon: Icons.person_add_rounded,
              label: 'Follow',
              onTap: onFollow,
            ),
        ],
      );
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    this.count,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int? count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(icon, color: Colors.white, size: 28),
              onPressed: onTap,
            ),
            if (count != null && count! > 0)
              Text(
                count.toString(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontSize: 12,
                    ),
              )
            else
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontSize: 12,
                    ),
              ),
          ],
        ),
      );
}
