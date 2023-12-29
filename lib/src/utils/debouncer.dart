import 'dart:async';

import 'package:flutter/material.dart';

/// Class to call the api after specific amount of time
class IsmLiveDebouncer {
  IsmLiveDebouncer();

  Timer? _timer;
  void run(VoidCallback action) {
    if (null != _timer) {
      _timer!.cancel();
    }
    _timer = Timer(const Duration(milliseconds: 750), action);
  }
}
