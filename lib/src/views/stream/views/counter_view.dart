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
  late AnimationController controller;
  late Animation<double> animation;

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
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    animation = Tween<double>(
      begin: 0.5,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOutBack,
    ));
    start();
  }

  void start() async {
    _counter.stream.listen((value) {
      controller.reset();
      controller.forward();
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
      controller.forward();
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
          child: SizedBox(
            height: Get.height,
            width: Get.width,
            child: ColoredBox(
              color: Colors.black38,
              child: Center(
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (context, child) => ScaleTransition(
                    scale: animation,
                    child: Text(
                      counter == 0 ? IsmLiveTranslations.of(context).streamTranslations?.youreLive ?? IsmLiveStrings.youreLive : counter.toString(),
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
