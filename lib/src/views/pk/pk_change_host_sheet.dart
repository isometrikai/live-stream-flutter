import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLivePkChangeHostSheet extends StatelessWidget {
  const IsmLivePkChangeHostSheet(
      {super.key,
      required this.image,
      required this.title,
      required this.description,
      required this.lable,
      required this.coins,
      required this.followers,
      this.onTap});
  final String image;
  final String title;
  final String description;
  final String lable;
  final String coins;
  final String followers;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: IsmLiveDimens.edgeInsets16.copyWith(
          top: IsmLiveDimens.thirtyTwo,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            IsmLiveImage.network(
              image,
              name: title,
              height: IsmLiveDimens.hundred,
              width: IsmLiveDimens.hundred,
              isProfileImage: true,
            ),
            IsmLiveDimens.boxHeight10,
            Text(
              title,
              style: context.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            IsmLiveDimens.boxHeight5,
            Text(
              description,
              style: context.textTheme.bodySmall
                  ?.copyWith(color: Colors.grey.shade400),
              textAlign: TextAlign.center,
            ),
            IsmLiveDimens.boxHeight5,
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.person),
                IsmLiveDimens.boxWidth2,
                Text(followers),
                IsmLiveDimens.boxWidth32,
                const IsmLiveImage.svg(IsmLiveAssetConstants.coinSvg),
                IsmLiveDimens.boxWidth2,
                Text(coins),
              ],
            ),
            IsmLiveDimens.boxHeight32,
            IsmLiveButton(
              label: lable,
              onTap: onTap,
            ),
          ],
        ),
      );
}
