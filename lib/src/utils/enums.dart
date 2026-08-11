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

  String get label => switch (this) {
        IsmLiveStreamTypes.free => IsmLiveStrings.free,
        IsmLiveStreamTypes.premium => IsmLiveStrings.premium,
      };
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
  all(0),
  live(8),
  scheduledStreams(1),
  // audioOnly(1),
  pk(2),
  // private(3),
  // ecommerce(4),
  restream(5),
  hd(6),
  recorded(7);
  // multilive(8);

  const IsmLiveStreamType(this.value);
  final int value;

  String get label => switch (this) {
        IsmLiveStreamType.all => IsmLiveStrings.all,
        IsmLiveStreamType.live => IsmLiveStrings.live,
        IsmLiveStreamType.scheduledStreams => IsmLiveStrings.scheduled,
        IsmLiveStreamType.pk => IsmLiveStrings.pk,
        IsmLiveStreamType.restream => IsmLiveStrings.reStream,
        IsmLiveStreamType.hd => IsmLiveStrings.hd,
        IsmLiveStreamType.recorded => IsmLiveStrings.recorded,
      };
}

enum IsmLiveCoinTransactionType {
  all(0),
  debit(1),
  credit(2);

  const IsmLiveCoinTransactionType(this.value);
  final int value;

  String get label => switch (this) {
        IsmLiveCoinTransactionType.all => IsmLiveStrings.all,
        IsmLiveCoinTransactionType.debit => IsmLiveStrings.debit,
        IsmLiveCoinTransactionType.credit => IsmLiveStrings.credit,
      };
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
  streamStopPresence('streamStopPresence'),
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
        IsmLiveActions.streamStopPresence.value:
            IsmLiveActions.streamStopPresence,
        IsmLiveActions.viewerJoined.value: IsmLiveActions.viewerJoined,
        IsmLiveActions.viewerLeft.value: IsmLiveActions.viewerLeft,
        IsmLiveActions.viewerRemoved.value: IsmLiveActions.viewerRemoved,
        IsmLiveActions.viewerTimeout.value: IsmLiveActions.viewerTimeout,
      }[action] ??
      IsmLiveActions.streamStartPresence;

  const IsmLiveActions(this.value);
  final String value;
}

enum IsmLiveAnalyticsOptions {
  hearts(IsmLiveAssetConstants.heartSvg),
  order(IsmLiveAssetConstants.box),
  viewers(IsmLiveAssetConstants.eye),
  followers(IsmLiveAssetConstants.profileUser),
  earnings(IsmLiveAssetConstants.dollar),
  duration(IsmLiveAssetConstants.clock),
  ;

  const IsmLiveAnalyticsOptions(this.icon);
  final String icon;

  static List<IsmLiveAnalyticsOptions> get optionsList =>
      IsmLiveDelegate.liveAnalyticsOptions.isEmpty
          ? [
              IsmLiveAnalyticsOptions.hearts,
              IsmLiveAnalyticsOptions.order,
              IsmLiveAnalyticsOptions.viewers,
              IsmLiveAnalyticsOptions.followers,
              IsmLiveAnalyticsOptions.earnings,
              IsmLiveAnalyticsOptions.duration,
            ]
          : IsmLiveDelegate.liveAnalyticsOptions;

  IsmLiveAnalyticsOptionOverride? get _override =>
      IsmLiveDelegate.analyticsOptionOverrides[this];

  /// Host [IsmLiveAnalyticsOptionOverride.icon], else the built-in SVG path.
  String get resolvedIcon => _override?.icon ?? icon;

  /// Host title override, else [fallback] (typically an [IsmLiveStrings] value).
  String resolveTitle(String fallback) => _override?.title ?? fallback;

  /// `true` for package defaults; host icons default to the host app bundle.
  bool get resolvedIconFromPackage {
    final override = _override;
    if (override?.icon == null) return true;
    return override!.fromPackage;
  }
}

/// Optional per-option label/icon override for analytics tiles
/// (end-stream screen + analytics sheet).
///
/// Set via `IsmLiveApp.configureInterface(analyticsOptionOverrides: ...)`.
/// Unset fields keep the SDK defaults — safe for partial overrides.
class IsmLiveAnalyticsOptionOverride {
  const IsmLiveAnalyticsOptionOverride({
    this.title,
    this.icon,
    this.fromPackage = false,
  });

  /// Custom tile label. `null` keeps [IsmLiveStrings] (e.g. Hearts, Viewers).
  final String? title;

  /// Custom SVG asset path. `null` keeps the enum's built-in icon.
  final String? icon;

  /// Whether [icon] is loaded from this package.
  ///
  /// Defaults to `false` so host-app assets work without extra config.
  /// Set `true` only when [icon] points at an SDK package asset.
  final bool fromPackage;
}

enum IsmLiveStreamOption {
  gift(IsmLiveAssetConstants.gift),
  bars(IsmLiveAssetConstants.bars),
  multiLive(IsmLiveAssetConstants.multi),
  share(IsmLiveAssetConstants.share),
  members(IsmLiveAssetConstants.analytics),
  scheduleModify(IsmLiveAssetConstants.more),
  settings(IsmLiveAssetConstants.settings),
  rotateCamera(IsmLiveAssetConstants.rotateCamera),
  speaker(IsmLiveAssetConstants.speakerOn),
  product(IsmLiveAssetConstants.product),
  vs(IsmLiveAssetConstants.vs),
  pk(IsmLiveAssetConstants.pk),
  heart(IsmLiveAssetConstants.heartSvg),
  rtmpDetails(IsmLiveAssetConstants.infoSvg),
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

  static List<IsmLiveStreamOption> get scheduleOptions =>
      IsmLiveDelegate.scheduleOptions.isEmpty
          ? [
              IsmLiveStreamOption.share,
              IsmLiveStreamOption.scheduleModify,
              if (IsmLiveDelegate.productStream == true)
                IsmLiveStreamOption.product,
            ]
          : IsmLiveDelegate.scheduleOptions;

  ///host options
  static List<IsmLiveStreamOption> get hostOptions =>
      IsmLiveDelegate.hostOptions.isEmpty
          ? [
              IsmLiveStreamOption.bars,
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
              IsmLiveStreamOption.bars,
              IsmLiveStreamOption.vs,
              IsmLiveStreamOption.multiLive,
              IsmLiveStreamOption.share,
              IsmLiveStreamOption.rtmpDetails,
            ]
          : IsmLiveDelegate.rtmpOptions;

  ///copublisher options
  static List<IsmLiveStreamOption> get copublisherOptions =>
      IsmLiveDelegate.copublisherOptions.isEmpty
          ? [
              // IsmLiveStreamOption.members,
              // IsmLiveStreamOption.vs,
              // IsmLiveStreamOption.multiLive,
              IsmLiveStreamOption.speaker,
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
              IsmLiveStreamOption.bars,
              IsmLiveStreamOption.share,
              IsmLiveStreamOption.rotateCamera,
              IsmLiveStreamOption.settings,
            ]
          : IsmLiveDelegate.pkOptions;
}

enum IsmLiveHostSettings {
  muteMyVideo(
    IsmLiveAssetConstants.video_camera,
    IsmLiveAssetConstants.video_off,
  ),
  muteMyAudio(
    IsmLiveAssetConstants.micro_phone,
    IsmLiveAssetConstants.micro_phone_off,
  );
  // block(IsmLiveAssetConstants.block, 'Block', 'Unblock'),
  // report(IsmLiveAssetConstants.report, 'Report', '');
  // muteRemoteVideo('Mute remote video', 'Unmute remote video'),
  // muteRemoteAudio('Mute remote audio', 'Unmute remote audio'),
  // showNetWorkStats('Show netWork stats', 'Hide netWork stats'),
  // hideChatMessages('Hide chat messages', 'Show chat messages'),
  // hideControlButtons('Hide control buttons', 'Show control buttons');

  const IsmLiveHostSettings(this.icon, this.offIcon);
  final String icon;
  final String offIcon;

  String get muteValues => switch (this) {
        IsmLiveHostSettings.muteMyVideo => IsmLiveStrings.turnOffVideo,
        IsmLiveHostSettings.muteMyAudio => IsmLiveStrings.mute,
      };

  String get unmuteValues => switch (this) {
        IsmLiveHostSettings.muteMyVideo => IsmLiveStrings.turnOnVideo,
        IsmLiveHostSettings.muteMyAudio => IsmLiveStrings.unmute,
      };
}

enum IsmLiveScheduleSettings {
  edit(IsmLiveAssetConstants.edit),
  delete(IsmLiveAssetConstants.delete);

  const IsmLiveScheduleSettings(this.icon);
  final String icon;

  String get label => switch (this) {
        IsmLiveScheduleSettings.edit => IsmLiveStrings.editStream,
        IsmLiveScheduleSettings.delete => IsmLiveStrings.deleteStream,
      };
}

enum IsmLiveMessageType {
  normal(0),
  heart(3),
  gift(2),
  gift3D(10),
  remove(1),
  pkStart(23),
  changeStream(21),
  changeStreamPkEnd(24),
  pk(20),
  pkStop(22),
  presence(4),

  /// Server message types not yet mapped in this SDK (e.g. newly introduced).
  /// Use [IsmLiveMessageModel.messageTypeValue] for the raw payload value.
  unknown(-1);

  const IsmLiveMessageType(this.value);
  final int value;

  static int parseValue(dynamic raw) {
    if (raw is int) return raw;
    if (raw is num) return raw.toInt();
    if (raw is String) return int.tryParse(raw) ?? 0;
    return 0;
  }

  factory IsmLiveMessageType.fromValue(int data) =>
      <int, IsmLiveMessageType>{
        IsmLiveMessageType.normal.value: IsmLiveMessageType.normal,
        IsmLiveMessageType.heart.value: IsmLiveMessageType.heart,
        IsmLiveMessageType.gift.value: IsmLiveMessageType.gift,
        IsmLiveMessageType.gift3D.value: IsmLiveMessageType.gift3D,
        IsmLiveMessageType.remove.value: IsmLiveMessageType.remove,
        IsmLiveMessageType.presence.value: IsmLiveMessageType.presence,
        IsmLiveMessageType.pk.value: IsmLiveMessageType.pk,
        IsmLiveMessageType.changeStream.value: IsmLiveMessageType.changeStream,
        IsmLiveMessageType.changeStreamPkEnd.value:
            IsmLiveMessageType.changeStreamPkEnd,
        IsmLiveMessageType.pkStart.value: IsmLiveMessageType.pkStart,
        IsmLiveMessageType.pkStop.value: IsmLiveMessageType.pkStop,
      }[data] ??
      IsmLiveMessageType.unknown;
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
  normal,
  threeD,
  animated;

  String get label => switch (this) {
        IsmLiveGiftType.normal => IsmLiveStrings.normal,
        IsmLiveGiftType.threeD => IsmLiveStrings.threeD,
        IsmLiveGiftType.animated => IsmLiveStrings.animated,
      };

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

/// Gift identifiers used for message `customType` parsing.
///
/// Gift media is served from the backend (CDN URLs), not bundled in the SDK.
enum IsmLiveGifts {
  bell(IsmLiveGiftType.normal),
  cherry(IsmLiveGiftType.normal),
  giftImage(IsmLiveGiftType.normal),
  icecream(IsmLiveGiftType.normal),
  kiss(IsmLiveGiftType.normal),
  lolipop(IsmLiveGiftType.normal),
  paw(IsmLiveGiftType.normal),
  cake(IsmLiveGiftType.animated),
  cheers(IsmLiveGiftType.animated),
  chest(IsmLiveGiftType.animated),
  clapping(IsmLiveGiftType.animated),
  coin(IsmLiveGiftType.animated),
  crown(IsmLiveGiftType.animated),
  cryingLaughter(IsmLiveGiftType.animated),
  diamond(IsmLiveGiftType.animated),
  goodLife(IsmLiveGiftType.animated),
  heartEyes(IsmLiveGiftType.animated),
  heart(IsmLiveGiftType.animated),
  inLove(IsmLiveGiftType.animated),
  moneyFlying(IsmLiveGiftType.animated),
  money(IsmLiveGiftType.animated),
  party(IsmLiveGiftType.animated),
  present(IsmLiveGiftType.animated),
  rocketLaunch(IsmLiveGiftType.animated),
  rocketSpin(IsmLiveGiftType.animated),
  rollingLaughter(IsmLiveGiftType.animated),
  star(IsmLiveGiftType.animated),
  thumb(IsmLiveGiftType.animated),
  trophy(IsmLiveGiftType.animated),
  verified(IsmLiveGiftType.animated),
  wow(IsmLiveGiftType.animated),
  yeah(IsmLiveGiftType.animated),
  cake3d(IsmLiveGiftType.threeD),
  cheers3d(IsmLiveGiftType.threeD),
  clapping3d(IsmLiveGiftType.threeD),
  crown3d(IsmLiveGiftType.threeD),
  fire(IsmLiveGiftType.threeD),
  fish(IsmLiveGiftType.threeD),
  happyBirthday(IsmLiveGiftType.threeD),
  heartEyes3d(IsmLiveGiftType.threeD),
  love(IsmLiveGiftType.threeD),
  money3d(IsmLiveGiftType.threeD),
  partyPopper(IsmLiveGiftType.threeD),
  rocket(IsmLiveGiftType.threeD),
  trophy3d(IsmLiveGiftType.threeD);

  factory IsmLiveGifts.fromName(String data) => IsmLiveGifts.values
      .firstWhere((e) => e.name == data, orElse: () => IsmLiveGifts.bell);

  const IsmLiveGifts(this.type);
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
  copublisherRequest,
  users;

  String get label => switch (this) {
        IsmLiveCopublisher.copublisherRequest =>
          IsmLiveStrings.copublisherRequests,
        IsmLiveCopublisher.users => IsmLiveStrings.users,
      };
}

enum IsmLivePk {
  onlineList,
  inviteList;

  String get label => switch (this) {
        IsmLivePk.onlineList => IsmLiveStrings.onlineList,
        IsmLivePk.inviteList => IsmLiveStrings.inviteList,
      };
}

enum IsmLivePkViewers {
  audiencelist,
  contributionRanking;

  String get label => switch (this) {
        IsmLivePkViewers.audiencelist => IsmLiveStrings.audiencelist,
        IsmLivePkViewers.contributionRanking =>
          IsmLiveStrings.contributionRanking,
      };
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

  String get label => switch (this) {
        IsmLiveRestreamType.facebook => IsmLiveStrings.facebook,
        IsmLiveRestreamType.youtube => IsmLiveStrings.youtube,
        IsmLiveRestreamType.instagram => IsmLiveStrings.instagram,
      };
}

enum IsmGoLiveTabItem {
  defaultLive,
  liveFromDevice;

  String get label => switch (this) {
        IsmGoLiveTabItem.defaultLive => IsmLiveStrings.singleMultiGuestLive,
        IsmGoLiveTabItem.liveFromDevice => IsmLiveStrings.liveFromDevice,
      };
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
