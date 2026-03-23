import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:video_player/video_player.dart';

/// Bottom bar: progress bar, play/pause, seek.
class IsmLiveStreamRecordingBottomControls extends StatefulWidget {
  const IsmLiveStreamRecordingBottomControls({
    super.key,
    required this.recording,
    required this.config,
    required this.videoController,
    required this.onPlayPause,
  });

  final IsmLiveStreamRecordingItem recording;
  final IsmLiveStreamRecordingPlayerConfig config;
  final VideoPlayerController? videoController;
  final VoidCallback onPlayPause;

  @override
  State<IsmLiveStreamRecordingBottomControls> createState() =>
      _IsmLiveStreamRecordingBottomControlsState();
}

class _IsmLiveStreamRecordingBottomControlsState
    extends State<IsmLiveStreamRecordingBottomControls> {
  @override
  void initState() {
    super.initState();
    widget.videoController?.addListener(_listener);
  }

  @override
  void didUpdateWidget(IsmLiveStreamRecordingBottomControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoController != widget.videoController) {
      oldWidget.videoController?.removeListener(_listener);
      widget.videoController?.addListener(_listener);
    }
  }

  void _listener() {
    if (!mounted) return;
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
      return;
    }
    setState(() {});
  }

  @override
  void dispose() {
    widget.videoController?.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const iconColor = Colors.white;
    final controller = widget.videoController;
    final position = controller?.value.position ?? Duration.zero;
    final duration = controller?.value.duration ?? Duration.zero;

    Widget buildControl(
      IsmLiveStreamRecordingControlWidgetSlot slot,
      Widget defaultChild, {
      VoidCallback? onTap,
    }) =>
        widget.config.controlWidgetBuilder?.call(
          context,
          slot,
          widget.recording,
          widget.config,
          defaultChild,
          onTap: onTap,
          videoController: controller,
        ) ??
        defaultChild;

    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        bottom: MediaQuery.paddingOf(context).bottom + 12,
        top: 12,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black54, Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              buildControl(
                IsmLiveStreamRecordingControlWidgetSlot.bottomPlayPause,
                IconButton(
                  icon: Icon(
                    controller?.value.isPlaying == true
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: iconColor,
                  ),
                  onPressed: widget.onPlayPause,
                ),
                onTap: widget.onPlayPause,
              ),
              Expanded(
                child: buildControl(
                  IsmLiveStreamRecordingControlWidgetSlot.bottomSeekBar,
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Colors.white,
                      inactiveTrackColor: Colors.white38,
                      thumbColor: Colors.white,
                    ),
                    child: Slider(
                      value: position.inMilliseconds.toDouble(),
                      max: duration.inMilliseconds > 0
                          ? duration.inMilliseconds.toDouble()
                          : 1,
                      onChanged: (v) {
                        controller?.seekTo(
                          Duration(milliseconds: v.round()),
                        );
                      },
                    ),
                  ),
                ),
              ),
              buildControl(
                IsmLiveStreamRecordingControlWidgetSlot.bottomDuration,
                Text(
                  '${_formatDuration(position)} / ${_formatDuration(duration)}',
                  style: theme.textTheme.bodySmall?.copyWith(color: iconColor),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
