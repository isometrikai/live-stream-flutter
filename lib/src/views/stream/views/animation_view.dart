import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class IsmLiveAnimationView extends StatefulWidget {
  const IsmLiveAnimationView({
    super.key,
    required this.child,
    this.duration,
    this.onComplete,
  });

  final Widget child;
  final int? duration;
  final VoidCallback? onComplete;

  @override
  State<IsmLiveAnimationView> createState() => _IsmLiveAnimationViewState();
}

class _IsmLiveAnimationViewState extends State<IsmLiveAnimationView> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  IsmLiveCounterProperties? streamProperties;

  final RxBool _isCompleted = false.obs;
  bool get isCompleted => _isCompleted.value;
  set isCompleted(bool value) => _isCompleted.value = value;

  Timer? timer;

  int get duration => widget.duration ?? streamProperties?.animationTime ?? IsmLiveConstants.animationTime;

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
    IsmLiveUtility.updateLater(start, false);
  }

  void setup() {
    startTime = DateTime.now();
    streamProperties = context.liveProperties?.streamProperties?.counterProperties;
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
    controller.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: controller,
        builder: (context, child) => AnimatedPositioned(
          duration: const Duration(seconds: 1),
          bottom: animation.value.verticalPosition,
          right: animation.value.horizontalPosition,
          child: Obx(
            () => Offstage(
              offstage: isCompleted,
              child: widget.child,
            ),
          ),
        ),
      );
}
