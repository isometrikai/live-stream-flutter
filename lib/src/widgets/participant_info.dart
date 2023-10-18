import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart';

class ParticipantTrack {
  ParticipantTrack(
      {required this.participant,
      required this.videoTrack,
      required this.isScreenShare});
  VideoTrack? videoTrack;
  Participant participant;
  final bool isScreenShare;
}

class ParticipantInfoWidget extends StatelessWidget {
  const ParticipantInfoWidget({
    this.title,
    this.audioAvailable = true,
    this.connectionQuality = ConnectionQuality.unknown,
    this.isScreenShare = false,
    this.enabledE2EE = false,
    Key? key,
  }) : super(key: key);
  //
  final String? title;
  final bool audioAvailable;
  final ConnectionQuality connectionQuality;
  final bool isScreenShare;
  final bool enabledE2EE;

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.black.withOpacity(0.3),
        padding: const EdgeInsets.symmetric(
          vertical: 7,
          horizontal: 10,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (title != null)
              Flexible(
                child: Text(
                  title!,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            isScreenShare
                ? Padding(
                    padding: IsmLiveDimens.edgeInsetsL5,
                    child: const Icon(
                      Icons.monitor,
                      color: Colors.white,
                      size: 16,
                    ),
                  )
                : Padding(
                    padding: IsmLiveDimens.edgeInsetsL5,
                    child: Icon(
                      audioAvailable ? Icons.mic : Icons.mic_off,
                      color: audioAvailable ? Colors.white : Colors.red,
                      size: 16,
                    ),
                  ),
            if (connectionQuality != ConnectionQuality.unknown)
              Padding(
                padding: IsmLiveDimens.edgeInsetsL5,
                child: Icon(
                  connectionQuality == ConnectionQuality.poor
                      ? Icons.wifi_off_outlined
                      : Icons.wifi,
                  color: {
                    ConnectionQuality.excellent: Colors.green,
                    ConnectionQuality.good: Colors.orange,
                    ConnectionQuality.poor: Colors.red,
                  }[connectionQuality],
                  size: 16,
                ),
              ),
            Padding(
              padding: IsmLiveDimens.edgeInsetsL5,
              child: Icon(
                enabledE2EE ? Icons.lock : Icons.lock_open,
                color: enabledE2EE ? Colors.green : Colors.red,
                size: 16,
              ),
            ),
          ],
        ),
      );
}
