import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class IsmLiveRadioListTile extends StatelessWidget {
  const IsmLiveRadioListTile({
    super.key,
    required this.title,
    required this.onChange,
    required this.value,
  });
  final String title;
  final Function(bool) onChange;
  final bool value;

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
                activeColor: context.liveTheme.primaryColor ?? IsmLiveColors.primary,
                trackColor: context.liveTheme.unselectedTextColor ?? IsmLiveColors.grey,
              ),
            ),
            IsmLiveDimens.boxWidth2,
            Text(
              title,
              style: context.textTheme.bodyLarge?.copyWith(
                color: IsmLiveColors.white,
              ),
            ),
          ],
        ),
      );
}
