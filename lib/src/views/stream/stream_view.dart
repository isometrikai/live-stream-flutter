import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/views/stream/views/counter_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

class IsmLiveStreamView extends StatelessWidget {
  IsmLiveStreamView({
    Key? key,
  })  : room = Get.arguments['room'],
        listener = Get.arguments['listener'],
        meetingId = Get.arguments['streamId'],
        audioCallOnly = Get.arguments['audioCallOnly'],
        super(key: key);

  final Room room;
  final EventsListener<RoomEvent> listener;
  final String meetingId;
  final bool audioCallOnly;

  bool get fastConnection => room.engine.fastConnectOptions != null;

  static const String route = IsmLiveRoutes.streamView;

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: 'room',
        initState: (ismLiveBuilder) async {
          var streamController = Get.find<IsmLiveStreamController>();
          streamController.initialApiCalls(meetingId);
          await streamController.setUpListeners(
            listener,
            room,
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

                room.localParticipant != null
                    ? SafeArea(
                        child: Padding(
                          padding: IsmLiveDimens.edgeInsets16,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              StreamHeader(
                                name: controller.hostDetails?.userName ?? 'U',
                                viewerCont: controller.streamViewersList.length,
                                imageUrl: controller
                                        .hostDetails?.userProfileImageUrl ??
                                    '',
                                viewerList: controller.streamViewersList,
                                onTabCross: () {
                                  controller.onExist(room, meetingId);
                                },
                                onTabViewers: () {
                                  IsmLiveUtility.openBottomSheet(
                                      IsmLiveListSheet(
                                          list: controller.streamViewersList),
                                      isScrollController: true);
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
                      )
                    : IsmLiveDimens.box0,

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
                const IsmLiveCounterView(),
              ],
            ),
          ),
        ),
      );
}
