import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class IsmLiveGiftView extends StatefulWidget {
  const IsmLiveGiftView({
    super.key,
    required this.child,
    this.duration,
    this.onComplete,
  });

  final Widget child;
  final int? duration;
  final VoidCallback? onComplete;

  @override
  State<IsmLiveGiftView> createState() => _IsmLiveGiftViewState();
}

class _IsmLiveGiftViewState extends State<IsmLiveGiftView> with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  IsmLiveCounterProperties? streamProperties;

  final RxBool _isCompleted = false.obs;
  bool get isCompleted => _isCompleted.value;
  set isCompleted(bool value) => _isCompleted.value = value;

  Timer? timer;

  int get duration => widget.duration ?? streamProperties?.giftTime ?? IsmLiveConstants.giftTime;

  late DateTime startTime;

  @override
  void initState() {
    super.initState();
    IsmLiveUtility.updateLater(setup, false);
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.ease,
    ));
    if (mounted) {
      IsmLiveUtility.updateLater(start, false);
    }
  }

  void setup() {
    startTime = DateTime.now();
    streamProperties = context.liveProperties.streamProperties?.counterProperties;
  }

  void start() async {
    unawaited(controller.forward());
    Future.delayed(Duration(seconds: duration), () {
      controller.reverse().then((value) {
        isCompleted = true;
        widget.onComplete?.call();
      });
    });
  }

  @override
  void dispose() {
    controller.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Obx(
        () => Offstage(
          offstage: isCompleted,
          child: Align(
            alignment: Alignment.center,
            child: SizedBox(
              height: Get.height * 0.5,
              width: Get.width * 0.5,
              child: AnimatedBuilder(
                animation: controller,
                builder: (context, child) => ScaleTransition(
                  scale: animation,
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      );
}
