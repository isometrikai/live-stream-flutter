import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLiveCounterView extends StatefulWidget {
  const IsmLiveCounterView({
    super.key,
    this.duration = 3,
    this.onComplete,
  });

  final int duration;
  final VoidCallback? onComplete;

  @override
  State<IsmLiveCounterView> createState() => _IsmLiveCounterViewState();
}

class _IsmLiveCounterViewState extends State<IsmLiveCounterView> with SingleTickerProviderStateMixin {
  late AnimationController scaleController;
  late Animation<double> scaleAnimation;

  final RxInt _counter = 0.obs;
  int get counter => _counter.value;
  set counter(int value) => _counter.value = value;

  final RxBool _isCompleted = false.obs;
  bool get isCompleted => _isCompleted.value;
  set isCompleted(bool value) => _isCompleted.value = value;

  Timer? timer;

  @override
  void initState() {
    super.initState();
    counter = widget.duration;
    scaleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: scaleController,
      curve: Curves.easeInOutBack,
    ));
    start();
  }

  void start() async {
    _counter.stream.listen((value) {
      IsmLiveLog('OnListen $value');
      scaleController.reset();
      scaleController.forward();
    });
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (counter == 0) {
        t.cancel();
        isCompleted = true;
        widget.onComplete?.call();
        return;
      }
      counter--;
    });
    IsmLiveUtility.updateLater(() {
      scaleController.forward();
    });
  }

  @override
  void dispose() {
    scaleController.dispose();
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Obx(
        () => Offstage(
          offstage: isCompleted,
          child: SizedBox(
            height: Get.height,
            width: Get.width,
            child: ColoredBox(
              color: Colors.black38,
              child: Center(
                child: AnimatedBuilder(
                  animation: scaleController,
                  builder: (context, child) => ScaleTransition(
                    scale: scaleAnimation,
                    child: Text(
                      counter == 0 ? 'You\'re Live!' : counter.toString(),
                      style: IsmLiveStyles.whiteBold25,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
}
