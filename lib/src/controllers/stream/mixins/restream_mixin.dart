part of '../stream_controller.dart';

mixin RestreamMixin {
  IsmLiveStreamController get _controller => Get.find();

  void onTapRestreamType(IsmLiveRestreamType type, bool value) async {
    // if (type != IsmLiveRestreamType.youtube) {
    //   return;
    // }
    await IsmLiveRouteManagement.goToRestreamSettingsView(type);
    _controller.update([IsmLiveRestreamView.updateId]);
  }

  void onChangeRestreamType(IsmLiveRestreamType type, bool value) {
    switch (type) {
      case IsmLiveRestreamType.facebook:
        _controller.restreamFacebook = value;
      case IsmLiveRestreamType.youtube:
        _controller.restreamYoutube = value;
      case IsmLiveRestreamType.instagram:
        _controller.restreamInstagram = value;
    }
    _controller.update([IsmLiveRestreamSettingsView.updateId]);
  }

  void onSaveRestreamSettings({
    required bool enable,
    required String channelName,
    required int channeltype,
    String? channelId,
  }) async {
    if (_controller.rtmlUrl.isEmpty || _controller.streamKey.isEmpty) {
      return;
    }
    if (channelId == null) {
      var res = await _controller.enableRestreamChannel(
        channelName: channelName,
        channeltype: channeltype,
        enable: enable,
      );

      if (res.isNotEmpty) {
        Get.back();
      }
    } else {
      var isComplete = await _controller.editRestreamChannel(
        channelName: channelName,
        channeltype: channeltype,
        enable: enable,
        channelId: channelId,
      );
      if (isComplete) {
        Get.back();
      }
    }

    // if (!isEnabled) {
    //   onChangeRestreamType(
    //     IsmLiveRestreamType.youtube,
    //     !_controller.isRestreamType(
    //       IsmLiveRestreamType.youtube,
    //     ),
    //   );
    // }
    // if (isEnabled) {
    //   _controller.rtmlUrl.clear();
    //   Get.back();
    // }
  }
}
