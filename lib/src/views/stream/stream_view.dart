// Live stream screen library. Implementation is split into [part] files under
// [stream_view/].
import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/res/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

part 'stream_view/ism_live_stream_view_body.dart';
part 'stream_view/schedule_stream_view.dart';
part 'stream_view/stream_view_chat.dart';
part 'stream_view/stream_view_cleanup.dart';
part 'stream_view/stream_view_gradients.dart';
part 'stream_view/stream_view_header.dart';

class IsmLiveStreamView extends StatelessWidget {
  /// Refactored: All arguments must be passed via the constructor.
  const IsmLiveStreamView({
    super.key,
    required this.listener,
    required this.room,
    this.streamImage,
    required this.streamId,
    required this.isHost,
    required this.isNewStream,
    required this.isScrolling,
    required this.isSchedule,
    required this.isInteractive,
  });

  final RoomListener listener;
  final Room room;
  final String? streamImage;
  final String streamId;
  final bool isHost;
  final bool isNewStream;
  final bool isScrolling;
  final bool isSchedule;
  final bool isInteractive;

  bool get fastConnection => room.engine.fastConnectOptions != null;

  static const String route = IsmLiveRoutes.streamView;
  static const String updateId = 'ismlive-stream-view';

  /// Clean up stream data when the view is closed.
  static Future<void> cleanupStreamData(
    IsmLiveStreamController controller,
  ) =>
      ismLiveStreamViewCleanupData(controller);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark, // For iOS
      ),
    );
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark, // For iOS
      ),
      child: isHost
          ? _IsmLiveStreamView(
              key: key,
              streamImage: streamImage,
              streamId: streamId,
              isHost: isHost,
              isNewStream: isNewStream,
              isInteractive: isInteractive,
              isSchedule: isSchedule,
            )
          : (!isScrolling)
              ? _IsmLiveStreamView(
                  key: key,
                  streamImage: streamImage,
                  streamId: streamId,
                  isHost: false,
                  isNewStream: false,
                  isInteractive: isInteractive,
                  isSchedule: isSchedule,
                )
              : GetX<IsmLiveStreamController>(
                  initState: (_) {
                    var controller = Get.find<IsmLiveStreamController>();

                    IsmLiveUtility.updateLater(() {
                      controller.previousStreamIndex =
                          controller.pageController?.page?.toInt() ?? 0;
                    });
                  },
                  builder: (controller) => PageView.builder(
                    itemCount: controller.streams.length,
                    controller: controller.pageController,
                    scrollDirection: Axis.vertical,
                    pageSnapping: true,
                    onPageChanged: (index) => controller.onStreamScroll(
                        index: index, context: context),
                    itemBuilder: (_, index) {
                      final stream = controller.streams[index];
                      return _IsmLiveStreamView(
                        // Important: each page must have a unique key.
                        // Reusing the same key across PageView pages can cause element reuse
                        // during partial scroll, showing stale (previous) stream UI.
                        key: ValueKey<String>(
                          'ism-live-stream-view-${stream.streamId ?? index}',
                        ),
                        streamImage: stream.streamImage,
                        streamId: stream.streamId ?? '',
                        isHost: false,
                        isNewStream: false,
                        isInteractive: isInteractive,
                        isSchedule: stream.isScheduledStream ?? isSchedule,
                      );
                    },
                  ),
                ),
    );
  }
}
