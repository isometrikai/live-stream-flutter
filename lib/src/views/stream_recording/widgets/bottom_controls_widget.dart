import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

/// Bottom bar: product strip, progress bar, play/pause, seek.
class IsmLiveStreamRecordingBottomControls extends StatefulWidget {
  const IsmLiveStreamRecordingBottomControls({
    super.key,
    required this.videoController,
    required this.products,
    required this.onPlayPause,
    required this.onAllProducts,
  });

  final VideoPlayerController? videoController;
  final List<IsmLiveStreamRecordingProduct> products;
  final VoidCallback onPlayPause;
  final VoidCallback onAllProducts;

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
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.videoController?.removeListener(_listener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = widget.videoController;
    final position = controller?.value.position ?? Duration.zero;
    final duration = controller?.value.duration ?? Duration.zero;

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
          if (widget.products.isNotEmpty) ...[
            SizedBox(
              height: 64,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.products.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  if (index == widget.products.length) {
                    return GestureDetector(
                      onTap: widget.onAllProducts,
                      child: Container(
                        width: 64,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(Icons.grid_view, color: Colors.white),
                        ),
                      ),
                    );
                  }
                  final product = widget.products[index];
                  return _ProductChip(
                    product: product,
                    onTap: widget.onAllProducts,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            children: [
              IconButton(
                icon: Icon(
                  controller?.value.isPlaying == true
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.white,
                ),
                onPressed: widget.onPlayPause,
              ),
              Expanded(
                child: SliderTheme(
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
              Text(
                '${_formatDuration(position)} / ${_formatDuration(duration)}',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.white),
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

class _ProductChip extends StatelessWidget {
  const _ProductChip({
    required this.product,
    required this.onTap,
  });

  final IsmLiveStreamRecordingProduct product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white38),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                ? Image.network(
                    product.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.image_not_supported,
                      color: Colors.white54,
                    ),
                  )
                : const Icon(Icons.image, color: Colors.white54),
          ),
        ),
      );
}
