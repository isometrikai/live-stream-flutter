import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) => GestureDetector(
        onTap: () {
          onChange(!value);
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(value: value, onChanged: onChange),
            IsmLiveDimens.boxWidth2,
            Text(
              title,
              style: IsmLiveStyles.white16,
            ),
          ],
        ),
      );
}
