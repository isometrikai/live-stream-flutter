import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class ParticipantInfoWidget extends StatelessWidget {
  const ParticipantInfoWidget({
    this.title,
    super.key,
    this.imageUrl,
    required this.name,
    required this.isHost,
  });
  //
  final String? title;
  final String? imageUrl;
  final String name;
  final bool isHost;

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.black.withOpacity(0.3),
        child: ListTile(
          contentPadding: IsmLiveDimens.edgeInsets10_0,
          horizontalTitleGap: IsmLiveDimens.five,
          leading: isHost
              ? SizedBox(
                  child: IsmLiveImage.network(
                    imageUrl ?? '',
                    name: name,
                    height: IsmLiveDimens.forty,
                    width: IsmLiveDimens.forty,
                    isProfileImage: true,
                  ),
                )
              : null,
          title: Text(
            title ?? '',
            style: const TextStyle(color: Colors.white),
            textAlign: isHost ? TextAlign.start : TextAlign.end,
          ),
          subtitle: UnconstrainedBox(
            alignment: isHost ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              padding: IsmLiveDimens.edgeInsets2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(IsmLiveDimens.five),
                color: isHost ? Colors.red : Colors.purple,
              ),
              child: Text(
                isHost ? 'Host' : 'Guest',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
          trailing: isHost == false
              ? SizedBox(
                  child: IsmLiveImage.network(
                    imageUrl ?? '',
                    name: name,
                    height: IsmLiveDimens.forty,
                    width: IsmLiveDimens.forty,
                    isProfileImage: true,
                  ),
                )
              : null,
        ),
      );
}
