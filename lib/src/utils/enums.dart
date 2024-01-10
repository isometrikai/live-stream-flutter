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

enum IsmLiveSnackbarType {
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

enum IsmLiveCallType {
  videoCall('VideoCall'),
  audioCall('AudioCall');

  factory IsmLiveCallType.fromValue(String data) =>
      {
        IsmLiveCallType.videoCall.value: IsmLiveCallType.videoCall,
        IsmLiveCallType.audioCall.value: IsmLiveCallType.audioCall,
      }[data] ??
      IsmLiveCallType.videoCall;

  const IsmLiveCallType(this.value);
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
  copublishRequestAccepted('copublishRequestAccepted'),
  copublishRequestAdded('copublishRequestAdded'),
  copublishRequestDenied('copublishRequestDenied'),
  copublishRequestRemoved('copublishRequestRemoved'),
  memberAdded('memberAdded'),
  memberLeft('memberLeft'),
  memberRemoved('memberRemoved'),
  messageRemoved('messageRemoved'),
  messageReplyRemoved('messageReplyRemoved'),
  messageReplySent('messageReplySent'),
  messageSent('messageSent'),
  moderatorAdded('moderatorAdded'),
  moderatorLeft('moderatorLeft'),
  moderatorRemoved('moderatorRemoved'),
  profileSwitched('profileSwitched'),
  publisherTimeout('publisherTimeout'),
  publishStarted('publishStarted'),
  publishStopped('publishStopped'),
  streamStarted('streamStarted'),
  streamStopped('streamStopped'),
  streamStartPresence('streamStartPresence'),
  viewerJoined('viewerJoined'),
  viewerLeft('viewerLeft'),
  viewerRemoved('viewerRemoved'),
  viewerTimeout('viewerTimeout');

  factory IsmLiveActions.fromString(String action) =>
      <String, IsmLiveActions>{
        IsmLiveActions.copublishRequestAccepted.value: IsmLiveActions.copublishRequestAccepted,
        IsmLiveActions.copublishRequestAdded.value: IsmLiveActions.copublishRequestAdded,
        IsmLiveActions.copublishRequestDenied.value: IsmLiveActions.copublishRequestDenied,
        IsmLiveActions.copublishRequestRemoved.value: IsmLiveActions.copublishRequestRemoved,
        IsmLiveActions.memberAdded.value: IsmLiveActions.memberAdded,
        IsmLiveActions.memberLeft.value: IsmLiveActions.memberLeft,
        IsmLiveActions.memberRemoved.value: IsmLiveActions.memberRemoved,
        IsmLiveActions.messageRemoved.value: IsmLiveActions.messageRemoved,
        IsmLiveActions.messageReplyRemoved.value: IsmLiveActions.messageReplyRemoved,
        IsmLiveActions.messageReplySent.value: IsmLiveActions.messageReplySent,
        IsmLiveActions.messageSent.value: IsmLiveActions.messageSent,
        IsmLiveActions.moderatorAdded.value: IsmLiveActions.moderatorAdded,
        IsmLiveActions.moderatorLeft.value: IsmLiveActions.moderatorLeft,
        IsmLiveActions.moderatorRemoved.value: IsmLiveActions.moderatorRemoved,
        IsmLiveActions.profileSwitched.value: IsmLiveActions.profileSwitched,
        IsmLiveActions.publisherTimeout.value: IsmLiveActions.publisherTimeout,
        IsmLiveActions.publishStarted.value: IsmLiveActions.publishStarted,
        IsmLiveActions.publishStopped.value: IsmLiveActions.publishStopped,
        IsmLiveActions.streamStarted.value: IsmLiveActions.streamStarted,
        IsmLiveActions.streamStopped.value: IsmLiveActions.streamStopped,
        IsmLiveActions.streamStartPresence.value: IsmLiveActions.streamStartPresence,
        IsmLiveActions.viewerJoined.value: IsmLiveActions.viewerJoined,
        IsmLiveActions.viewerLeft.value: IsmLiveActions.viewerLeft,
        IsmLiveActions.viewerRemoved.value: IsmLiveActions.viewerRemoved,
        IsmLiveActions.viewerTimeout.value: IsmLiveActions.viewerTimeout,
      }[action] ??
      IsmLiveActions.streamStartPresence;

  const IsmLiveActions(this.value);
  final String value;
}

enum IsmLiveStreamOption {
  gift(IsmLiveAssetConstants.gift),
  multiLive(IsmLiveAssetConstants.multi),
  share(IsmLiveAssetConstants.share),
  members(IsmLiveAssetConstants.members),
  favourite(IsmLiveAssetConstants.favourite),
  settings(IsmLiveAssetConstants.setting),
  rotateCamera(IsmLiveAssetConstants.rotateCamera),
  speaker(IsmLiveAssetConstants.speakerOn),
  vs(IsmLiveAssetConstants.vs);

  const IsmLiveStreamOption(this.icon);

  final String icon;
  static List<IsmLiveStreamOption> get viewersOptions => [
        IsmLiveStreamOption.gift,
        IsmLiveStreamOption.share,
        IsmLiveStreamOption.speaker,
        IsmLiveStreamOption.multiLive,
      ];

  static List<IsmLiveStreamOption> get hostOptions => [
        IsmLiveStreamOption.members,
        IsmLiveStreamOption.multiLive,
        IsmLiveStreamOption.vs,
        IsmLiveStreamOption.share,
        IsmLiveStreamOption.favourite,
        IsmLiveStreamOption.rotateCamera,
        IsmLiveStreamOption.settings,
      ];
}

enum IsmLiveMessageType {
  normal(0),
  heart(1),
  gift(2),
  remove(3),
  presence(4);

  factory IsmLiveMessageType.fromValue(int data) =>
      <int, IsmLiveMessageType>{
        IsmLiveMessageType.normal.value: IsmLiveMessageType.normal,
        IsmLiveMessageType.heart.value: IsmLiveMessageType.heart,
        IsmLiveMessageType.gift.value: IsmLiveMessageType.gift,
        IsmLiveMessageType.remove.value: IsmLiveMessageType.remove,
        IsmLiveMessageType.presence.value: IsmLiveMessageType.presence,
      }[data] ??
      IsmLiveMessageType.normal;

  const IsmLiveMessageType(this.value);
  final int value;
}

enum IsmLiveCustomType {
  custom1;

  factory IsmLiveCustomType.fromName(String data) =>
      <String, IsmLiveCustomType>{
        IsmLiveCustomType.custom1.name: IsmLiveCustomType.custom1,
      }[data] ??
      IsmLiveCustomType.custom1;
}
