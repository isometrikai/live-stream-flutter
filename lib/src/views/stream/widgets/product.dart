// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveProduct extends StatelessWidget {
  const IsmLiveProduct({
    super.key,
    required this.productName,
    required this.productPrice,
    required this.productDiscription,
    required this.symbol,
    required this.isSelected,
    required this.onChanged,
    required this.imageUrl,
  });
  final String productName;
  final num productPrice;
  final String productDiscription;
  final String symbol;
  final String imageUrl;
  final bool isSelected;
  final Function(bool?) onChanged;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          SizedBox(
            width: IsmLiveDimens.seventy,
            height: IsmLiveDimens.seventy,
            child: IsmLiveImage.network(
              imageUrl,
              name:productName,
              radius: IsmLiveDimens.ten,
            ),
          ),
          IsmLiveDimens.boxWidth10,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      productName,
                      style: context.textTheme.bodySmall
                          ?.copyWith(color: IsmLiveColors.lightGray),
                    ),
                    SizedBox(
                      height: IsmLiveDimens.twenty,
                      width: IsmLiveDimens.twenty,
                      child: Checkbox(
                        checkColor: Colors.white,
                        activeColor: Colors.black,
                        value: isSelected,
                        onChanged: onChanged,
                      ),
                    )
                  ],
                ),
                Text(
                  productDiscription,
                  overflow: TextOverflow.ellipsis,
                  style: context.textTheme.bodyLarge,
                  maxLines: 1,
                ),
                IsmLiveDimens.boxHeight10,
                Row(
                  children: [
                    Text(
                      '$symbol $productPrice',
                      style: context.textTheme.bodySmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    IsmLiveDimens.boxWidth4,
                    Text(
                      '$symbol $productPrice',
                      style: const TextStyle(
                        color: IsmLiveColors.lightGray,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: IsmLiveColors.lightGray,
                      ),
                    ),
                    if (isSelected) ...[
                      const Spacer(),
                      IsmLiveTapHandler(
                        child: const Text(
                          'Add Discount',
                          style: TextStyle(color: Colors.blue),
                        ),
                        onTap: () => IsmLiveUtility.openBottomSheet(
                          const IsmLiveProductDiscountSheet(),
                        ),
                      ),
                    ]
                  ],
                )
              ],
            ),
          )
        ],
      );
}
