part of '../stream_controller.dart';

mixin StreamOngoingControlsMixin
    on StreamOngoingMixin, StreamOngoingSocialMixin {
  /// Remote publication enable/disable controls server/adaptive settings, not
  /// what you hear. Toggle each remote audio track's enable/disable so the
  /// underlying WebRTC track matches the speaker UI.
  Future<void> _syncRemoteAudioPlaybackWithSpeakerFlag(lk.Room room) async {
    final speakerOn = _controller.speakerOn;

    // Route audio to the loudspeaker when enabling. Mobile WebRTC defaults to
    // the earpiece/receiver; without this call viewers hear audio from the
    // wrong speaker (or faintly through the receiver when muted).
    // The helper respects external devices (Bluetooth/wired) on Android.
    if (speakerOn) {
      await _ensureLoudspeakerRouting(forRoom: room);
    }

    final futures = <Future<void>>[];
    for (final participant in room.remoteParticipants.values) {
      for (final pub in participant.audioTrackPublications) {
        final track = pub.track;
        if (track == null) {
          continue;
        }
        futures.add(() async {
          try {
            if (speakerOn) {
              await track.enable();
            } else {
              await track.disable();
            }
            // Belt-and-suspenders: directly flip the underlying WebRTC
            // MediaStreamTrack. On some mobile platforms the higher-level
            // enable/disable alone does not silence the audio renderer.
            try {
              track.mediaStreamTrack.enabled = speakerOn;
            } catch (_) {}
          } catch (e) {
            IsmLiveLog('speaker remote audio track error $e');
          }
        }());
      }
    }
    await Future.wait(futures);
  }

  Future<void> toggleSpeaker({
    bool? value,
  }) async {
    // Update UI state immediately (even if there are no remote audio tracks yet).
    final nextValue = value ?? !_controller.speakerOn;
    _controller.speakerOn = nextValue;
    _controller.update([
      IsmLiveStreamView.updateId,
      IsmLiveControlsWidget.updateId,
    ]);

    final room = _controller.room;
    if (room == null) {
      return;
    }

    try {
      await _syncRemoteAudioPlaybackWithSpeakerFlag(room);
    } catch (e) {
      IsmLiveLog('speaker error $e');
    }
  }

  Future onOptionTap(IsmLiveStreamOption option, BuildContext context) async {
    switch (option) {
      case IsmLiveStreamOption.gift:
        _controller.giftsSheet();
        break;
      case IsmLiveStreamOption.multiLive:
        if (_controller.isHost || _controller.isPublishing) {
          _controller.copublishingHostSheet();
        } else {
          if (_controller.memberStatus.canEnableVideo) {
            _controller.copublishingStartVideoSheet(context);
          } else {
            _controller.copublishingViewerSheet(context);
          }
        }

        break;
      case IsmLiveStreamOption.share:
        _controller.shareStream();
        break;
      case IsmLiveStreamOption.members:
        break;
      case IsmLiveStreamOption.scheduleModify:
        _controller.schgeduleStreamSheet();
        break;
      case IsmLiveStreamOption.settings:
        _controller.settingSheet();
        break;
      case IsmLiveStreamOption.product:
        IsmLiveRouteManagement.goToTagProduct();
        break;
      case IsmLiveStreamOption.rotateCamera:
        _controller.toggleCamera();
        break;
      case IsmLiveStreamOption.videoEffects:
        _controller.videoEffectsSheet();
        break;
      case IsmLiveStreamOption.speaker:
        await toggleSpeaker();
        break;
      case IsmLiveStreamOption.bars:
        final context = IsmLiveUtility.navigatorKey.currentContext!;
        await IsmLiveUtility.openBottomSheet(
          IsmliveAnalyticsSheet(
            streamId: (_controller.userRole?.isPkGuest ?? false)
                ? _pkController.pkguestStreamId ?? ''
                : _controller.streamId ?? '',
          ),
          backgroundColor: context.liveTheme?.backgroundColor ??
              (Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF121212)
                  : Colors.white),
        );
        break;
      case IsmLiveStreamOption.vs:
        _controller.pkSheet();
        break;
      case IsmLiveStreamOption.heart:
        // Tap feedback runs from the stream controls widget via native Android/iOS.
        _addLocalHeart();
        _scheduleHeartFlush();
        break;
      case IsmLiveStreamOption.pk:
        _pkController.stopPkBattleSheet();
        break;
      case IsmLiveStreamOption.rtmpDetails:
        _controller.rtmpSheet();
        break;
    }
  }

  void onSettingTap(
    IsmLiveHostSettings option,
  ) async {
    switch (option) {
      // case IsmLiveHostSettings.muteRemoteVideo:
      //   break;
      // case IsmLiveHostSettings.muteRemoteAudio:
      //   break;
      // case IsmLiveHostSettings.showNetWorkStats:
      //   break;
      // case IsmLiveHostSettings.hideChatMessages:
      //   break;
      // case IsmLiveHostSettings.hideControlButtons:
      //   break;
      case IsmLiveHostSettings.muteMyAudio:
        await _controller.toggleAudio();
        break;
      case IsmLiveHostSettings.muteMyVideo:
        _controller.toggleVideo();
        break;
      // case IsmLiveHostSettings.block:
      //   break;
      // case IsmLiveHostSettings.report:
      //   break;
    }
  }

  void onScheduleSettingTap(
    IsmLiveScheduleSettings option,
  ) async {
    switch (option) {
      case IsmLiveScheduleSettings.edit:
        IsmLiveRoute.pop();
        IsmLiveRouteManagement.goToGoLiveView(
          popPrevious: true,
          editStreamData: _controller.streamDetails,
        );
        break;
      case IsmLiveScheduleSettings.delete:
        IsmLiveRoute.pop();
        await _controller
            .deleteScheduledStream(_controller.streamDetails?.eventId ?? '');
        IsmLiveRoute.pop();
        _controller.streamDispose();
        unawaited(_controller.getStreams());
        break;
    }
  }

  Future<bool> requestBackgroundPermission([bool isRetry = false]) async {
    // Required for android screenshare.
    try {
      var hasPermissions = await FlutterBackground.hasPermissions;
      if (!isRetry) {
        final androidConfig = FlutterBackgroundAndroidConfig(
          notificationTitle: IsmLiveStrings.screenSharing,
          notificationText: IsmLiveStrings.screenSharingNotificationText(
            IsmLiveConstants.name,
          ),
          notificationIcon: const AndroidResource(
            name: 'ic_launcher',
            defType: 'mipmap',
          ),
        );
        hasPermissions = await FlutterBackground.initialize(
          androidConfig: androidConfig,
        );
      }
      if (hasPermissions && !FlutterBackground.isBackgroundExecutionEnabled) {
        return await FlutterBackground.enableBackgroundExecution();
      }
      return false;
    } catch (e, st) {
      if (!isRetry) {
        return await Future<bool>.delayed(
          const Duration(seconds: 1),
          () => requestBackgroundPermission(true),
        );
      }
      IsmLiveLog.error('Could not publish video: $e', st);
      return false;
    }
  }

  void enableScreenShare() async {
    try {
      IsmLiveUtility.showLoader();
      if (_controller.room == null ||
          _controller.room!.localParticipant == null) {
        return;
      }

      var isExecuting = await requestBackgroundPermission();
      IsmLiveLog.error(isExecuting);
      if (!isExecuting) {
        isExecuting = await requestBackgroundPermission();
      }
      if (isExecuting) {
        await _controller.room!.localParticipant!.setScreenShareEnabled(
          true,
          captureScreenAudio: true,
        );
      }
    } catch (e, st) {
      IsmLiveLog.error(e, st);
    } finally {
      IsmLiveUtility.closeLoader();
    }
  }

  void disableScreenShare() async {
    try {
      IsmLiveUtility.showLoader();
      await _controller.room!.localParticipant!.setScreenShareEnabled(
        false,
      );
      await FlutterBackground.disableBackgroundExecution();
    } catch (e, st) {
      IsmLiveLog.error(e, st);
    } finally {
      IsmLiveUtility.closeLoader();
    }
  }
}
