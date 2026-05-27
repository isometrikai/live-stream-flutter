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
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = context.liveTheme?.backgroundColor ??
        (isDarkMode ? const Color(0xFF121212) : Colors.white);
    final textColor = context.liveTheme?.primaryColor ??
        (isDarkMode ? Colors.white : Colors.black);
    final subtitleColor = context.liveTheme?.unselectedTextColor ??
        (isDarkMode ? const Color(0xFFB0B0B0) : Colors.grey.shade400);
    final iconColor = context.liveTheme?.primaryColor ??
        (isDarkMode ? Colors.white : Colors.black);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            IsmLiveDelegate.bottomSheetBorderRadius?.topLeft.x ??
                IsmLiveDimens.thirty,
          ),
        ),
      ),
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
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          IsmLiveDimens.boxHeight5,
          Text(
            description,
            style: context.textTheme.bodySmall?.copyWith(
              color: subtitleColor,
            ),
            textAlign: TextAlign.center,
          ),
          IsmLiveDimens.boxHeight5,
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.person, color: iconColor),
              IsmLiveDimens.boxWidth2,
              Text(followers, style: TextStyle(color: textColor)),
              IsmLiveDimens.boxWidth32,
              IsmLiveImage.svg(
                IsmLiveAssetConstants.coinSvg,
                color: iconColor,
              ),
              IsmLiveDimens.boxWidth2,
              Text(coins, style: TextStyle(color: textColor)),
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
}
