import 'dart:async';
import 'dart:convert';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLivePkController extends GetxController
    with GetTickerProviderStateMixin {
  IsmLivePkController(this._viewModel);

  final IsmLivePkViewModel _viewModel;

  final IsmLiveStreamController streamController =
      Get.find<IsmLiveStreamController>();

  late TabController pkTabController;
  late TabController pkViewersTabController;

  ScrollController pkInviteListController = ScrollController();

  TextEditingController pkInviteTextController = TextEditingController();

  final _pkInviteDebouncer = IsmLiveDebouncer();
  final _giftCategoriesDebouncer = IsmLiveDebouncer();
  final _giftDebouncer = IsmLiveDebouncer();

  final RxList<IsmLivePkInviteModel> _pkInviteList =
      <IsmLivePkInviteModel>[].obs;
  List<IsmLivePkInviteModel> get pkInviteList => _pkInviteList;
  set pkInviteList(List<IsmLivePkInviteModel> list) =>
      _pkInviteList.value = list;

  final RxList<IsmLiveGiftGroupModel> _giftCategoriesList =
      <IsmLiveGiftGroupModel>[].obs;
  List<IsmLiveGiftGroupModel> get giftCategoriesList => _giftCategoriesList;
  set giftCategoriesList(List<IsmLiveGiftGroupModel> list) =>
      _giftCategoriesList.value = list;

  final RxList<IsmLiveGiftsCategoryModel> _giftList =
      <IsmLiveGiftsCategoryModel>[].obs;
  List<IsmLiveGiftsCategoryModel> get giftList => _giftList;
  set giftList(List<IsmLiveGiftsCategoryModel> list) => _giftList.value = list;

  final RxString _pkSelectTime = ''.obs;
  String get pkSelectTime => _pkSelectTime.value;
  set pkSelectTime(String value) => _pkSelectTime.value = value;

  final Rx<IsmLivePk> _pk = IsmLivePk.inviteList.obs;
  IsmLivePk get pk => _pk.value;
  set pk(IsmLivePk value) => _pk.value = value;

  final Rx<IsmLivePkViewers> _pkViewers = IsmLivePkViewers.audiencelist.obs;
  IsmLivePkViewers get pkViewers => _pkViewers.value;
  set pkViewers(IsmLivePkViewers value) => _pkViewers.value = value;

  final Rx<Duration> _pkDuration = Duration.zero.obs;
  Duration get pkDuration => _pkDuration.value;
  set pkDuration(Duration value) => _pkDuration.value = value;

  final RxDouble _pkBarPersentage = 0.5.obs;
  double get pkBarPersentage => _pkBarPersentage.value;
  set pkBarPersentage(double value) => _pkBarPersentage.value = value;

  late String inviteId;

  String? pkId;

  int pkHostValue = 0;
  int pkGustValue = 0;

  Timer? pkTimer;

  @override
  void onInit() {
    super.onInit();
    pkTabController = TabController(
      vsync: this,
      length: IsmLivePk.values.length,
    );
    pkViewersTabController = TabController(
      vsync: this,
      length: IsmLivePkViewers.values.length,
    );
    pkPagination();
  }

  @override
  void onReady() {
    super.onReady();
    IsmLiveUtility.updateLater(() {
      pkTabController.addListener(() {
        pk = IsmLivePk.values[pkTabController.index];
      });
      pkViewersTabController.addListener(() {
        pkViewers = IsmLivePkViewers.values[pkViewersTabController.index];
      });
    });
  }

  void startPkTimer({
    required int time,
    bool inSec = false,
  }) {
    if (pkTimer != null) {
      return;
    }

    if (inSec) {
      pkDuration = Duration(seconds: time);
    } else {
      pkDuration = Duration(minutes: time);
    }

    pkTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        pkDuration -= const Duration(
          seconds: 1,
        );
        if (pkDuration.inSeconds == 0) {
          pkTimer?.cancel();
          pkTimer = null;
        }
      },
    );
  }

  void pkStartEvent(Map<String, dynamic> payload) async {
    try {
      var pkDetails = IsmLivePkEventMetaDataModel.fromMap(payload['metaData']);
      if (pkTimer != null) {
        pkTimer?.cancel();
        pkTimer = null;
      }
      streamController.pkStages?.makePkStart();
      streamController.pkWinnerId = null;
      pkId = pkDetails.pkId;
      pkBarPersentage = 0.5;
      pkHostValue = 0;
      pkGustValue = 0;
      startPkTimer(
        time: pkDetails.timeInMin ?? 0,
      );
    } catch (e) {
      IsmLiveLog(e);
    }
  }

  void pkStopEvent(Map<String, dynamic> payload, bool isForceStop) async {
    try {
      IsmLivePkEventMetaDataModel? pkDetails;
      String stopPkId;
      if (isForceStop) {
        pkDetails = IsmLivePkEventMetaDataModel.fromMap(payload['metaData']);
        stopPkId = pkDetails.pkId ?? '';
      } else {
        stopPkId = payload['payload']['pkId'];
      }

      pkTimer?.cancel();
      pkTimer = null;

      streamController.pkStages?.removePkStart();
      streamController.pkStages?.makePkStop();
      await pkWinner(stopPkId);
      IsmLiveDebouncer(
        durationtime: 6000,
      ).run(() {
        streamController.pkStages?.removePkStop();
        streamController.update([IsmLivePublisherGrid.updateId]);
        streamController.update([IsmLiveStreamView.updateId]);
      });
    } catch (e) {
      IsmLiveLog(e);
    }
  }

  bool isPkInviteApisCall = false;
  void pkPagination() {
    pkInviteListController.addListener(() async {
      if (pkInviteListController.position.maxScrollExtent * 0.8 <=
          pkInviteListController.position.pixels) {
        if (isPkInviteApisCall) {
          return;
        }
        isPkInviteApisCall = true;

        await getUsersToInviteForPK(
          limit: 10,
          skip: pkInviteList.length,
          searchTag: pkInviteTextController.text,
        );
        isPkInviteApisCall = false;
      }
    });
  }

  void pkChangeHostSheet({required String userId, String? name}) async {
    await IsmLiveUtility.openBottomSheet(
      IsmLivePkChangeHostSheet(
        followers: '',
        coins: '',
        description: 'New York, USA Female 34',
        image: '',
        lable: 'Change host',
        title: '@$name',
        onTap: () {
          streamController.participantList =
              streamController.participantList.reversed.toList();

          var swap = pkHostValue;
          pkHostValue = pkGustValue;
          pkGustValue = swap;

          pkBarPersentage = pkPersentege(pkHostValue, pkGustValue);

          streamController.update([IsmLivePublisherGrid.updateId]);

          Get.back();
        },
      ),
    );
  }

  void pkInviteSheet({
    required List<String> images,
    required String userName,
    required String reciverName,
    required String description,
    required String title,
    bool isInvite = false,
    String? inviteId,
    String? reciverStreamId,
  }) async {
    await IsmLiveUtility.openBottomSheet(
      IsmLivePkInviteSheet(
        description: description,
        images: images,
        userName: userName,
        reciverName: reciverName,
        title: title,
        isInvite: isInvite,
        inviteId: inviteId,
        reciverStreamId: reciverStreamId,
      ),
    );
  }

  void stopPkBattleSheet() async {
    await IsmLiveUtility.openBottomSheet(
      IsmLiveCustomButtomSheet(
        title: streamController.pkStages?.isPkStart ?? false
            ? 'You want to end pk battle'
            : 'Pk battle not started',
        leftLabel: 'cancel',
        rightLabel:
            streamController.pkStages?.isPkStart ?? false ? 'stop battle' : '',
        onLeft: Get.back,
        onRight: () {
          Get.back();
          if (streamController.pkStages?.isPkStart ?? false) {
            stopPkBattle(action: 'FORCE_STOP', pkId: pkId ?? '');
          } else {}
        },
      ),
    );
  }

  Future<void> getUsersToInviteForPK({
    int limit = 15,
    int skip = 0,
    String? searchTag,
  }) async {
    _pkInviteDebouncer.run(() async {
      await _getUsersToInviteForPK(
        limit: limit,
        skip: skip,
        searchTag: searchTag,
      );
    });
  }

  Future<void> _getUsersToInviteForPK({
    required int limit,
    required int skip,
    String? searchTag,
  }) async {
    var res = await _viewModel.getUsersToInviteForPK(
      limit: limit,
      skip: skip,
      searchTag: searchTag,
    );
    pkInviteList.addAll(res);
    pkInviteList = pkInviteList.toSet().toList();
  }

  Future<void> sendInvitationToUserForPK({
    required IsmLivePkInviteModel reciverDetails,
  }) async {
    var res = await _viewModel.sendInvitationToUserForPK(
      reciverStreamId: reciverDetails.streamId,
      senderStreamId: streamController.streamId ?? '',
      userId: reciverDetails.userId,
    );

    if (res) {
      Get.back();
      pkInviteSheet(
          description:
              'The PK challenge between you and ${reciverDetails.name} will start soon. Please wait…',
          images: [
            reciverDetails.profilePic ?? '',
            streamController.user?.profileUrl ?? ''
          ],
          userName: streamController.user?.name ?? '',
          reciverName: reciverDetails.name,
          title: 'Linking...');
    }
  }

  void invitationPk({
    required String inviteId,
    required String response,
    required String reciverStreamId,
  }) async {
    var res = await _viewModel.invitationPk(
      streamId: reciverStreamId,
      inviteId: inviteId,
      response: response,
    );

    if (res != null && res.message != IsmLivePkResponce.rejected) {
      await publishPk(
        reciverStreamId: res.streamData.streamId ?? '',
        hdBroadcast: res.streamData.hdBroadcast ?? false,
        streamDiscription: res.streamData.streamDescription,
        streamImage: res.streamData.streamImage,
      );
    }
  }

  Future<void> publishPk({
    required String reciverStreamId,
    String? streamImage,
    String? streamDiscription,
    bool hdBroadcast = false,
  }) async {
    var token = await _viewModel.publishPk(
      streamId: reciverStreamId,
      startPublish: true,
    );

    if (token == null) {
      return;
    }
    await streamController.room!.disconnect();
    await streamController.room!.dispose();

    await streamController.connectStream(
      hdBroadcast: hdBroadcast,
      streamDiscription: streamDiscription,
      streamImage: streamImage,
      token: token,
      streamId: reciverStreamId,
      isHost: false,
      isNewStream: false,
      isCopublisher: false,
      isPk: true,
    );

    await streamController.sortParticipants();
  }

  void pkBarStatus(Map<String, dynamic> payload) {
    var data = jsonDecode(payload['body']);

    if (data['reciverId'] ==
        streamController.participantList.first.participant.identity) {
      pkHostValue = data['totalCoinsRecived'] as int;

      pkBarPersentage = pkPersentege(pkHostValue, pkGustValue);
    } else {
      pkGustValue = data['totalCoinsRecived'] as int;

      pkBarPersentage = pkPersentege(pkHostValue, pkGustValue);
    }
  }

  double pkPersentege(int first, int secound) {
    var total = first + secound;
    return first / total;
  }

  void pkStatus(String streamId) async {
    var res = await _viewModel.pkStatus(
      streamId: streamId,
    );

    if (res != null) {
      pkId = res.pkId;
      streamController.pkStages = IsmLivePkStages.isPk();
      streamController.pkStages?.makePkStart();
      startPkTimer(
        time: res.timeRemain ?? 0,
        inSec: true,
      );
    }
  }

  Future<void> startPkBattle() async {
    if (pkSelectTime.isNotEmpty) {
      Get.back();
      await _viewModel.startPkBattle(
        battleTimeInMin: pkSelectTime,
        inviteId: inviteId,
      );
    }
  }

  Future<void> stopPkBattle({
    required String pkId,
    required String action,
  }) async {
    await _viewModel.stopPkBattle(
      action: action,
      pkId: pkId,
    );
  }

  Future<void> pkWinner(String pkId) async {
    var res = await _viewModel.pkWinner(
      pkId: pkId,
    );

    if (res != null) {
      streamController.pkWinnerId = res.winnerId ?? '';
    }

    streamController.update([IsmLiveStreamView.updateId]);
  }

  Future<void> getGiftCategories({
    int limit = 15,
    int skip = 0,
    String? searchTag,
  }) async {
    _giftCategoriesDebouncer.run(() async {
      await _getGiftCategories(
        limit: limit,
        skip: skip,
        searchTag: searchTag,
      );
    });
  }

  Future<void> _getGiftCategories({
    required int limit,
    required int skip,
    String? searchTag,
  }) async {
    var res = await _viewModel.getGiftCategories(
      limit: limit,
      skip: skip,
      searchTag: searchTag,
    );

    giftCategoriesList.addAll(res);
    giftCategoriesList = giftCategoriesList.toSet().toList();
  }

  Future<void> getGiftsForACategory({
    int limit = 15,
    int skip = 0,
    String? searchTag,
    required String giftGroupId,
  }) async {
    _giftDebouncer.run(() async {
      await _getGiftsForACategory(
        limit: limit,
        skip: skip,
        searchTag: searchTag,
        giftGroupId: giftGroupId,
      );
    });
  }

  Future<void> _getGiftsForACategory({
    required int limit,
    required int skip,
    required String giftGroupId,
    String? searchTag,
  }) async {
    var res = await _viewModel.getGiftsForACategory(
      limit: limit,
      skip: skip,
      searchTag: searchTag,
      giftGroupId: giftGroupId,
    );

    giftList.addAll(res);
    giftList = giftList.toSet().toList();
  }

  Future<void> sendGift() async {
    var res = await _viewModel.sendGiftToStreamer(IsmLiveSendGiftModel(
      isPk: true,
      receiverStreamId: streamController.streamId,
      receiverUserId:
          streamController.participantList.first.participant.identity,
      senderId: streamController.user?.userId,
      receiverName: streamController.participantList.first.participant.name,
      messageStreamId: streamController.streamId,
      pkId: pkId,
      amount: 10,
      currency: 'COIN',
      receiverCurrency: 'INR',
      reciverUserType:
          streamController.participantList.first.participant.identity ==
                  streamController.hostDetails?.userId
              ? 'publisher'
              : 'co-publisher',
      IsGiftVideo: false,
      deviceId: IsmLiveUtility.config.projectConfig.deviceId,
      giftId: '65f2834f3098f1fbf4022d46',
      giftThumbnailUrl:
          'https://admin-media1.isometrik.io/virtual_currency_gift_icon/TOr7LK_Zjr.png',
      giftTitle: 'Cat Dancing',
      isometricToken: IsmLiveUtility.config.userConfig.userToken,
      giftUrl:
          'https://admin-media1.isometrik.io/virtual_currency_gift_animation/ORZoL4_CYS.gif',
    ));
  }
}
