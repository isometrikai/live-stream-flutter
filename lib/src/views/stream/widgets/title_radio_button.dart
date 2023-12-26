import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class TitleSwitchButton extends StatelessWidget {
  const TitleSwitchButton({
    super.key,
    required this.title,
    this.onChange,
    required this.value,
  });
  final String title;
  final Function(bool)? onChange;
  final bool value;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Switch(value: value, onChanged: onChange),
          IsmLiveDimens.boxWidth2,
          Text(
            title,
            style: IsmLiveStyles.white16,
          ),
        ],
      );
}
