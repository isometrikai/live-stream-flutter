import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rounded_progress_bar/flutter_rounded_progress_bar.dart';
import 'package:flutter_rounded_progress_bar/rounded_progress_bar_style.dart';

class ParticipantInfoWidget extends StatelessWidget {
  const ParticipantInfoWidget({
    this.title,
    super.key,
    this.imageUrl,
    required this.name,
    required this.isHost,
    required this.isFirstIndex,
  });
  //
  final String? title;
  final String? imageUrl;
  final String name;
  final bool isHost;
  final bool isFirstIndex;

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.black.withOpacity(0.3),
        child: ListTile(
          contentPadding: isFirstIndex
              ? IsmLiveDimens.edgeInsetsL10
              : IsmLiveDimens.edgeInsetsR10,
          horizontalTitleGap: IsmLiveDimens.five,
          leading: isFirstIndex
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
            '@$title',
            style: const TextStyle(color: Colors.white),
            textAlign: isFirstIndex ? TextAlign.start : TextAlign.end,
          ),
          subtitle: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RoundedProgressBar(
                childLeft: isFirstIndex
                    ? const Text(
                        '0',
                      )
                    : null,
                childRight: !isFirstIndex
                    ? const Text(
                        '0',
                      )
                    : null,
                paddingChildLeft:
                    isFirstIndex ? IsmLiveDimens.edgeInsets4_0 : null,
                paddingChildRight:
                    !isFirstIndex ? IsmLiveDimens.edgeInsets4_0 : null,
                height: IsmLiveDimens.twenty,
                style: RoundedProgressBarStyle(
                    borderWidth: 0,
                    widthShadow: 0,
                    backgroundProgress: Colors.blue,
                    colorProgress: Colors.red),
                borderRadius: isFirstIndex
                    ? BorderRadius.only(
                        bottomLeft: Radius.circular(IsmLiveDimens.ten),
                        topLeft: Radius.circular(IsmLiveDimens.ten),
                      )
                    : BorderRadius.only(
                        bottomRight: Radius.circular(IsmLiveDimens.ten),
                        topRight: Radius.circular(IsmLiveDimens.ten),
                      ),
                percent: isFirstIndex ? 20 : 0,
              ),
            ],
          ),
          trailing: !isFirstIndex
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
