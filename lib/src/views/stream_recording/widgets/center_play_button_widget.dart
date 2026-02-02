import 'package:flutter/material.dart';

/// Center play/pause overlay button.
class IsmLiveStreamRecordingCenterPlayButton extends StatelessWidget {
  const IsmLiveStreamRecordingCenterPlayButton({
    super.key,
    required this.isPlaying,
  });

  final bool isPlaying;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.black45,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: Colors.white,
          size: 48,
        ),
      );
}
