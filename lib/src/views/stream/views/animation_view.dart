import 'dart:async';
import 'dart:math' as math;

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class IsmLiveAnimationView extends StatefulWidget {
  IsmLiveAnimationView({
    super.key,
    required this.child,
    this.duration,
    this.onComplete,
    this.verticalHeightFactor = 1.1,
    this.fadeOutAtEnd = false,
  });

  final Widget child;
  final int? duration;
  final VoidCallback? onComplete;

  /// Fraction of screen height used for vertical travel over the animation (0→1).
  /// Hearts use a lower value for a shorter float path.
  final double verticalHeightFactor;

  /// When true, opacity eases to 0 in the last segment before the widget completes.
  final bool fadeOutAtEnd;

  @override
  State<IsmLiveAnimationView> createState() => _IsmLiveAnimationViewState();
}

class _IsmLiveAnimationViewState extends State<IsmLiveAnimationView>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;
  Animation<double>? _fadeOpacity;
  CurvedAnimation? _fadeCurve;

  IsmLiveCounterProperties? streamProperties;

  final RxBool _isCompleted = false.obs;
  bool get isCompleted => _isCompleted.value;
  set isCompleted(bool value) => _isCompleted.value = value;

  Timer? timer;

  int get duration =>
      widget.duration ??
      streamProperties?.animationTime ??
      IsmLiveConstants.animationTime;

  late DateTime startTime;

  @override
  void initState() {
    super.initState();
    IsmLiveUtility.updateLater(setup, false);
    controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: duration),
    );
    animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.ease,
    ))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          IsmLiveLog.error('Animation completed');
          widget.onComplete?.call();
        } else if (status == AnimationStatus.dismissed) {
          IsmLiveLog.error('Animation Dismissed');
        }
      });

    if (widget.fadeOutAtEnd) {
      _fadeCurve = CurvedAnimation(
        parent: controller,
        curve: const Interval(0.74, 1.0, curve: Curves.easeOut),
      );
      _fadeOpacity =
          Tween<double>(begin: 1.0, end: 0.0).animate(_fadeCurve!);
    }

    IsmLiveUtility.updateLater(start, false);
  }

  void setup() {
    startTime = DateTime.now();
    streamProperties =
        context.liveProperties?.streamProperties?.counterProperties;
  }

  void start() async {
    timer = Timer.periodic(const Duration(milliseconds: 300), (t) {
      final diff = DateTime.now().difference(startTime);
      if (diff >= Duration(seconds: duration)) {
        isCompleted = true;
        t.cancel();
      }
    });
    unawaited(controller.forward());
  }

  @override
  void dispose() {
    _fadeCurve?.dispose();
    controller.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          final bottom = animation.value.verticalPosition(
            context,
            heightFactor: widget.verticalHeightFactor,
          );
          final right = animation.value.horizontalPosition(context);
          var visual = widget.child;
          final fade = _fadeOpacity;
          if (fade != null) {
            visual = FadeTransition(opacity: fade, child: visual);
          }
          return AnimatedPositioned(
            duration: const Duration(seconds: 1),
            bottom: bottom,
            right: right,
            child: Obx(
              () => Offstage(
                offstage: isCompleted,
                // Below AnimatedPositioned so Stack parent data stays valid; still
                // blocks hearts from stealing taps on the message row.
                child: IgnorePointer(child: visual),
              ),
            ),
          );
        },
      );
}

/// Lightweight floating-heart animation with deterministic motion parameters.
class IsmLiveFloatingHeartView extends StatefulWidget {
  const IsmLiveFloatingHeartView({
    super.key,
    required this.child,
    required this.durationMs,
    required this.startX,
    required this.maxHorizontalDrift,
    required this.pathVariant,
    required this.travelHeightFactor,
    this.onComplete,
  });

  final Widget child;
  final int durationMs;
  final double startX;
  final double maxHorizontalDrift;
  final int pathVariant;
  final double travelHeightFactor;
  final VoidCallback? onComplete;

  @override
  State<IsmLiveFloatingHeartView> createState() => _IsmLiveFloatingHeartViewState();
}

class _IsmLiveFloatingHeartViewState extends State<IsmLiveFloatingHeartView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: widget.durationMs),
  )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onComplete?.call();
      }
    });

  static final double _bottomInset = IsmLiveDimens.seventy;

  @override
  void initState() {
    super.initState();
    unawaited(_controller.forward());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        child: RepaintBoundary(
          child: IgnorePointer(child: widget.child),
        ),
        builder: (context, child) {
          final t = _controller.value;
          final curveT = Curves.easeOut.transform(t);
          final screenHeight = MediaQuery.of(context).size.height;
          final pathPhase = widget.pathVariant * (math.pi / 3);
          final lateralWave = math.sin((curveT * math.pi * 1.75) + pathPhase) *
              widget.maxHorizontalDrift *
              (1 - (curveT * 0.5));
          final right = 18 + widget.startX + lateralWave;
          final bottom =
              _bottomInset + (screenHeight * widget.travelHeightFactor * curveT);
          final scale = 0.9 + (0.35 * curveT);
          final opacity = curveT < 0.75 ? 1.0 : (1 - ((curveT - 0.75) / 0.25));

          return Positioned(
            bottom: bottom,
            right: right,
            child: Opacity(
              opacity: opacity.clamp(0.0, 1.0),
              child: Transform.scale(
                scale: scale,
                child: child,
              ),
            ),
          );
        },
      );
}
