import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';

class IsmLiveStream extends StatelessWidget {
  const IsmLiveStream({
    super.key,
    required this.configuration,
    this.onCallStart,
    this.onCallEnd,
  });

  final IsmLiveStreamConfig configuration;
  final VoidCallback? onCallStart;
  final VoidCallback? onCallEnd;

  @override
  Widget build(BuildContext context) => MyMeetingsView(
        configuration: configuration,
      );
}
