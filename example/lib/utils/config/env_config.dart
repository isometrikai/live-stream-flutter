import 'package:appscrip_live_stream_component_example/utils/utils.dart';
import 'package:flutter/material.dart';

class EnvConfig {
  const EnvConfig({
    required this.appTitle,
    this.theme,
    this.themeMode,
    required this.appFlavor,
    this.commConfig,
  });

  final String appTitle;
  final ThemeData? theme;
  final ThemeMode? themeMode;
  final AppFlavor appFlavor;
  final CommunicationConfig? commConfig;
}
