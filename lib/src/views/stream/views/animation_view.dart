import 'dart:async';

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
