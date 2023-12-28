import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';

enum IsmLiveRequestType {
  get,
  post,
  put,
  patch,
  delete,
  upload;
}

enum IsmLiveConnectionState {
  connected,
  disconnected,
  connecting,
  subscribed,
  unsubscribed;

  @override
  String toString() => '${name[0].toUpperCase()}${name.substring(1).toLowerCase()}';
}

enum SimulateScenarioResult {
  signalReconnect,
  nodeFailure,
  migration,
  serverLeave,
  switchCandidate,
  clear,
  e2eeKeyRatchet,
}

enum IsmLiveMessageType {
  error,
  success,
  information;
}

enum IsmLiveButtonType {
  primary,
  secondary,
  outlined,
  text;
}

enum IsmLiveImageType {
  asset,
  svg,
  file,
  network;
}

enum IsmLiveStatsType {
  unknown,
  audioSender,
  videoSender,
  audioReceiver,
  videoReceiver,
}

enum IsmLiveCustomType {
  videoCall('VideoCall'),
  audioCall('AudioCall');

  factory IsmLiveCustomType.fromValue(String data) =>
      {
        IsmLiveCustomType.videoCall.value: IsmLiveCustomType.videoCall,
        IsmLiveCustomType.audioCall.value: IsmLiveCustomType.audioCall,
      }[data] ??
      IsmLiveCustomType.videoCall;

  const IsmLiveCustomType(this.value);
  final String value;
}

enum IsmLiveMeetingType {
  videoCall(0),
  audioCall(1);

  factory IsmLiveMeetingType.fromValue(int data) =>
      {
        IsmLiveMeetingType.videoCall.value: IsmLiveMeetingType.videoCall,
        IsmLiveMeetingType.audioCall.value: IsmLiveMeetingType.audioCall,
      }[data] ??
      IsmLiveMeetingType.videoCall;

  const IsmLiveMeetingType(this.value);
  final int value;
}

enum IsmLiveCallType {
  one2one,
  liveStream;
}

enum IsmLiveEngineType {
  agora,
  livekit,
}

enum IsmLiveStreamType {
  all(0, IsmLiveStrings.all),
  audioOnly(1, IsmLiveStrings.audioOnly),
  multilive(2, IsmLiveStrings.multiLive),
  private(3, IsmLiveStrings.private),
  ecommerce(4, IsmLiveStrings.ecommerce),
  restream(5, IsmLiveStrings.reStream),
  hd(6, IsmLiveStrings.hd),
  recorded(7, IsmLiveStrings.recorded);

  const IsmLiveStreamType(this.value, this.label);
  final int value;
  final String label;
}

enum IsmLiveActions {
  streamStart('streamStartPresence');

  factory IsmLiveActions.fromString(String action) =>
      <String, IsmLiveActions>{
        IsmLiveActions.streamStart.value: IsmLiveActions.streamStart,
      }[action] ??
      IsmLiveActions.streamStart;

  const IsmLiveActions(this.value);
  final String value;
}
