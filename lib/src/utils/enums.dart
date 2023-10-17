enum IsmLiveStreamType {
  nearby('Nearby'),
  pk('PK'),
  popular('Popular'),
  following('Following'),
  paid('Paid'),
  starts('Stars');

  const IsmLiveStreamType(this.label);
  final String label;
}

enum IsmLiveRequestType {
  get,
  post,
  put,
  patch,
  delete,
  upload;
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

enum IsmLiveNavItemType {
  streams,
  reels,
  explore,
  chats,
  profile;
}

enum IsmLiveButtonType {
  primary,
  secondary,
  outlined,
  text;
}

enum IsmLiveImageType {
  asset,
  file,
  network;
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
