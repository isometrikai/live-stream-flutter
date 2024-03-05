import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveProductDiscountSheet extends StatelessWidget {
  const IsmLiveProductDiscountSheet({super.key});

  @override
  Widget build(BuildContext context) => Padding(
        padding: IsmLiveDimens.edgeInsets16_30_16_5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Discount Percentage',
                  style: context.textTheme.headlineSmall,
                ),
                IconButton(
                  onPressed: Get.back,
                  icon: const Icon(
                    Icons.close,
                    color: IsmLiveColors.black,
                  ),
                ),
              ],
            ),
            IsmLiveDimens.boxHeight32,
            Text(
              'Enter discount percentage',
              style: context.textTheme.bodySmall,
            ),
            IsmLiveInputField(
              radius: IsmLiveDimens.five,
              controller: TextEditingController(),
              suffixIcon: const Icon(Icons.percent),
              borderColor: Colors.purple[100],
              textInputType: const TextInputType.numberWithOptions(),
            ),
            IsmLiveDimens.boxHeight32,
            IsmLiveDimens.boxHeight32,
            const IsmLiveButton(label: 'Add'),
          ],
        ),
      );
}
