part of '../stream_controller.dart';

mixin StreamSheetMixin {
  IsmLiveStreamController get _controller => Get.find();

  Color? _sheetBackgroundColor(BuildContext context) =>
      context.liveTheme?.backgroundColor ??
      (Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF121212)
          : Colors.white);

  // Function to handle exit actions from the stream
  Future<void> onExit({
    required bool isHost,
    required String streamId,
    required BuildContext context,
    bool showViewerLeaveDialog = false,
  }) async {
    FocusScope.of(context).unfocus();

    if (isHost || (_controller.isCopublisher)) {
      await IsmLiveUtility.openCustomBottomSheet(
        title: isHost
            ? IsmLiveStrings.areYouSureEndStream
            : IsmLiveStrings.areYouSureLeaveStream,
        leftLabel: isHost ? IsmLiveStrings.cancel : IsmLiveStrings.stopStream,
        rightLabel:
            isHost ? IsmLiveStrings.endStream : IsmLiveStrings.leaveStream,
        onLeft: isHost
            ? IsmLiveRoute.pop
            : () async {
                IsmLiveRoute.pop();
                await _controller.disconnectStream(
                  isHost: isHost,
                  streamId: streamId,
                  endStream: false,
                );
              },
        onRight: () async {
          IsmLiveRoute.pop();

          await _controller.disconnectStream(
            isHost: isHost,
            streamId: streamId,
          );
        },
        isDismissible: false,
        backgroundColor: _sheetBackgroundColor(context),
      );
    } else {
      if (showViewerLeaveDialog) {
        await IsmLiveUtility.openCustomBottomSheet(
          title: IsmLiveStrings.areYouSureLeaveStream,
          leftLabel: IsmLiveStrings.cancel,
          rightLabel: IsmLiveStrings.leaveStream,
          onLeft: IsmLiveRoute.pop,
          onRight: () async {
            IsmLiveRoute.pop();
            await _controller.disconnectStream(
              isHost: isHost,
              streamId: streamId,
            );
          },
          isDismissible: false,
          backgroundColor: _sheetBackgroundColor(context),
        );
      } else {
        await _controller.disconnectStream(
          isHost: isHost,
          streamId: streamId,
        );
      }
    }
  }

// Function to handle showing gifts bottom sheet
  void giftsSheet() async {
    final context = IsmLiveUtility.navigatorKey.currentContext!;
    await IsmLiveUtility.openBottomSheet(
      IsmLiveGiftsSheet(
        onTap: (gift) => _controller.sendGiftMessage(
          streamId: _controller.streamId ?? '',
          gift: gift,
        ),
      ),
      isScrollController: true,
      backgroundColor: _sheetBackgroundColor(context),
    );
  }

// Function to handle showing settings bottom sheet
  void settingSheet() async {
    final context = IsmLiveUtility.navigatorKey.currentContext!;
    await IsmLiveUtility.openBottomSheet(
      const IsmLiveSettingsSheet(),
      backgroundColor: _sheetBackgroundColor(context),
    );
  }

  void pkChallengeSheet() async {
    final context = IsmLiveUtility.navigatorKey.currentContext!;
    await IsmLiveUtility.openBottomSheet(
      const IsmLivePkChallengeSheet(),
      backgroundColor: _sheetBackgroundColor(context),
    );
  }

  /// Same path as tapping Multi Live in stream controls: delegate callback first,
  /// then default `onOptionTap`.
  Future<void> presentViewerMultiLiveAsIfTapped(BuildContext context) async {
    final controlCallback = IsmLiveDelegate.controlOptionCallback;
    if (controlCallback != null) {
      final handled = await controlCallback(
        context,
        IsmLiveStreamOption.multiLive,
        _controller.streamId ?? '',
        _controller.isHost,
        _controller.isCopublisher,
      );
      if (handled) {
        _controller.update([IsmLiveControlsWidget.updateId]);
        return;
      }
    }
    await _controller.onOptionTap(IsmLiveStreamOption.multiLive, context);
    _controller.update([IsmLiveControlsWidget.updateId]);
  }

  /// After the host adds this viewer as co-publisher ([IsmLiveMemberStatus.gotRequest]),
  /// opens the same Multi Live flow as a manual tap once the frame is ready.
  void scheduleAutoOpenCopublishInviteSheetForViewer() {
    if (_controller.isHost) {
      return;
    }
    if (_controller.isCopublisher) {
      return;
    }
    if (!_controller.memberStatus.receivedRequest) {
      return;
    }
    if (_controller._autoOpenedCopublishHostInviteSheet) {
      return;
    }
    _controller._autoOpenedCopublishHostInviteSheet = true;

    IsmLiveUtility.updateLater(() {
      Future.delayed(const Duration(milliseconds: 120), () {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          final ctx = IsmLiveUtility.navigatorKey.currentContext;
          if (ctx == null || !ctx.mounted) {
            _controller._autoOpenedCopublishHostInviteSheet = false;
            return;
          }
          if (_controller.isHost || _controller.isCopublisher) {
            _controller._autoOpenedCopublishHostInviteSheet = false;
            return;
          }
          if (!_controller.memberStatus.receivedRequest) {
            _controller._autoOpenedCopublishHostInviteSheet = false;
            return;
          }
          await _controller.presentViewerMultiLiveAsIfTapped(ctx);
        });
      });
    });
  }

  // Function to handle showing copublishing viewer bottom sheet
  void copublishingViewerSheet(BuildContext context) async {
    await IsmLiveUtility.openBottomSheet(
      IsmLiveCopublishingViewerSheet(
          title: context.liveTranslations?.requestCopublishingTitle ??
              IsmLiveStrings.requestCopublishingTitle,
          description:
              context.liveTranslations?.requestCopublishingDescription ??
                  IsmLiveStrings.requestCopublishingDescription,
          label: _controller.memberStatus.isRejected
              ? IsmLiveStrings.requestDeniedByHost
              : _controller.memberStatus.didRequested
                  ? IsmLiveStrings.requestedCopublishing
                  : IsmLiveStrings.sendRequest,
          images: [
            _controller.user?.profileUrl ?? '',
            _controller.hostDetails?.userProfileImageUrl ?? '',
          ],
          imageNames: [
            _controller.user?.name ?? '',
            _controller.hostDetails?.name ?? '',
          ],
          imageInitials: [
            _controller.user?.profileInitials,
            _controller.hostDetails?.profileInitials,
          ],
          onTap: _controller.memberStatus.didRequested ||
                  _controller.memberStatus.isRejected
              ? null
              : () async {
                  final isSent = await _controller.requestCopublisher(
                    _controller.streamId ?? '',
                  );
                  if (isSent) {
                    _controller.memberStatus = IsmLiveMemberStatus.requested;
                  }
                }),
      backgroundColor: _sheetBackgroundColor(context),
    );
  }

// Function to handle showing copublishing start video bottom sheet
  void copublishingStartVideoSheet(BuildContext context) async {
    await IsmLiveUtility.openBottomSheet(
      IsmLiveCopublishingViewerSheet(
        title: IsmLiveStrings.youAreNowACopublisher,
        // (context.liveTranslations?.hostAcceptedCopublishRequestTitle ??
        //         IsmLiveStrings.hostAcceptedCopublishRequestTitle)
        //     .trParams({
        //   'name': _controller.hostDetails?.userName ?? 'Host',
        // }),
        description: IsmLiveStrings.youCanJoinTheLiveStreamAndStartPublishingYourVideo,
            // context.liveTranslations?.hostAcceptedCopublishRequestDescription ??
            //     IsmLiveStrings.hostAcceptedCopublishRequestDescription,
        label: IsmLiveStrings.startVideo,
        images: [
          IsmLiveDelegate.getUserProfileUrl
              ?.call(_controller.user?.profileUrl ?? '') ??
              _controller.user?.profileUrl ?? '',
        ],
        imageNames: [
          _controller.user?.name ?? '',
        ],
        imageInitials: [
          _controller.user?.profileInitials,
        ],
        onTap: () async {
          if (_controller.room != null) {
            var token = await _controller.switchViewer(
                streamId: _controller.streamId ?? '');
            if (token == null) {
              return;
            }
            await _controller.room!.disconnect();

            await _controller.connectStream(
                token: token,
                streamId: _controller.streamId ?? '',
                isHost: false,
                isNewStream: false,
                isCopublisher: true,
                context: context,
                reJoin: true);

            await _controller.sortParticipants();
          }
        },
      ),
      backgroundColor: _sheetBackgroundColor(context),
    );
  }

  // Function to handle showing copublishing host bottom sheet
  void copublishingHostSheet() async {
    final context = IsmLiveUtility.navigatorKey.currentContext!;
    await IsmLiveUtility.openBottomSheet(
      const IsmLiveCopublishingHostSheet(),
      isScrollController: true,
      backgroundColor: _sheetBackgroundColor(context),
    );
  }

  void schgeduleStreamSheet() async {
    final context = IsmLiveUtility.navigatorKey.currentContext!;
    await IsmLiveUtility.openBottomSheet(
      const IsmLiveScheduleSettingsSheet(),
      backgroundColor: _sheetBackgroundColor(context),
    );
  }

  void pkSheet() async {
    final context = IsmLiveUtility.navigatorKey.currentContext!;
    await IsmLiveUtility.openBottomSheet(
      const IsmLivePkSheet(),
      isScrollController: true,
      backgroundColor: _sheetBackgroundColor(context),
    );
  }

  void shareStream() async {
    try {
      final result =
          await Share.share('check out my website https://example.com');

      if (result.status == ShareResultStatus.success) {
        print('Thank you for sharing my website!');
      }
    } catch (e) {
      IsmLiveLog.error(e);
    }
  }

  void rtmpSheet() async {
    final context = IsmLiveUtility.navigatorKey.currentContext!;
    await IsmLiveUtility.openBottomSheet(
      const IsmLiveRtmpSheet(),
      isScrollController: true,
      backgroundColor: _sheetBackgroundColor(context),
    );
  }

  void paidStreamSheet({required num coins, required Function() onTap}) async {
    final context = IsmLiveUtility.navigatorKey.currentContext!;
    await IsmLiveUtility.openCustomBottomSheet(
      title: IsmLiveStrings.premiumStreamPayToJoinMessage.replaceFirst(
        '%s',
        coins.toString(),
      ),
      leftLabel: IsmLiveStrings.cancel,
      rightLabel: IsmLiveStrings.payAndContinue,
      onLeft: IsmLiveRoute.pop,
      onRight: onTap,
      isScrollController: true,
      backgroundColor: _sheetBackgroundColor(context),
    );
  }

  void premiumStreamSheet() async {
    final context = IsmLiveUtility.navigatorKey.currentContext!;
    await IsmLiveUtility.openBottomSheet(
      IsmLivePremiumStreamSheet(
        textController: _controller.premiumStreamCoinsController,
        onTap: () {
          if (_controller.premiumStreamCoinsController.isNotEmpty) {
            IsmLiveRoute.pop();
            _controller.update([IsmGoLiveView.updateId]);
          }
        },
      ),
      isScrollController: true,
      backgroundColor: _sheetBackgroundColor(context),
    );
  }
}
