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
        child: Container(
          margin: EdgeInsets.symmetric(vertical: IsmLiveDimens.eight),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // CupertinoSwitch with controlled dimensions - no default margins
              SizedBox(
                height: IsmLiveDimens.twentyFive,
                width: IsmLiveDimens.thirtyTwo,
                child: FittedBox(
                  fit: BoxFit.fitHeight,
                  child: CupertinoSwitch(
                    value: value,
                    onChanged: onChange,
                    activeTrackColor: context.liveTheme?.primaryColor ??
                        IsmLiveColors.primary,
                    inactiveTrackColor:
                        context.liveTheme?.unselectedTextColor ??
                            IsmLiveColors.grey,
                  ),
                ),
              ),
              const SizedBox(width: 8.0), // Small margin after switch
              Text(
                title,
                style: IsmGoLiveView.getTextStyle(context, isDark),
              ),
              if (showIcon) ...[
                const Spacer(),
                const Icon(Icons.keyboard_arrow_right_rounded),
              ],
            ],
          ),
        ),
      );
}
