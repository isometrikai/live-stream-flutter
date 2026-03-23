import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLivePremiumStreamSheet extends StatelessWidget {
  const IsmLivePremiumStreamSheet(
      {super.key, required this.textController, this.onTap});
  final TextEditingController textController;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final keyboardBottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: keyboardBottom),
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: context.liveTheme?.backgroundColor ??
                (Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF121212)
                    : Colors.white),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(
                IsmLiveDelegate.bottomSheetBorderRadius?.topLeft.x ??
                    IsmLiveDimens.thirty,
              ),
            ),
          ),
          child: Padding(
            padding: IsmLiveDimens.edgeInsets16_30_16_5,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const IsmLiveImage.svg(IsmLiveAssetConstants.premiumDimond),
                Text(
                  IsmLiveStrings.premiumBroadcast,
                  style: context.textTheme.bodyLarge?.copyWith(
                    color: context.liveTheme?.primaryColor ??
                        (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IsmLiveDimens.boxHeight8,
                Text(
                  IsmLiveStrings.setCoinsFromFans,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.liveTheme?.unselectedTextColor ??
                        (Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[400]
                            : Colors.grey[600]),
                  ),
                ),
                IsmLiveDimens.boxHeight20,
                IsmLiveInputField(
                  maxLength: 6,
                  validator: (value) {
                    if (value == null) return IsmLiveStrings.enterCoins;
                    return null;
                  },
                  radius: IsmLiveDimens.ten,
                  controller: textController,
                  fillColor: context.liveTheme?.cardBackgroundColor ??
                      (Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1E1E1E)
                          : Colors.white),
                  borderColor: Theme.of(context).brightness == Brightness.dark
                      ? context.liveTheme?.borderColor ?? const Color(0xFF1E1E1E)
                      : IsmLiveColors.black,
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
                  label: IsmLiveStrings.save,
                  onTap: onTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
