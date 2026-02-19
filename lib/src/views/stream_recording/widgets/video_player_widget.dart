import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = context.liveTheme?.backgroundColor ??
        (isDarkMode ? const Color(0xFF121212) : Colors.black);
    final fgColor = context.liveTheme?.primaryColor ??
        (isDarkMode ? Colors.white : Colors.white);

    final controller = widget.controller;
    if (controller == null) {
      return ColoredBox(
        color: bgColor,
        child: Center(
          child: CircularProgressIndicator(color: fgColor),
        ),
      );
    }

    if (controller.value.hasError) {
      return ColoredBox(
        color: bgColor,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: fgColor, size: 48),
              const SizedBox(height: 16),
              Text(
                IsmLiveStrings.failedToLoadVideo,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: fgColor,
                    ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: controller.initialize,
                child: const Text(IsmLiveStrings.retry),
              ),
            ],
          ),
        ),
      );
    }

    if (!controller.value.isInitialized) {
      return ColoredBox(
        color: bgColor,
        child: Center(
          child: CircularProgressIndicator(color: fgColor),
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
