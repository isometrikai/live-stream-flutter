import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';

class IsmLiveStreamProperties {
  const IsmLiveStreamProperties({
    this.counterProperties,
  });

  final IsmLiveCounterProperties? counterProperties;

  IsmLiveStreamProperties copyWith({
    IsmLiveCounterProperties? counterProperties,
  }) =>
      IsmLiveStreamProperties(
        counterProperties: counterProperties ?? this.counterProperties,
      );
}
