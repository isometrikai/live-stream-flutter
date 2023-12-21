part of '../stream_controller.dart';

mixin StreamAPIMixin {
  IsmLiveStreamController get _controller => Get.find<IsmLiveStreamController>();

  IsmLiveDBWrapper get _dbWrapper => Get.find<IsmLiveDBWrapper>();

  Future<void> getUserDetails() async {
    await _controller._viewModel.getUserDetails();
    _controller.user = UserDetails.fromJson(_dbWrapper.getStringValue(IsmLiveLocalKeys.user));
    _controller.update([IsmLiveHeader.updateId]);
  }

  Future<bool> _subscribeUser(bool isSubscribing) => _controller._viewModel.subscribeUser(
        isSubscribing: isSubscribing,
      );

  Future<void> getStreams(IsmLiveStreamType type) async {
    _controller._streams[type] = await _controller._viewModel.getStreams(
      queryModel: type.queryModel,
    );
    _controller._streamRefreshControllers[type]!.refreshCompleted();
    IsmLiveUtility.updateLater(() {
      _controller.update([IsmLiveStreamView.updateId]);
    });
  }
}
