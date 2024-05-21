import 'dart:async';

import 'package:flutter/material.dart';

/// Class to call the api after specific amount of time
class IsmLiveDebouncer {
  IsmLiveDebouncer({this.durationtime});
  int? durationtime;
  Timer? _timer;
  void run(VoidCallback action) {
    if (null != _timer) {
      _timer!.cancel();
    }
    _timer = Timer(Duration(milliseconds: durationtime ?? 750), action);
  }
}
