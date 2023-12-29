import 'dart:math' as math;

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

class RoomPage extends StatelessWidget {
  RoomPage({
    super.key,
  });
  final Room room = Get.arguments['room'];
  final EventsListener<RoomEvent> listener = Get.arguments['listener'];
  final String meetingId = Get.arguments['meetingId'];
  final bool audioCallOnly = Get.arguments['audioCallOnly'];
  bool get fastConnection => room.engine.fastConnectOptions != null;
  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveCallingController>(
        id: 'room',
        initState: (ismLiveBuilder) async {
          var streamController = Get.find<IsmLiveCallingController>();

          await streamController.setUpListeners(
            listener,
            room,
          );
          await streamController.sortParticipants(room);

          WidgetsBindingCompatible.instance?.addPostFrameCallback((_) {
            if (!fastConnection) {
              streamController.askPublish(room, audioCallOnly);
            }
          });
          if (lkPlatformIsMobile()) {
            await Hardware.instance.setSpeakerphoneOn(true);
          }
        },
        dispose: (ismLiveBuilder) async {
          var streamController = Get.find<IsmLiveCallingController>();
          room.removeListener(() {
            streamController.onRoomDidUpdate(room);
          });
          await listener.dispose();
          await room.dispose();
        },
        builder: (controller) => PopScope(
          canPop: false,
          child: Scaffold(
            body: Stack(
              children: [
                controller.participantTracks.isNotEmpty
                    ? ParticipantWidget.widgetFor(controller.participantTracks.first, showStatsLayer: true)
                    : const NoVideoWidget(
                        name: null,
                      ),
                Positioned(
                  bottom: IsmLiveDimens.twenty,
                  child: room.localParticipant != null
                      ? ControlsWidget(room, room.localParticipant!, meetingId: meetingId, audioCallOnly: audioCallOnly)
                      : IsmLiveDimens.box0,
                ),
                Positioned(
                  left: controller.positionX,
                  top: controller.positionY,
                  child: GestureDetector(
                    onPanUpdate: controller.onPan,
                    child: SizedBox(
                      width: Get.width * 0.9,
                      height: IsmLiveDimens.twoHundred,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: math.max(0, controller.participantTracks.length - 1),
                        itemBuilder: (BuildContext context, int index) => Container(
                          margin: IsmLiveDimens.edgeInsets4_8,
                          width: IsmLiveDimens.twoHundred - IsmLiveDimens.fifty,
                          height: IsmLiveDimens.twoHundred,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(IsmLiveDimens.twenty),
                            child: GestureDetector(
                              onTap: () {
                                controller.onClick(index);
                              },
                              child: ParticipantWidget.widgetFor(controller.participantTracks[index + 1], showStatsLayer: true),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
