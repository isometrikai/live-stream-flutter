import 'dart:async';

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

  final RxList<IsmLivePkInviteModel> _pkInviteList =
      <IsmLivePkInviteModel>[].obs;
  List<IsmLivePkInviteModel> get pkInviteList => _pkInviteList;
  set pkInviteList(List<IsmLivePkInviteModel> list) =>
      _pkInviteList.value = list;

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

  String? inviteId;

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
    required String pkId,
  }) {
    if (pkTimer != null) {
      return;
    }

    pkDuration = Duration(minutes: time);
    pkTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        pkDuration -= const Duration(
          seconds: 1,
        );
        if (pkDuration.inSeconds == 0) {
          stopPkBattle(action: 'FORCE_STOP', pkId: pkId);
          pkTimer?.cancel();
          pkTimer = null;
        }
      },
    );
  }

  void pkEventHandler(Map<String, dynamic> payload) async {
    if (!streamController.isPk) {
      unawaited(
        streamController.getStreamMembers(
          streamId: streamController.streamId ?? '',
        ),
      );
    }
    streamController.pkStages ??= IsmLivePkStages.isPk();
    var pkDetails = IsmLivePkEventMetaDataModel.fromMap(payload['metaData']);

    if (pkDetails.message == IsmLiveStatus.pkStart) {
      streamController.pkStages?.makePkStart();
      startPkTimer(time: pkDetails.timeInMin ?? 0, pkId: pkDetails.pkId ?? '');
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
    this.inviteId = inviteId;
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

  void pkStatus(String streamId) async {
    await _viewModel.pkStatus(
      streamId: streamId,
    );
  }

  Future<void> startPkBattle() async {
    if (pkSelectTime.isNotEmpty) {
      await _viewModel.startPkBattle(
        battleTimeInMin: pkSelectTime,
        inviteId: inviteId ?? '',
      );

      Get.back();
    }
  }

  Future<void> stopPkBattle({
    required String pkId,
    required String action,
  }) async {
    var res = await _viewModel.stopPkBattle(
      action: action,
      pkId: pkId,
    );

    if (res) {
      await pkWinner(pkId);
    }
  }

  Future<void> pkWinner(String pkId) async {
    await _viewModel.pkWinner(
      pkId: pkId,
    );
  }
}
