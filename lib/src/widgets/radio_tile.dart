import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class IsmLiveRadioListTile extends StatelessWidget {
  const IsmLiveRadioListTile({
    super.key,
    required this.title,
    required this.onChange,
    required this.value,
    this.isDark = true,
    this.showIcon = false,
  });
  final String title;
  final Function(bool) onChange;
  final bool value;
  final bool isDark;
  final bool showIcon;

  @override
  Widget build(BuildContext context) => IsmLiveTapHandler(
        onTap: () => onChange(!value),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: 0.8,
              child: CupertinoSwitch(
                value: value,
                onChanged: onChange,
                activeTrackColor:
                    context.liveTheme?.primaryColor ?? IsmLiveColors.primary,
                inactiveTrackColor: context.liveTheme?.unselectedTextColor ??
                    IsmLiveColors.grey,
              ),
            ),
            IsmLiveDimens.boxWidth2,
            Text(
              title,
              style: context.dynamicTextTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isDark ? IsmLiveColors.white : IsmLiveColors.black,
              ),
            ),
            if (showIcon) ...[
              const Spacer(),
              const Icon(Icons.keyboard_arrow_right_rounded),
            ],
          ],
        ),
      );
}
