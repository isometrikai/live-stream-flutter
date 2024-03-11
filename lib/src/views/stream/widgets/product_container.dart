import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveProductContainer extends StatelessWidget {
  const IsmLiveProductContainer({
    super.key,
    required this.productName,
    required this.productDisc,
    required this.currencyIcon,
    required this.price,
    required this.onPress,
    required this.imageUrl,
    this.width,
  });
  final String productName;
  final double? width;
  final String imageUrl;
  final String productDisc;
  final String currencyIcon;
  final num price;
  final Function() onPress;

  @override
  Widget build(BuildContext context) => Container(
        width: width ?? Get.width * .3,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: IsmLiveImage.network(imageUrl),
                ),
                IsmLiveDimens.boxHeight10,
                Padding(
                  padding: IsmLiveDimens.edgeInsets8_0,
                  child: Text(
                    productName.toUpperCase(),
                    style: context.textTheme.bodySmall
                        ?.copyWith(color: IsmLiveColors.lightGray),
                  ),
                ),
                Padding(
                  padding: IsmLiveDimens.edgeInsets8_0,
                  child: Text(
                    productDisc,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyLarge,
                    maxLines: 1,
                  ),
                ),
                IsmLiveDimens.boxHeight10,
                Padding(
                  padding: IsmLiveDimens.edgeInsets8_0,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$currencyIcon $price',
                        style: context.textTheme.bodySmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IsmLiveDimens.boxWidth4,
                      Text(
                        '$currencyIcon $price',
                        style: const TextStyle(
                          color: IsmLiveColors.lightGray,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: IsmLiveColors.lightGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              right: -10,
              top: -10,
              child: IconButton(
                padding: IsmLiveDimens.edgeInsets0,
                onPressed: onPress,
                icon: Icon(
                  Icons.cancel,
                  size: IsmLiveDimens.twenty,
                ),
              ),
            ),
          ],
        ),
      );
}
