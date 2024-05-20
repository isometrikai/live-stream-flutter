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

  final RxDouble _pkLoadingValue = 0.2.obs;
  double get pkLoadingValue => _pkLoadingValue.value;
  set pkLoadingValue(double value) => _pkLoadingValue.value = value;

  final Rx<IsmLivePk> _pk = IsmLivePk.inviteList.obs;
  IsmLivePk get pk => _pk.value;
  set pk(IsmLivePk value) => _pk.value = value;

  final Rx<IsmLivePkViewers> _pkViewers = IsmLivePkViewers.audiencelist.obs;
  IsmLivePkViewers get pkViewers => _pkViewers.value;
  set pkViewers(IsmLivePkViewers value) => _pkViewers.value = value;

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
      streamId: streamController.streamId ?? '',
      inviteId: inviteId,
      response: response,
    );

    if (res) {
      publishPk(reciverStreamId: reciverStreamId);
    }
  }

  void publishPk({
    required String reciverStreamId,
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
      token: token,
      streamId: reciverStreamId,
      isHost: false,
      isNewStream: false,
      isCopublisher: false,
      isPk: true,
    );

    await streamController.sortParticipants();
  }
}
