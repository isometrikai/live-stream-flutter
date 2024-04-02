import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class IsmLiveRestreamLinkTile extends StatelessWidget {
  const IsmLiveRestreamLinkTile(
    this.type, {
    super.key,
  });

  final IsmLiveRestreamType type;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: context.liveTheme?.borderColor,
          borderRadius: BorderRadius.circular(IsmLiveDimens.eight),
        ),
        padding: IsmLiveDimens.edgeInsets12,
        child: Row(
          children: [
            IsmLiveImage.svg(type.icon),
            IsmLiveDimens.boxWidth10,
            Text(type.linkPreview),
          ],
        ),
      );
}
