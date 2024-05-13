import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IsmLivePkController extends GetxController
    with GetTickerProviderStateMixin {
  IsmLivePkController(this._viewModel);

  final IsmLivePkViewModel _viewModel;

  late TabController pkTabController;
  late TabController pkViewersTabController;

  ScrollController pkInviteListController = ScrollController();

  TextEditingController pkInviteTextController = TextEditingController();

  final RxList<IsmLivePkInviteModel> _pkInviteList =
      <IsmLivePkInviteModel>[].obs;
  List<IsmLivePkInviteModel> get pkInviteList => _pkInviteList;
  set pkInviteList(List<IsmLivePkInviteModel> list) =>
      _pkInviteList.value = list;

  final Rx<IsmLivePk> _pk = IsmLivePk.inviteList.obs;
  IsmLivePk get pk => _pk.value;
  set pk(IsmLivePk value) => _pk.value = value;

  final Rx<IsmLivePkViewers> _pkViewers = IsmLivePkViewers.audiencelist.obs;
  IsmLivePkViewers get pkViewers => _pkViewers.value;
  set pkViewers(IsmLivePkViewers value) => _pkViewers.value = value;
  @override
  void onInit() {
    super.onInit();
    getUsersToInviteForPK();
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

        await getUsersToInviteForPK(limit: 10, skip: pkInviteList.length);
        isPkInviteApisCall = false;
      }
    });
  }

  Future<void> getUsersToInviteForPK({
    int limit = 15,
    int skip = 0,
    String? searchTag,
  }) async {
    var res = await _viewModel.getUsersToInviteForPK(
      limit: limit,
      skip: skip,
      searchTag: searchTag,
    );

    pkInviteList.addAll(res);
  }
}
