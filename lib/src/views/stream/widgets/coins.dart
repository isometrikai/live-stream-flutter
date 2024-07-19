import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class IsmLiveCoins extends StatelessWidget {
  const IsmLiveCoins({
    super.key,
    required this.coins,
  });

  final String coins;

  @override
  Widget build(BuildContext context) => Container(
        padding: IsmLiveDimens.edgeInsets4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(IsmLiveDimens.eight),
          color: Colors.black12,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const IsmLiveImage.svg(IsmLiveAssetConstants.coinSvg),
            IsmLiveDimens.boxWidth4,
            Text(
              coins,
              style: IsmLiveStyles.white12,
            ),
          ],
        ),
      );
}
