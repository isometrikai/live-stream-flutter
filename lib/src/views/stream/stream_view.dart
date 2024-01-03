import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

class IsmLiveStreamView extends StatelessWidget {
  IsmLiveStreamView({
    super.key,
  })  : room = Get.arguments['room'],
        listener = Get.arguments['listener'],
        meetingId = Get.arguments['streamId'],
        audioCallOnly = Get.arguments['audioCallOnly'],
        isHost = Get.arguments['isHost'],
        isNewStream = Get.arguments['isNewStream'];

  final Room room;
  final EventsListener<RoomEvent> listener;
  final String meetingId;
  final bool audioCallOnly;
  final bool isHost;
  final bool isNewStream;

  bool get fastConnection => room.engine.fastConnectOptions != null;

  static const String route = IsmLiveRoutes.streamView;

  static const String updateId = 'ismlive-stream-view';

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: updateId,
        initState: (ismLiveBuilder) async {
          var streamController = Get.find<IsmLiveStreamController>();
          await streamController.setUpListeners(
            isHost: isHost,
            streamId: meetingId,
            listener: listener,
            room: room,
          );
          await streamController.sortParticipants(room);

          IsmLiveUtility.updateLater(() {
            if (!fastConnection) {
              streamController.askPublish(room, audioCallOnly);
            }
          });
          if (lkPlatformIsMobile()) {
            await Hardware.instance.setSpeakerphoneOn(true);
          }
        },
        dispose: (ismLiveBuilder) async {
          var streamController = Get.find<IsmLiveStreamController>();
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
                    ? ParticipantWidget.widgetFor(
                        controller.participantTracks.first,
                        showStatsLayer: false)
                    : const NoVideoWidget(
                        name: null,
                      ),
                SizedBox(
                  height: Get.height,
                  width: Get.width,
                  child: const ColoredBox(
                    color: Colors.black38,
                  ),
                ),

                if (room.localParticipant != null) ...[
                  SafeArea(
                    child: Padding(
                      padding: IsmLiveDimens.edgeInsets16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          StreamHeader(
                            name: controller.user?.userName ?? 'U',
                            imageUrl: controller.user?.profileUrl ?? '',
                            onTabCross: () {
                              controller.onExit(
                                isHost: isHost,
                                room: room,
                                streamId: meetingId,
                              );
                            },
                            onTabViewers: () {
                              IsmLiveUtility.openBottomSheet(
                                Obx(() => IsmLiveListSheet(
                                    list: controller.streamViewersList)),
                              );
                            },
                          ),
                          IsmLiveControlsWidget(
                            room,
                            room.localParticipant!,
                            meetingId: meetingId,
                            audioCallOnly: audioCallOnly,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                // Positioned(
                //   left: controller.positionX,
                //   top: controller.positionY,
                //   child: GestureDetector(
                //     onPanUpdate: controller.onPan,
                //     child: SizedBox(
                //       width: Get.width * 0.9,
                //       height: IsmLiveDimens.twoHundred,
                //       child: ListView.builder(
                //         shrinkWrap: true,
                //         scrollDirection: Axis.horizontal,
                //         itemCount: math.max(0, controller.participantTracks.length - 1),
                //         itemBuilder: (BuildContext context, int index) => Container(
                //           margin: IsmLiveDimens.edgeInsets4_8,
                //           width: IsmLiveDimens.twoHundred - IsmLiveDimens.fifty,
                //           height: IsmLiveDimens.twoHundred,
                //           child: ClipRRect(
                //             borderRadius: BorderRadius.circular(IsmLiveDimens.twenty),
                //             child: GestureDetector(
                //               onTap: () {
                //                 controller.onClick(index);
                //               },
                //               child: ParticipantWidget.widgetFor(controller.participantTracks[index + 1], showStatsLayer: true),
                //             ),
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                if (isHost && isNewStream) ...[
                  Positioned(
                    bottom: IsmLiveDimens.sixteen,
                    left: IsmLiveDimens.sixteen,
                    child: const IsmLiveModerationWarning(),
                  ),
                  const IsmLiveCounterView(onCompleteSheet: YourLiveSheet()),
                ],
              ],
            ),
          ),
        ),
      );
}
