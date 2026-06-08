part of '../stream_controller.dart';

// Scheduled stream helpers.
mixin StreamJoinScheduleMixin on StreamJoinMixin {
  Future<IsmLiveScheduleRTCModule?> goLiveSchedule() async {
    var payload = IsmLiveScheduleStreamParam(
      audioOnly: _controller.streamDetails?.audioOnly,
      enableRecording: _controller.streamDetails?.isRecorded,
      eventId: _controller.streamDetails?.eventId,
      hdBroadcast: _controller.streamDetails?.hdBroadcast,
      isPaid: _controller.streamDetails?.isPaid,
      isPublicStream: _controller.streamDetails?.isPublicStream,
      isSelfHosted: true,
      isometrikUserId: _controller.streamDetails?.userId,
      lowLatencyMode: true,
      members: _controller.streamDetails?.members,
      multiLive: true,
      paymentAmount: _controller.streamDetails?.paymentAmount,
      paymentCurrencyCode: _controller.streamDetails?.paymentCurrencyCode,
      persistRtmpIngestEndpoint:
          _controller.streamDetails?.persistRtmpIngestEndpoint,
      products: _controller.streamDetails?.products,
      productsLinked: _controller.streamDetails?.productsLinked,
      restream: _controller.streamDetails?.restream,
      rtmpIngest: _controller.streamDetails?.rtmpIngest,
      saleType: 1,
      streamDescription: _controller.streamDetails?.streamDescription,
      streamImage: _controller.streamDetails?.streamImage,
      streamTitle: (_controller.streamDetails?.streamTitle?.isEmpty ?? true)
          ? 'My stream'
          : _controller.streamDetails?.streamTitle,
      userName: _controller.streamDetails?.userDetails?.userName,
    );
    return await _controller.goliveScheduleStream(payload);
  }

  void startSeduleStream(
    IsmLiveStreamDataModel stream, {
    bool isHost = true,
    bool isScrolling = false,
    bool joinByScrolling = false,
  }) {
    _controller._streamViewLoadedCallbackTriggered = false;
    _controller.userRole =
        isHost ? IsmLiveUserRole.host() : IsmLiveUserRole.viewer();
    var details = stream.userDetails;

    _controller.streamDetails = stream;

    _controller.descriptionController.text =
        stream.streamDescription ?? _controller.descriptionController.text;

    _controller.hostDetails = IsmLiveMemberDetailsModel(
        isAdmin: false,
        isPublishing: false,
        joinTime: 0,
        metaData: details?.userMetaData ?? const IsmLiveMetaData(),
        userId: details?.id ?? '',
        userIdentifier: details?.appUserId ?? '',
        userName: details?.userName ?? '',
        userProfileImageUrl: details?.userProfile ?? '');

    // Scheduled "not started yet" preview does not join LiveKit. Do not stash a
    // placeholder Room on the controller: `completeDeferredConnection` awaits
    // `previousRoom.disconnect()`, and disconnect() on a never-connected Room can
    // block ~10s (SDK timeout)â€”the main slowdown when hosting a scheduled go-live.
    _controller.room = null;
    if (!joinByScrolling) {
      final navContext = IsmLiveUtility.navigatorKey.currentContext;
      if (navContext != null) {
        unawaited(
          IsmLiveUtility.precacheStreamCover(stream.streamImage, navContext),
        );
      }
      final previewRoom = lk.Room();
      IsmLiveRouteManagement.goToStreamView(
        isHost: isHost,
        isNewStream: false,
        room: previewRoom,
        isScrolling: isScrolling,
        streamImage: stream.streamImage,
        listener: previewRoom.createListener(),
        streamId: stream.streamId ?? '',
        isSchedule: true,
        reJoin: false, // This is for scheduled streams, not rejoin
      );
    }

    IsmLiveUtility.updateLater(() {
      // Trigger stream view loaded callback for scheduled streams (only once per stream)
      if (!_controller._streamViewLoadedCallbackTriggered) {
        _controller._streamViewLoadedCallbackTriggered = true;
        IsmLiveDelegate.streamScreenLoadedCallback?.call(
          _controller.isHost,
          _controller.hostDetails,
          stream,
        );
      }
    }, true);
  }

  void editScheduleStream(BuildContext context) async {
    String? image;
    if (_controller.streamDetails?.streamImage?.isEmpty ?? true) {
      if (_controller.pickedImage == null) {
        final file = await _controller.cameraController?.takePicture();
        if (file != null) {
          _controller.pickedImage = file;
          _controller.update([IsmGoLiveView.updateId]);
        } else {
          var file = await FileManager.pickGalleryImage();
          if (file != null) {
            _controller.pickedImage = file;
            _controller.update([IsmGoLiveView.updateId]);
          }
        }
      }

      var bytes = File(_controller.pickedImage!.path).readAsBytesSync();
      var type = _controller.pickedImage!.name.split('.').last;
      image = await _controller.uploadImage(type, bytes, context);
    }

    var res = await _controller.editScheduledStream(
      eventId: _controller.streamDetails?.eventId ?? '',
      streamImage: image ?? _controller.streamDetails?.streamImage,
      streamDescription: _controller.descriptionController.text.trim(),
    );
    _controller.streamDetails = null;
    if (res) {
      IsmLiveUtility.showCustomDialog(
        IsmLiveEditScheduleDialog(
          message:
              _controller.streamDetails?.scheduleStartTime ?? DateTime.now(),
        ),
      );
    }
  }
}