part of '../stream_controller.dart';

mixin StreamOngoingScrollMixin on StreamOngoingMixin, StreamOngoingDisconnectMixin {
  bool onChangeCall = false;

  int? _pendingScrollIndex;

  void onStreamScroll({
    required int index,
    required BuildContext context,
  }) async {
    var shouldShowStoppedPresenceDialog = false;
    if (onChangeCall) {
      _pendingScrollIndex = index;
      return;
    }

    // Guard: avoid RangeError when streams list is empty or index is invalid
    if (_controller.streams.isEmpty ||
        index < 0 ||
        index >= _controller.streams.length) {
      return;
    }

    // Notify host app about stream scroll (fire and forget)
    IsmLiveDelegate.streamScreenConfigure.onStreamScrollCallback?.call(
      context,
      _controller.streamId ?? '',
      index,
      _controller.streams[index],
      _controller.isHost,
    );

    IsmLiveDelegate.trackEvent(
      IsmLiveAnalyticsEvent.streamScroll,
      properties: [
        {
          'current_stream_id': _controller.streamId ?? '',
          'next_stream_index': index,
          'next_stream_id': _controller.streams[index].streamId ?? '',
          'is_host': _controller.isHost,
        }
      ],
    );

    IsmLiveUtility.showLoader();
    onChangeCall = true;
    _pendingScrollIndex = null;

    // Cancel any in-flight deferred connection from the initial stream load.
    // Without this, completeDeferredConnection can race with the scroll-based
    // disconnect+join, causing ICE timeout and a broken state.
    _controller.pendingConnection = false;

    if (_controller.streams.length - 1 == index + 1) {
      unawaited(_controller.getStreams(
        skip: _controller.streams.length,
        type: _controller.streamType,
      ));
    }

    try {
      final didLeft = await disconnectStream(
        isHost: false,
        streamId: _controller.streamId ?? '',
        goBack: false,
        isScrolling: true,
      );
      if (!didLeft) {
        IsmLiveLog.error('Cannot leave stream');
      }

      // If user scrolled further while we were disconnecting, skip joining
      // the intermediate stream and jump straight to the latest target.
      if (_pendingScrollIndex != null && _pendingScrollIndex != index) {
        return;
      }

      final targetStream = _controller.streams[index];
      final targetStreamId = targetStream.streamId;
      if (_controller.isStreamStoppedByPresence(targetStreamId)) {
        shouldShowStoppedPresenceDialog = true;
        return;
      }

      if ((targetStream.isPaid ?? false) && !(targetStream.isBuy ?? false)) {
        IsmLiveUtility.closeLoader();
        _controller.paidStreamSheet(
            coins: targetStream.amount ?? 0,
            onTap: () async {
              IsmLiveRoute.pop();
              var res = await _controller.buyStream(targetStream.streamId ?? '');
              if (res) {
                targetStream.copyWith(isBuy: true);
                await _controller.joinStream(
                  targetStream,
                  false,
                  joinByScrolling: true,
                  isScrolling: true,
                  context: context,
                );
              }
            });
      } else {
        await _controller.joinStream(
          targetStream,
          false,
          joinByScrolling: true,
          isScrolling: true,
          context: context,
        );
      }

      _controller.previousStreamIndex = index;
    } catch (e, st) {
      IsmLiveLog.error('onStreamScroll error: $e', st);
    } finally {
      onChangeCall = false;
      IsmLiveUtility.closeLoader();

      if (shouldShowStoppedPresenceDialog) {
        _controller.showStoppedPresenceUnavailableDialog();
      } else {
        // Process the latest pending scroll after this operation completes.
        // This runs inside finally so onChangeCall is already false, and the
        // recursive call will set it back to true synchronously (before its
        // first await), preventing concurrent entry.
        final pending = _pendingScrollIndex;
        if (pending != null) {
          _pendingScrollIndex = null;
          onStreamScroll(index: pending, context: context);
        }
      }
    }
  }

}