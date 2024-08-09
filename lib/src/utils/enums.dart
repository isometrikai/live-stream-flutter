import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:get/get.dart';

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
  disconnected;

  @override
  String toString() =>
      '${name[0].toUpperCase()}${name.substring(1).toLowerCase()}';
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
  icon;
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

enum IsmLivePkUserType {
  publisher('publisher'),
  copublisher('co-publisher');

  const IsmLivePkUserType(this.value);
  final String value;
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

enum IsmLivePkResponce {
  accepted('Invite Accepted'),
  rejected('Invite Rejected');

  factory IsmLivePkResponce.fromValue(String data) =>
      {
        IsmLivePkResponce.accepted.value: IsmLivePkResponce.accepted,
        IsmLivePkResponce.rejected.value: IsmLivePkResponce.rejected,
      }[data] ??
      IsmLivePkResponce.rejected;

  const IsmLivePkResponce(this.value);
  final String value;
}

enum IsmLivePkResponceToSend {
  accepted('Accepted'),
  rejected('Rejected');

  const IsmLivePkResponceToSend(this.value);
  final String value;
}

enum IsmLiveStreamTypes {
  free('Free'),
  premium('Premium');

  const IsmLiveStreamTypes(this.value);
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
  scheduledStreams(1, IsmLiveStrings.scheduled),
  // audioOnly(1, IsmLiveStrings.audioOnly),
  pk(2, IsmLiveStrings.pk),
  // private(3, IsmLiveStrings.private),
  // ecommerce(4, IsmLiveStrings.ecommerce),
  restream(5, IsmLiveStrings.reStream),
  hd(6, IsmLiveStrings.hd),
  recorded(7, IsmLiveStrings.recorded);
  // multilive(8, IsmLiveStrings.multiLive);

  const IsmLiveStreamType(this.value, this.label);
  final int value;
  final String label;
}

enum IsmLiveCoinTransactionType {
  debit(1, IsmLiveStrings.debit),

  credit(2, IsmLiveStrings.credit);

  const IsmLiveCoinTransactionType(this.value, this.label);
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
  pubsubMessagePublished('pubsubMessagePublished'),
  pubsubMessageOnTopicPublished('pubsubMessageOnTopicPublished'),
  pubsubDirectMessagePublished('pubsubDirectMessagePublished'),
  streamStarted('streamStarted'),
  streamStopped('streamStopped'),
  streamStartPresence('streamStartPresence'),
  viewerJoined('viewerJoined'),
  viewerLeft('viewerLeft'),
  viewerRemoved('viewerRemoved'),
  viewerTimeout('viewerTimeout');

  factory IsmLiveActions.fromString(String action) =>
      <String, IsmLiveActions>{
        IsmLiveActions.copublishRequestAccepted.value:
            IsmLiveActions.copublishRequestAccepted,
        IsmLiveActions.copublishRequestAdded.value:
            IsmLiveActions.copublishRequestAdded,
        IsmLiveActions.copublishRequestDenied.value:
            IsmLiveActions.copublishRequestDenied,
        IsmLiveActions.copublishRequestRemoved.value:
            IsmLiveActions.copublishRequestRemoved,
        IsmLiveActions.memberAdded.value: IsmLiveActions.memberAdded,
        IsmLiveActions.memberLeft.value: IsmLiveActions.memberLeft,
        IsmLiveActions.memberRemoved.value: IsmLiveActions.memberRemoved,
        IsmLiveActions.messageRemoved.value: IsmLiveActions.messageRemoved,
        IsmLiveActions.messageReplyRemoved.value:
            IsmLiveActions.messageReplyRemoved,
        IsmLiveActions.messageReplySent.value: IsmLiveActions.messageReplySent,
        IsmLiveActions.messageSent.value: IsmLiveActions.messageSent,
        IsmLiveActions.moderatorAdded.value: IsmLiveActions.moderatorAdded,
        IsmLiveActions.moderatorLeft.value: IsmLiveActions.moderatorLeft,
        IsmLiveActions.moderatorRemoved.value: IsmLiveActions.moderatorRemoved,
        IsmLiveActions.profileSwitched.value: IsmLiveActions.profileSwitched,
        IsmLiveActions.publisherTimeout.value: IsmLiveActions.publisherTimeout,
        IsmLiveActions.publishStarted.value: IsmLiveActions.publishStarted,
        IsmLiveActions.publishStopped.value: IsmLiveActions.publishStopped,
        IsmLiveActions.pubsubDirectMessagePublished.value:
            IsmLiveActions.pubsubDirectMessagePublished,
        IsmLiveActions.pubsubMessagePublished.value:
            IsmLiveActions.pubsubMessagePublished,
        IsmLiveActions.pubsubMessageOnTopicPublished.value:
            IsmLiveActions.pubsubMessageOnTopicPublished,
        IsmLiveActions.streamStarted.value: IsmLiveActions.streamStarted,
        IsmLiveActions.streamStopped.value: IsmLiveActions.streamStopped,
        IsmLiveActions.streamStartPresence.value:
            IsmLiveActions.streamStartPresence,
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
  bars(IsmLiveAssetConstants.bars),
  multiLive(IsmLiveAssetConstants.multi),
  share(IsmLiveAssetConstants.share),
  members(IsmLiveAssetConstants.analytics),
  favourite(IsmLiveAssetConstants.favourite),
  settings(IsmLiveAssetConstants.settings),
  rotateCamera(IsmLiveAssetConstants.rotateCamera),
  speaker(IsmLiveAssetConstants.speakerOn),
  product(IsmLiveAssetConstants.product),
  vs(IsmLiveAssetConstants.vs),
  pk(IsmLiveAssetConstants.pk),
  heart(IsmLiveAssetConstants.heartSvg),
  ;

  const IsmLiveStreamOption(this.icon);

  final String icon;

  ///viewer options
  static List<IsmLiveStreamOption> get viewersOptions =>
      IsmLiveDelegate.viewersOption.isEmpty
          ? [
              IsmLiveStreamOption.gift,
              IsmLiveStreamOption.share,
              IsmLiveStreamOption.speaker,
              IsmLiveStreamOption.multiLive,
              IsmLiveStreamOption.heart,
            ]
          : IsmLiveDelegate.viewersOption;

  ///host options
  static List<IsmLiveStreamOption> get hostOptions =>
      IsmLiveDelegate.hostOptions.isEmpty
          ? [
              IsmLiveStreamOption.members,
              IsmLiveStreamOption.vs,
              IsmLiveStreamOption.multiLive,
              // IsmLiveStreamOption.product,
              IsmLiveStreamOption.share,
              // IsmLiveStreamOption.favourite,
              IsmLiveStreamOption.rotateCamera,
              IsmLiveStreamOption.settings,
            ]
          : IsmLiveDelegate.hostOptions;

  ///rtmp options
  static List<IsmLiveStreamOption> get rtmpOptions =>
      IsmLiveDelegate.rtmpOptions.isEmpty
          ? [
              // IsmLiveStreamOption.members,
              IsmLiveStreamOption.vs,
              IsmLiveStreamOption.multiLive,
              IsmLiveStreamOption.product,
              // IsmLiveStreamOption.share,
              // // IsmLiveStreamOption.favourite,
              // IsmLiveStreamOption.rotateCamera,
              // IsmLiveStreamOption.settings,
            ]
          : IsmLiveDelegate.rtmpOptions;

  ///copublisher options
  static List<IsmLiveStreamOption> get copublisherOptions =>
      IsmLiveDelegate.copublisherOptions.isEmpty
          ? [
              // IsmLiveStreamOption.members,
              // IsmLiveStreamOption.vs,
              // IsmLiveStreamOption.multiLive,
              IsmLiveStreamOption.share,
              IsmLiveStreamOption.rotateCamera,
              IsmLiveStreamOption.settings,
            ]
          : IsmLiveDelegate.copublisherOptions;

  ///pk options
  static List<IsmLiveStreamOption> get pkOptions =>
      IsmLiveDelegate.pkOptions.isEmpty
          ? [
              IsmLiveStreamOption.pk,
              IsmLiveStreamOption.members,
              IsmLiveStreamOption.share,
              IsmLiveStreamOption.rotateCamera,
              IsmLiveStreamOption.settings,
            ]
          : IsmLiveDelegate.pkOptions;
}

enum IsmLiveHostSettings {
  muteMyVideo(IsmLiveAssetConstants.video_camera,
      IsmLiveAssetConstants.video_off, 'Turn Off Video', 'Trun On Video'),
  muteMyAudio(IsmLiveAssetConstants.micro_phone,
      IsmLiveAssetConstants.micro_phone_off, 'Mute', 'Unmute');
  // block(IsmLiveAssetConstants.block, 'Block', 'Unblock'),
  // report(IsmLiveAssetConstants.report, 'Report', '');
  // muteRemoteVideo('Mute remote video', 'Unmute remote video'),
  // muteRemoteAudio('Mute remote audio', 'Unmute remote audio'),
  // showNetWorkStats('Show netWork stats', 'Hide netWork stats'),
  // hideChatMessages('Hide chat messages', 'Show chat messages'),
  // hideControlButtons('Hide control buttons', 'Show control buttons');

  const IsmLiveHostSettings(
      this.icon, this.offIcon, this.muteValues, this.unmuteValues);
  final String muteValues;
  final String unmuteValues;
  final String icon;
  final String offIcon;
}

enum IsmLiveMessageType {
  normal(0),
  heart(3),
  gift(2),
  gift3D(10),
  remove(1),
  pkStart(23),
  pkAccepted(21),
  pk(20),
  pkStop(22),
  presence(4);

  factory IsmLiveMessageType.fromValue(int data) =>
      <int, IsmLiveMessageType>{
        IsmLiveMessageType.normal.value: IsmLiveMessageType.normal,
        IsmLiveMessageType.heart.value: IsmLiveMessageType.heart,
        IsmLiveMessageType.gift.value: IsmLiveMessageType.gift,
        IsmLiveMessageType.gift3D.value: IsmLiveMessageType.gift3D,
        IsmLiveMessageType.remove.value: IsmLiveMessageType.remove,
        IsmLiveMessageType.presence.value: IsmLiveMessageType.presence,
        IsmLiveMessageType.pk.value: IsmLiveMessageType.pk,
        IsmLiveMessageType.pkAccepted.value: IsmLiveMessageType.pkAccepted,
        IsmLiveMessageType.pkStart.value: IsmLiveMessageType.pkStart,
        IsmLiveMessageType.pkStop.value: IsmLiveMessageType.pkStop,
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

enum IsmLiveGiftType {
  normal(IsmLiveStrings.normal),
  threeD(IsmLiveStrings.threeD),
  animated(IsmLiveStrings.animated);

  const IsmLiveGiftType(this.label);
  final String label;

  List<IsmLiveGifts> get gifts {
    switch (this) {
      case IsmLiveGiftType.normal:
        return IsmLiveGifts.normal;
      case IsmLiveGiftType.threeD:
        return IsmLiveGifts.threeD;
      case IsmLiveGiftType.animated:
        return IsmLiveGifts.animated;
    }
  }
}

enum IsmLiveGifts {
  bell(IsmLiveGiftType.normal, IsmLiveAssetConstants.bell),
  cherry(IsmLiveGiftType.normal, IsmLiveAssetConstants.cherry),
  giftImage(IsmLiveGiftType.normal, IsmLiveAssetConstants.giftImage),
  icecream(IsmLiveGiftType.normal, IsmLiveAssetConstants.icecream),
  kiss(IsmLiveGiftType.normal, IsmLiveAssetConstants.kiss),
  lolipop(IsmLiveGiftType.normal, IsmLiveAssetConstants.lolipop),
  paw(IsmLiveGiftType.normal, IsmLiveAssetConstants.paw),
  cake(IsmLiveGiftType.animated, IsmLiveAssetConstants.cake),
  cheers(IsmLiveGiftType.animated, IsmLiveAssetConstants.cheers),
  chest(IsmLiveGiftType.animated, IsmLiveAssetConstants.chest),
  clapping(IsmLiveGiftType.animated, IsmLiveAssetConstants.clapping),
  coin(IsmLiveGiftType.animated, IsmLiveAssetConstants.coin),
  crown(IsmLiveGiftType.animated, IsmLiveAssetConstants.crown),
  cryingLaughter(
      IsmLiveGiftType.animated, IsmLiveAssetConstants.cryingLaughter),
  diamond(IsmLiveGiftType.animated, IsmLiveAssetConstants.diamond),
  goodLife(IsmLiveGiftType.animated, IsmLiveAssetConstants.goodLife),
  heartEyes(IsmLiveGiftType.animated, IsmLiveAssetConstants.heartEyes),
  heart(IsmLiveGiftType.animated, IsmLiveAssetConstants.heart),
  inLove(IsmLiveGiftType.animated, IsmLiveAssetConstants.inLove),
  moneyFlying(IsmLiveGiftType.animated, IsmLiveAssetConstants.moneyFlying),
  money(IsmLiveGiftType.animated, IsmLiveAssetConstants.money),
  party(IsmLiveGiftType.animated, IsmLiveAssetConstants.party),
  present(IsmLiveGiftType.animated, IsmLiveAssetConstants.present),
  rocketLaunch(IsmLiveGiftType.animated, IsmLiveAssetConstants.rocketLaunch),
  rocketSpin(IsmLiveGiftType.animated, IsmLiveAssetConstants.rocketSpin),
  rollingLaughter(
      IsmLiveGiftType.animated, IsmLiveAssetConstants.rollingLaughter),
  star(IsmLiveGiftType.animated, IsmLiveAssetConstants.star),
  thumb(IsmLiveGiftType.animated, IsmLiveAssetConstants.thumb),
  trophy(IsmLiveGiftType.animated, IsmLiveAssetConstants.trophy),
  verified(IsmLiveGiftType.animated, IsmLiveAssetConstants.verified),
  wow(IsmLiveGiftType.animated, IsmLiveAssetConstants.wow),
  yeah(IsmLiveGiftType.animated, IsmLiveAssetConstants.yeah),
  cake3d(IsmLiveGiftType.threeD, IsmLiveAssetConstants.cake3d),
  cheers3d(IsmLiveGiftType.threeD, IsmLiveAssetConstants.cheers3d),
  clapping3d(IsmLiveGiftType.threeD, IsmLiveAssetConstants.clapping3d),
  crown3d(IsmLiveGiftType.threeD, IsmLiveAssetConstants.crown3d),
  fire(IsmLiveGiftType.threeD, IsmLiveAssetConstants.fire),
  fish(IsmLiveGiftType.threeD, IsmLiveAssetConstants.fish),
  happyBirthday(IsmLiveGiftType.threeD, IsmLiveAssetConstants.happyBirthday),
  heartEyes3d(IsmLiveGiftType.threeD, IsmLiveAssetConstants.heartEyes3d),
  love(IsmLiveGiftType.threeD, IsmLiveAssetConstants.love),
  money3d(IsmLiveGiftType.threeD, IsmLiveAssetConstants.money3d),
  partyPopper(IsmLiveGiftType.threeD, IsmLiveAssetConstants.partyPopper),
  rocket(IsmLiveGiftType.threeD, IsmLiveAssetConstants.rocket),
  trophy3d(IsmLiveGiftType.threeD, IsmLiveAssetConstants.trophy3d);

  factory IsmLiveGifts.fromName(String data) => IsmLiveGifts.values
      .firstWhere((e) => e.name == data, orElse: () => IsmLiveGifts.bell);

  const IsmLiveGifts(this.type, this.path);
  final String path;
  final IsmLiveGiftType type;

  static List<IsmLiveGifts> get normal => IsmLiveGifts.values
      .where((e) => e.type == IsmLiveGiftType.normal)
      .toList();

  static List<IsmLiveGifts> get threeD => IsmLiveGifts.values
      .where((e) => e.type == IsmLiveGiftType.threeD)
      .toList();

  static List<IsmLiveGifts> get animated => IsmLiveGifts.values
      .where((e) => e.type == IsmLiveGiftType.animated)
      .toList();
}

enum IsmLiveCopublisher {
  copublisherRequest(IsmLiveStrings.copublisherRequests),
  users(IsmLiveStrings.users);

  const IsmLiveCopublisher(this.label);
  final String label;
}

enum IsmLivePk {
  onlineList(IsmLiveStrings.onlineList),
  inviteList(IsmLiveStrings.inviteList);

  const IsmLivePk(this.label);
  final String label;
}

enum IsmLivePkViewers {
  audiencelist(IsmLiveStrings.audiencelist),
  contributionRanking(IsmLiveStrings.contributionRanking);

  const IsmLivePkViewers(this.label);
  final String label;
}

enum IsmLiveMemberStatus {
  notMember,
  gotRequest,
  requested,
  requestApproved,
  requestDenied,
  copublisher;

  bool get receivedRequest => this == IsmLiveMemberStatus.gotRequest;

  bool get isApproved => this == IsmLiveMemberStatus.requestApproved;

  bool get isRejected => this == IsmLiveMemberStatus.requestDenied;

  bool get didRequested => this == IsmLiveMemberStatus.requested;

  bool get isMember => this == IsmLiveMemberStatus.copublisher;

  bool get canEnableVideo => receivedRequest || isApproved;
}

enum IsmLiveRestreamType {
  facebook(0),
  youtube(1),
  instagram(2);

  factory IsmLiveRestreamType.channelType(int data) {
    switch (data) {
      case 2:
        return IsmLiveRestreamType.instagram;
      case 1:
        return IsmLiveRestreamType.youtube;
      default:
        return IsmLiveRestreamType.facebook;
    }
  }

  const IsmLiveRestreamType(this.value);
  final int value;

  String get label => name.capitalizeFirst!;
}

enum IsmGoLiveTabItem {
  defaultLive('Single/Multi Guest Live'),
  liveFromDevice('Live From Device');

  const IsmGoLiveTabItem(this.label);
  final String label;
}

enum IsmLivePermission {
  host,
  viewer,
  moderator,

  pkGuest,
  copublisher;

  bool get isHost => this == IsmLivePermission.host;

  bool get isViewer => this == IsmLivePermission.viewer;

  bool get isModerator => this == IsmLivePermission.moderator;

  bool get isCopublisher => this == IsmLivePermission.copublisher;

  bool get isPkGuest => this == IsmLivePermission.pkGuest;
}

enum IsmLiveStages {
  pk,
  pkStart,
  pkStop;

  bool get isPkStart => this == IsmLiveStages.pkStart;

  bool get isPk => this == IsmLiveStages.pk;

  bool get isPkStop => this == IsmLiveStages.pkStop;
}

enum IsmLiveStatus {
  pk('stream is mearged for Pk challenge'),
  pkStart('pk started'),
  pkEnd('pk Ended');

  factory IsmLiveStatus.fromValue(String data) =>
      <String, IsmLiveStatus>{
        IsmLiveStatus.pkEnd.label: IsmLiveStatus.pkEnd,
        IsmLiveStatus.pk.label: IsmLiveStatus.pk,
        IsmLiveStatus.pkStart.label: IsmLiveStatus.pkStart,
      }[data] ??
      IsmLiveStatus.pk;

  const IsmLiveStatus(this.label);
  final String label;
}
