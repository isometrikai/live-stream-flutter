import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/widgets.dart';

class IsmLiveProperties extends StatelessWidget {
  const IsmLiveProperties({
    super.key,
    required this.data,
    required this.child,
  });

  static IsmLivePropertiesData? maybeOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_InheritedLiveProperties>()
      ?.properties
      .data;

  static IsmLivePropertiesData of(BuildContext context) {
    final result = maybeOf(context);
    assert(result != null, 'No IsmLivePropertiesData found in the context');
    return result!;
  }

  final IsmLivePropertiesData data;
  final Widget child;

  @override
  Widget build(BuildContext context) => _InheritedLiveProperties(
        properties: this,
        child: child,
      );
}

class _InheritedLiveProperties extends InheritedTheme {
  const _InheritedLiveProperties({
    required this.properties,
    required super.child,
  });

  final IsmLiveProperties properties;

  @override
  bool updateShouldNotify(covariant _InheritedLiveProperties oldWidget) =>
      oldWidget.properties.data != properties.data;

  @override
  Widget wrap(BuildContext context, Widget child) => IsmLiveProperties(
        data: properties.data,
        child: child,
      );
}
