import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class NoVideoWidget extends StatelessWidget {
  const NoVideoWidget({super.key, this.name});
  final String? name;
  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          height: IsmLiveDimens.hundred,
          width: IsmLiveDimens.hundred,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue,
          ),
          alignment: Alignment.center,
          child: LayoutBuilder(
            builder: (ctx, constraints) => Text(
              name?[0] ?? 'U',
              style: IsmLiveStyles.whiteBold25,
            ),
          ),
        ),
      );
}
