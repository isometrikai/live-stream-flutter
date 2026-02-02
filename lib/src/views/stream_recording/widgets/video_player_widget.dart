import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Wraps [VideoPlayer] with loading and error/retry UI.
class IsmLiveStreamRecordingVideoWidget extends StatefulWidget {
  const IsmLiveStreamRecordingVideoWidget({
    super.key,
    this.controller,
  });

  final VideoPlayerController? controller;

  @override
  State<IsmLiveStreamRecordingVideoWidget> createState() =>
      _IsmLiveStreamRecordingVideoWidgetState();
}

class _IsmLiveStreamRecordingVideoWidgetState
    extends State<IsmLiveStreamRecordingVideoWidget> {
  @override
  void didUpdateWidget(IsmLiveStreamRecordingVideoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      widget.controller?.addListener(_listener);
      oldWidget.controller?.removeListener(_listener);
    }
  }

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_listener);
  }

  void _listener() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    if (controller == null) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (controller.value.hasError) {
      return ColoredBox(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 48),
              const SizedBox(height: 16),
              Text(
                'Failed to load video',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: controller.initialize,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (!controller.value.isInitialized) {
      return const ColoredBox(
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: controller.value.size.width,
        height: controller.value.size.height,
        child: VideoPlayer(controller),
      ),
    );
  }
}
