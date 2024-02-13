part of '../stream_controller.dart';

mixin StreamSheetMixin {
  IsmLiveStreamController get _controller => Get.find();

  void onExit({
    required bool isHost,
    required String streamId,
  }) {
    IsmLiveUtility.openBottomSheet(
      IsmLiveCustomButtomSheet(
        title: isHost
            ? IsmLiveStrings.areYouSureEndStream
            : IsmLiveStrings.areYouSureLeaveStream,
        leftLabel: 'Cancel',
        rightLabel: isHost ? 'End Stream' : 'Leave Stram',
        onLeft: Get.back,
        onRight: () async {
          Get.back();
          await _controller.disconnectStream(
            isHost: isHost,
            streamId: streamId,
          );
        },
      ),
      isDismissible: false,
    );
  }

  void giftsSheet() async {
    await IsmLiveUtility.openBottomSheet(
      IsmLiveGiftsSheet(
        onTap: (gift) => _controller.sendGiftMessage(
          streamId: _controller.streamId ?? '',
          gift: gift,
        ),
      ),
      isScrollController: true,
    );
  }

  void settingSheet() async {
    await IsmLiveUtility.openBottomSheet(
      const IsmLiveSettingsSheet(),
    );
  }

  void copublishingViewerSheet() async {
    await IsmLiveUtility.openBottomSheet(
      IsmLiveCopublishingViewerSheet(
        title: Get.context?.liveTranslations.requestCopublishingTitle ??
            IsmLiveStrings.requestCopublishingTitle,
        description:
            Get.context?.liveTranslations.requestCopublishingDescription ??
                IsmLiveStrings.requestCopublishingDescription,
        label: 'Send Request',
        images: [
          _controller.user?.profileUrl ?? '',
          _controller.hostDetails?.userProfileImageUrl ?? '',
        ],
        onTap: () {
          if (!_controller.isModerator) {
            _controller.requestCopublisher(
              _controller.streamId ?? '',
            );
          }
        },
      ),
    );
  }

  void copublishingStartVideoSheet() async {
    await IsmLiveUtility.openBottomSheet(
      IsmLiveCopublishingViewerSheet(
        title:
            (Get.context?.liveTranslations.hostAcceptedCopublishRequestTitle ??
                    IsmLiveStrings.hostAcceptedCopublishRequestTitle)
                .trParams({
          'name': _controller.hostDetails?.userName ?? 'Host',
        }),
        description: Get.context?.liveTranslations
                .hostAcceptedCopublishRequestDescription ??
            IsmLiveStrings.hostAcceptedCopublishRequestDescription,
        label: 'Start Video',
        images: [
          _controller.user?.profileUrl ?? '',
        ],
        onTap: () async {
          //TODO: Uncomment to enable video

          var token = await _controller.switchViewer(
              streamId: _controller.streamId ?? '');
          if (token == null) {
            return;
          }

          await _controller.connectStream(
            token: token,
            streamId: _controller.streamId ?? '',
            isHost: false,
            isNewStream: false,
            isCopublisher: true,
          );

          await _controller.sortParticipants();
          // unawaited(_controller.enableMyVideo());
          // unawaited(_controller.toggleAudio(value: true));
        },
      ),
    );
  }

  void copublishingHostSheet() async {
    await IsmLiveUtility.openBottomSheet(
      const IsmLiveCopublishingHostSheet(),
    );
  }
}
