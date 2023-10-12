import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';

/// This class will be used for providing all configuration
/// for the live stream module
class IsmLiveStreamConfig {
  const IsmLiveStreamConfig({
    required this.communicationConfig,
    required this.userConfig,
  });

  final IsmLiveCommunicationConfig communicationConfig;
  final IsmLiveUserConfig userConfig;
}
