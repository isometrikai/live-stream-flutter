import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class ParticipantInfoWidget extends StatelessWidget {
  const ParticipantInfoWidget({
    this.title,
    super.key,
    required this.isMute,
  });
  //
  final String? title;
  final bool isMute;

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.black.withOpacity(0.3),
        padding: EdgeInsets.symmetric(
          vertical: IsmLiveDimens.eight,
          horizontal: IsmLiveDimens.ten,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title!,
              overflow: TextOverflow.ellipsis,
              style: IsmLiveStyles.whiteBold16,
            ),
            IsmLiveDimens.boxWidth10,
            if (isMute)
              Icon(
                Icons.mic_off,
                color: Colors.white,
                size: IsmLiveDimens.fifteen,
              ),
          ],
        ),
      );
}
