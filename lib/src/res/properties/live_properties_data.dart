import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/foundation.dart';

class IsmLivePropertiesData with Diagnosticable {
  const IsmLivePropertiesData({
    this.streamProperties,
  });

  final IsmLiveStreamProperties? streamProperties;
}
