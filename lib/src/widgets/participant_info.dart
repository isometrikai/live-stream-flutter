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
    required this.hostCoins,
    required this.gustCoins,
    required this.hostper,
    required this.gustper,
    required this.battleStart,
  });

  final String? title;
  final String? imageUrl;
  final String name;
  final bool isHost;
  final bool battleStart;
  final int hostCoins;
  final int gustCoins;
  final double hostper;
  final double gustper;

  final bool isFirstIndex;

  @override
  Widget build(BuildContext context) => Stack(
        children: [
          Container(
            color: Colors.black.withOpacity(0.3),
            child: ListTile(
              contentPadding: isFirstIndex
                  ? IsmLiveDimens.edgeInsetsL10
                  : IsmLiveDimens.edgeInsetsR10,
              horizontalTitleGap: IsmLiveDimens.ten,
              leading: isFirstIndex
                  ? IsmLiveProfileView(
                      imageUrl: imageUrl ?? '',
                      name: name,
                      isHost: isHost,
                    )
                  : null,
              title: Text(
                '@$title',
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textAlign: isFirstIndex ? TextAlign.start : TextAlign.end,
              ),
              subtitle: Column(
                crossAxisAlignment:
                    isHost ? CrossAxisAlignment.start : CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (battleStart)
                    RoundedProgressBar(
                      childLeft: isFirstIndex
                          ? Text(
                              ' $hostCoins',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            )
                          : null,
                      childRight: !isFirstIndex
                          ? Text(
                              ' $gustCoins',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            )
                          : null,
                      paddingChildLeft:
                          isFirstIndex ? IsmLiveDimens.edgeInsets4_0 : null,
                      paddingChildRight:
                          !isFirstIndex ? IsmLiveDimens.edgeInsets4_0 : null,
                      height: 18,
                      style: RoundedProgressBarStyle(
                        borderWidth: 0,
                        widthShadow: 0,
                        backgroundProgress:
                            !isFirstIndex ? Colors.red : Colors.blue,
                        colorProgress: isFirstIndex ? Colors.red : Colors.blue,
                      ),
                      borderRadius: isFirstIndex
                          ? const BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              topLeft: Radius.circular(10),
                            )
                          : const BorderRadius.only(
                              bottomRight: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                      reverse: !isFirstIndex,
                      milliseconds: 0,
                      percent: isFirstIndex ? hostper : gustper,
                    )
                  else
                    Container(
                      padding: IsmLiveDimens.edgeInsets2_0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(IsmLiveDimens.five),
                        color: isHost ? Colors.red : Colors.purple,
                      ),
                      child: Text(
                        isHost ? 'Host' : 'Guest',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                ],
              ),
              trailing: !isFirstIndex
                  ? IsmLiveProfileView(
                      imageUrl: imageUrl ?? '',
                      name: name,
                      isHost: isHost,
                    )
                  : null,
            ),
          ),
          if (battleStart) ...[
            Positioned(
              bottom: 5,
              left: isHost ? -8 : null,
              right: !isHost ? -8 : null,
              child: IsmLiveImage.svg(
                isHost
                    ? IsmLiveAssetConstants.hostRing
                    : IsmLiveAssetConstants.gustRing,
                height: 55,
              ),
            ),
            Positioned(
              bottom: 5,
              left: isHost ? 16 : null,
              right: isHost ? null : 12,
              child: Container(
                padding: IsmLiveDimens.edgeInsets2_0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: isHost ? Colors.red : Colors.purple,
                ),
                child: Text(
                  isHost ? 'Host' : 'Guest',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),
          ]
        ],
      );
}

class IsmLiveProfileView extends StatelessWidget {
  const IsmLiveProfileView({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.isHost,
  });
  final String imageUrl;
  final String name;
  final bool isHost;

  @override
  Widget build(BuildContext context) => IsmLiveImage.network(
        imageUrl,
        name: name,
        height: 40,
        width: 40,
        isProfileImage: true,
      );
}
