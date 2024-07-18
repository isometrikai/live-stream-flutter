part of '../stream_controller.dart';

mixin StreamSheetMixin {
  IsmLiveStreamController get _controller => Get.find();
  // Function to handle exit actions from the stream
  void onExit({
    required bool isHost,
    required String streamId,
  }) async {
    FocusScope.of(Get.context!).unfocus();

    if (isHost || (_controller.isCopublisher)) {
      await IsmLiveUtility.openBottomSheet(
        IsmLiveCustomButtomSheet(
          title: isHost
              ? IsmLiveStrings.areYouSureEndStream
              : IsmLiveStrings.areYouSureLeaveStream,
          leftLabel: isHost ? 'Cancel' : 'Stop stream',
          rightLabel: isHost ? 'End Stream' : 'Leave stream',
          onLeft: isHost
              ? Get.back
              : () async {
                  Get.back();
                  await _controller.disconnectStream(
                    isHost: isHost,
                    streamId: streamId,
                    endStream: false,
                  );
                },
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
    } else {
      await _controller.disconnectStream(
        isHost: isHost,
        streamId: streamId,
      );
    }
  }

// Function to handle showing gifts bottom sheet
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

// Function to handle showing settings bottom sheet
  void settingSheet() async {
    await IsmLiveUtility.openBottomSheet(
      const IsmLiveSettingsSheet(),
    );
  }

  void pkChallengeSheet() async {
    await IsmLiveUtility.openBottomSheet(
      const IsmLivePkChallengeSheet(),
    );
  }

  // Function to handle showing copublishing viewer bottom sheet
  void copublishingViewerSheet() async {
    await IsmLiveUtility.openBottomSheet(
      IsmLiveCopublishingViewerSheet(
        title: Get.context?.liveTranslations?.requestCopublishingTitle ??
            IsmLiveStrings.requestCopublishingTitle,
        description:
            Get.context?.liveTranslations?.requestCopublishingDescription ??
                IsmLiveStrings.requestCopublishingDescription,
        label: _controller.memberStatus.isRejected
            ? 'Request denied by the host'
            : _controller.memberStatus.didRequested
                ? 'Requested Co-publishing'
                : 'Send Request',
        images: [
          _controller.user?.profileUrl ?? '',
          _controller.hostDetails?.userProfileImageUrl ?? '',
        ],
        onTap: _controller.memberStatus.didRequested ||
                _controller.memberStatus.isRejected
            ? null
            : () async {
                if (!_controller.isModerator) {
                  final isSent = await _controller.requestCopublisher(
                    _controller.streamId ?? '',
                  );
                  if (isSent) {
                    _controller.memberStatus = IsmLiveMemberStatus.requested;
                  }
                }
              },
      ),
    );
  }

// Function to handle showing copublishing start video bottom sheet
  void copublishingStartVideoSheet() async {
    await IsmLiveUtility.openBottomSheet(
      IsmLiveCopublishingViewerSheet(
        title:
            (Get.context?.liveTranslations?.hostAcceptedCopublishRequestTitle ??
                    IsmLiveStrings.hostAcceptedCopublishRequestTitle)
                .trParams({
          'name': _controller.hostDetails?.userName ?? 'Host',
        }),
        description: Get.context?.liveTranslations
                ?.hostAcceptedCopublishRequestDescription ??
            IsmLiveStrings.hostAcceptedCopublishRequestDescription,
        label: 'Start Video',
        images: [
          _controller.user?.profileUrl ?? '',
        ],
        onTap: () async {
          if (_controller.room != null) {
            var token = await _controller.switchViewer(
                streamId: _controller.streamId ?? '');
            if (token == null) {
              return;
            }
            // await _controller.room!.disconnect();
            await _controller.room!.dispose();

            await _controller.connectStream(
              token: token,
              streamId: _controller.streamId ?? '',
              isHost: false,
              isNewStream: false,
              isCopublisher: true,
            );

            await _controller.sortParticipants();
          }
        },
      ),
    );
  }

  // Function to handle showing copublishing host bottom sheet
  void copublishingHostSheet() async {
    await IsmLiveUtility.openBottomSheet(
      const IsmLiveCopublishingHostSheet(),
      isScrollController: true,
    );
  }

  void pkSheet() async {
    await IsmLiveUtility.openBottomSheet(
      const IsmLivePkSheet(),
      isScrollController: true,
    );
  }

  void rtmpSheet() async {
    await IsmLiveUtility.openBottomSheet(
      const IsmLiveRtmpSheet(),
      isScrollController: true,
    );
  }
}
