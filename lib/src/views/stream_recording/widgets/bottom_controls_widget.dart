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
  static const Duration _seekThrottleDuration = Duration(milliseconds: 140);

  bool _isDragging = false;
  double _dragPositionMs = 0;
  bool _wasPlayingBeforeDrag = false;
  DateTime _lastPreviewSeekAt = DateTime.fromMillisecondsSinceEpoch(0);

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
    final value = controller?.value;
    final actualPosition = value?.position ?? Duration.zero;
    final duration = value?.duration ?? Duration.zero;
    final showPause = value != null && value.isPlaying && !value.isBuffering;
    final maxMs = duration.inMilliseconds > 0 ? duration.inMilliseconds : 1;
    final currentSliderMs = (_isDragging
            ? _dragPositionMs.clamp(0, maxMs.toDouble())
            : actualPosition.inMilliseconds
                .toDouble()
                .clamp(0, maxMs.toDouble()))
        .toDouble();
    final displayPosition = Duration(milliseconds: currentSliderMs.round());

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
                    showPause ? Icons.pause_rounded : Icons.play_arrow_rounded,
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
                      value: currentSliderMs,
                      max: maxMs.toDouble(),
                      onChangeStart: (v) {
                        final c = controller;
                        if (c == null) return;
                        _isDragging = true;
                        _dragPositionMs = v;
                        _wasPlayingBeforeDrag =
                            c.value.isPlaying && !c.value.isBuffering;
                        if (_wasPlayingBeforeDrag) {
                          c.pause();
                        }
                        setState(() {});
                      },
                      onChanged: (v) {
                        final c = controller;
                        if (c == null) return;
                        _dragPositionMs = v;
                        _isDragging = true;
                        final now = DateTime.now();
                        if (now.difference(_lastPreviewSeekAt) >=
                            _seekThrottleDuration) {
                          _lastPreviewSeekAt = now;
                          c.seekTo(Duration(milliseconds: v.round()));
                        }
                        setState(() {});
                      },
                      onChangeEnd: (v) async {
                        final c = controller;
                        if (c == null) return;
                        _dragPositionMs = v;
                        _lastPreviewSeekAt =
                            DateTime.fromMillisecondsSinceEpoch(0);
                        await c.seekTo(Duration(milliseconds: v.round()));
                        if (_wasPlayingBeforeDrag) {
                          await c.play();
                        }
                        if (!mounted) return;
                        setState(() {
                          _isDragging = false;
                        });
                      },
                    ),
                  ),
                ),
              ),
              buildControl(
                IsmLiveStreamRecordingControlWidgetSlot.bottomDuration,
                Text(
                  '${_formatDuration(displayPosition)} / ${_formatDuration(duration)}',
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
