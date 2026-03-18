import 'package:flutter/material.dart';

/// Lightweight shimmer without external dependencies.
/// Intended for skeleton placeholders only.
class IsmLiveShimmer extends StatefulWidget {
  const IsmLiveShimmer({
    super.key,
    required this.child,
    this.baseColor,
    this.highlightColor,
    this.period = const Duration(milliseconds: 1200),
  });

  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;
  final Duration period;

  @override
  State<IsmLiveShimmer> createState() => _IsmLiveShimmerState();
}

class _IsmLiveShimmerState extends State<IsmLiveShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.period)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final base = widget.baseColor ??
        scheme.surfaceContainerHighest.withValues(alpha: 0.85);
    final highlight =
        widget.highlightColor ?? scheme.surface.withValues(alpha: 0.9);

    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = _controller.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment(-1.0 - 2.0 * t, 0),
            end: Alignment(1.0 - 2.0 * t, 0),
            colors: [base, highlight, base],
            stops: const [0.35, 0.5, 0.65],
          ).createShader(rect),
          child: ColoredBox(
            color: base,
            child: child,
          ),
        );
      },
    );
  }
}

class IsmLiveSkeletonBox extends StatelessWidget {
  const IsmLiveSkeletonBox({
    super.key,
    required this.height,
    required this.width,
    this.radius = 12,
  });

  final double height;
  final double width;
  final double radius;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        width: width,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white, // overridden by [IsmLiveShimmer]
            borderRadius: BorderRadius.circular(radius),
          ),
        ),
      );
}

class IsmLiveSkeletonCircle extends StatelessWidget {
  const IsmLiveSkeletonCircle({super.key, required this.size});

  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: size,
        width: size,
        child: const DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white, // overridden by [IsmLiveShimmer]
            shape: BoxShape.circle,
          ),
        ),
      );
}
