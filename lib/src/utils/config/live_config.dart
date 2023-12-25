import 'package:appscrip_live_stream_component/src/utils/utils.dart';
import 'package:flutter/widgets.dart';

class IsmLiveConfig extends StatelessWidget {
  const IsmLiveConfig({
    super.key,
    required this.data,
    required this.child,
  });

  final IsmLiveConfigData data;
  final Widget child;

  static IsmLiveConfigData of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_InheritedLiveConfig>()!
      .config
      .data;

  @override
  Widget build(BuildContext context) => _InheritedLiveConfig(
        config: this,
        child: child,
      );
}

class _InheritedLiveConfig extends InheritedWidget {
  const _InheritedLiveConfig({
    required this.config,
    required super.child,
  });

  final IsmLiveConfig config;

  @override
  bool updateShouldNotify(covariant _InheritedLiveConfig oldWidget) =>
      oldWidget.config.data != config.data;
}
