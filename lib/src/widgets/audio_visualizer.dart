import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:livekit_client/livekit_client.dart' as lk;

/// Audio visualizer widget that shows pulsing animation when audio is active
class IsmLiveAudioVisualizer extends StatefulWidget {
  const IsmLiveAudioVisualizer({
    super.key,
    required this.participant,
    this.size = 80,
    this.activeColor,
    this.inactiveColor,
  });

  final lk.Participant participant;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  @override
  State<IsmLiveAudioVisualizer> createState() =>
      _IsmLiveAudioVisualizerState();
}

class _IsmLiveAudioVisualizerState extends State<IsmLiveAudioVisualizer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.repeat(reverse: true);

    // Listen to audio level changes
    widget.participant.addListener(_checkAudioLevel);
    _checkAudioLevel();
  }

  @override
  void dispose() {
    widget.participant.removeListener(_checkAudioLevel);
    _controller.dispose();
    super.dispose();
  }

  void _checkAudioLevel() {
    // Prefer LiveKit's speaking detection if available
    bool hasActiveAudio = false;
    try {
      // isSpeaking exists on LiveKit participants
      // ignore: invalid_use_of_protected_member
      // ignore: invalid_use_of_visible_for_testing_member
      final dynamic p = widget.participant;
      if (p is lk.Participant) {
        // Some SDK versions expose isSpeaking via mixin; wrap in try
        hasActiveAudio = (p.isSpeaking == true);
      }
    } catch (_) {
      hasActiveAudio = false;
    }

    // Fallback: any unmuted audio publication
    if (!hasActiveAudio) {
      for (var trackPub in widget.participant.audioTrackPublications) {
        if (trackPub.track != null && !trackPub.muted) {
          hasActiveAudio = true;
          break;
        }
      }
    }

    if (hasActiveAudio != _isSpeaking) {
      setState(() {
        _isSpeaking = hasActiveAudio;
      });
      if (_isSpeaking) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.reset();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = widget.activeColor ?? IsmLiveColors.red;
    final inactiveColor = widget.inactiveColor ?? Colors.white.withOpacity(0.3);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final ringColor = _isSpeaking ? activeColor : inactiveColor;
        final ringWidth = _isSpeaking ? 3.0 + (_animation.value - 1.0) * 2 : 2.0;
        return Transform.scale(
          scale: _isSpeaking ? _animation.value : 1.0,
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent, // keep image visible
              border: Border.all(color: ringColor, width: ringWidth),
              boxShadow: _isSpeaking
                  ? [
                      BoxShadow(
                        color: activeColor.withOpacity(0.35),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
          ),
        );
      },
    );
  }
}

/// Audio waveform visualizer showing bars
class IsmLiveAudioWaveform extends StatelessWidget {
  const IsmLiveAudioWaveform({
    super.key,
    required this.isActive,
    this.barCount = 5,
    this.height = 40,
    this.activeColor,
    this.inactiveColor,
  });

  final bool isActive;
  final int barCount;
  final double height;
  final Color? activeColor;
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    final activeColor = this.activeColor ?? IsmLiveColors.red;
    final inactiveColor = this.inactiveColor ?? Colors.white.withOpacity(0.3);

    return SizedBox(
      height: height,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: List.generate(barCount, (index) {
          return AnimatedContainer(
            duration: Duration(milliseconds: 100 + (index * 50)),
            margin: const EdgeInsets.symmetric(horizontal: 2),
            width: 4,
            height: isActive
                ? height * (0.3 + (index % 3) * 0.2)
                : height * 0.2,
            decoration: BoxDecoration(
              color: isActive ? activeColor : inactiveColor,
              borderRadius: BorderRadius.circular(2),
            ),
          );
        }),
      ),
    );
  }
}

