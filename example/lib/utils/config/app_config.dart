import 'package:appscrip_live_stream_component_example/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AppConfig {
  static Future<void> init(EnvConfig envConfig) async {
    _info = await PackageInfo.fromPlatform();
    _appTitle = envConfig.appTitle;
    _theme = envConfig.theme;
    _themeMode = envConfig.themeMode;
    _appFlavor = envConfig.appFlavor;
    _commConfig = envConfig.commConfig;
  }

  static late PackageInfo _info;

  static String get appVersion => _info.version;

  static late String _appTitle;
  static late ThemeData? _theme;
  static late ThemeMode? _themeMode;
  static late AppFlavor _appFlavor;
  static late CommunicationConfig? _commConfig;

  static String get appTitle => _appTitle;
  static ThemeData? get theme => _theme;
  static ThemeMode? get themeMode => _themeMode;
  static AppFlavor get appFlavor => _appFlavor;
  static CommunicationConfig? get commConfig => _commConfig;
}
