import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class StreamLiveSheet extends StatelessWidget {
  const StreamLiveSheet({
    super.key,
    this.onTap,
    this.buttonLable,
    required this.title,
    this.subTitle,
    this.widget,
  });
  final VoidCallback? onTap;
  final String? buttonLable;
  final String title;
  final String? subTitle;
  final Widget? widget;
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final titleColor = context.liveTheme?.primaryColor ??
        (isDarkMode ? Colors.white : Colors.black);
    final subtitleColor = context.liveTheme?.unselectedTextColor ??
        (isDarkMode ? const Color(0xFFB0B0B0) : Colors.grey);
    final iconColor = context.liveTheme?.primaryColor ??
        (isDarkMode ? Colors.white : Colors.black);

    return Container(
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: context.liveTheme?.backgroundColor ??
            (isDarkMode ? const Color(0xFF121212) : Colors.white),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(
            IsmLiveDelegate.bottomSheetBorderRadius?.topLeft.x ??
                IsmLiveDimens.thirty,
          ),
        ),
      ),
      padding: IsmLiveDimens.edgeInsets16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              onPressed: IsmLiveRoute.pop,
              icon: Icon(Icons.close, color: iconColor),
            ),
          ),
          widget ?? IsmLiveDimens.box0,
          IsmLiveDimens.boxHeight16,
          Text(
            title,
            style: IsmLiveStyles.blackBold16.copyWith(color: titleColor),
            textAlign: TextAlign.center,
          ),
          if (subTitle != null) ...[
            IsmLiveDimens.boxHeight16,
            Text(
              subTitle ?? '',
              style: IsmLiveStyles.lightGrey14.copyWith(color: subtitleColor),
              textAlign: TextAlign.center,
            )
          ],
          if (onTap != null && buttonLable != null) ...[
            IsmLiveDimens.boxHeight16,
            IsmLiveButton(
              label: buttonLable!,
              onTap: onTap!,
            ),
          ],
        ],
      ),
    );
  }
}
