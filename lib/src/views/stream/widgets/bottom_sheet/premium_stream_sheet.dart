import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class IsmLivePremiumStreamSheet extends StatelessWidget {
  const IsmLivePremiumStreamSheet(
      {super.key, required this.textController, this.onTap});
  final TextEditingController textController;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: IsmLiveDimens.edgeInsets16_30_16_5,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const IsmLiveImage.svg(IsmLiveAssetConstants.premiumDimond),
            Text(
              'Premium Broadcast',
              style: context.textTheme.bodyLarge,
            ),
            Text(
              'Set coins you want to get from your fans',
              style: context.textTheme.bodySmall,
            ),
            IsmLiveDimens.boxHeight20,
            IsmLiveInputField(
              maxLength: 6,
              validator: (value) {
                if (value == null) return 'Enter coins';
                return null;
              },
              radius: IsmLiveDimens.ten,
              controller: textController,
              prefixIcon: UnconstrainedBox(
                child: IsmLiveImage.svg(
                  IsmLiveAssetConstants.coinSvg,
                  dimensions: IsmLiveDimens.thirty,
                ),
              ),
              textInputType: const TextInputType.numberWithOptions(),
            ),
            IsmLiveDimens.boxHeight32,
            IsmLiveButton(
              label: 'Save',
              onTap: onTap,
            ),
          ],
        ),
      );
}
