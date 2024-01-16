import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveMessageBottomSheet extends StatelessWidget {
  const IsmLiveMessageBottomSheet({
    super.key,
    required this.isHost,
    this.onReply,
    this.onDelete,
  });

  final bool isHost;
  final VoidCallback? onReply;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => Padding(
        padding: IsmLiveDimens.edgeInsets8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SheetItem(
              icon: Icons.reply_rounded,
              label: 'Reply',
              onTap: onReply,
            ),
            if (isHost)
              _SheetItem(
                icon: Icons.delete_rounded,
                label: 'Delete',
                onTap: onDelete,
              ),
          ],
        ),
      );
}

class _SheetItem extends StatelessWidget {
  const _SheetItem({
    required this.icon,
    required this.label,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => IsmLiveTapHandler(
        onTap: () {
          Get.back();
          onTap?.call();
        },
        child: Padding(
          padding: IsmLiveDimens.edgeInsets16_10,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon),
              IsmLiveDimens.boxWidth10,
              Text(
                label,
                style: context.textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
}
