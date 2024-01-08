import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

class IsmLiveStreamView extends StatelessWidget {
  IsmLiveStreamView({
    super.key,
  })  : room = Get.arguments['room'],
        listener = Get.arguments['listener'],
        imageUrl = Get.arguments['imageUrl'],
        streamId = Get.arguments['streamId'],
        audioCallOnly = Get.arguments['audioCallOnly'],
        isHost = Get.arguments['isHost'];

  final RoomListener listener;
  final Room room;
  final String? imageUrl;
  final String streamId;
  final bool audioCallOnly;
  final bool isHost;

  bool get fastConnection => room.engine.fastConnectOptions != null;

  static const String route = IsmLiveRoutes.streamView;

  static const String updateId = 'ismlive-stream-view';

  @override
  Widget build(BuildContext context) {
    final child = _IsmLiveStreamView(
      key: key,
      room: room,
      listener: listener,
      imageUrl: imageUrl,
      streamId: streamId,
      audioCallOnly: audioCallOnly,
      isHost: isHost,
    );
    if (isHost) {
      return child;
    }
    return GetX<IsmLiveStreamController>(
      builder: (controller) => PageView.builder(
        itemCount: controller.streams.length,
        onPageChanged: (index) => controller.onStreamScroll(index: index, room: room),
        itemBuilder: (_, index) => child,
      ),
    );
  }
}

class _IsmLiveStreamView extends StatelessWidget {
  const _IsmLiveStreamView({
    super.key,
    required this.room,
    required this.listener,
    required this.imageUrl,
    required this.streamId,
    required this.audioCallOnly,
    required this.isHost,
  });

  final Room room;
  final RoomListener listener;
  final String? imageUrl;
  final String streamId;
  final bool audioCallOnly;
  final bool isHost;

  bool get fastConnection => room.engine.fastConnectOptions != null;

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: IsmLiveStreamView.updateId,
        initState: (ismLiveBuilder) async {
          var streamController = Get.find<IsmLiveStreamController>()
            ..initializeStream(
              streamId: streamId,
              room: room,
              listener: listener,
              isHost: isHost,
            );

          IsmLiveUtility.updateLater(() {
            if (!fastConnection) {
              streamController.askPublish(room, audioCallOnly);
            }
          });
        },
        dispose: (ismLiveBuilder) async {
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
                        showStatsLayer: false,
                      )
                    : NoVideoWidget(imageUrl: imageUrl ?? ''),

                if (room.localParticipant != null) ...[
                  SafeArea(
                    child: Padding(
                      padding: IsmLiveDimens.edgeInsets16,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          StreamHeader(
                            name: controller.hostDetails?.userName ?? 'U',
                            imageUrl: controller.hostDetails?.userProfileImageUrl ?? '',
                            onTabCross: () {
                              FocusScope.of(context).unfocus();
                              controller.onExit(
                                isHost: isHost,
                                room: room,
                                streamId: streamId,
                              );
                            },
                            onTabViewers: () {
                              IsmLiveUtility.openBottomSheet(
                                GetBuilder<IsmLiveStreamController>(
                                  id: IsmLiveStreamView.updateId,
                                  builder: (controller) => IsmLiveListSheet(
                                    scrollController: controller.viewerListController,
                                    items: controller.streamViewersList,
                                    trailing: (_, viewer) => SizedBox(
                                      width: IsmLiveDimens.eighty,
                                      child: isHost
                                          ? IsmLiveButton(
                                              label: 'Kickout',
                                              small: true,
                                              onTap: () {
                                                controller.kickoutViewer(
                                                  streamId: streamId,
                                                  viewerId: viewer.userId,
                                                );
                                              },
                                            )
                                          : const IsmLiveButton(
                                              label: 'Follow',
                                              small: true,
                                            ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          IsmLiveControlsWidget(
                            room,
                            room.localParticipant!,
                            meetingId: streamId,
                            audioCallOnly: audioCallOnly,
                          ),
                          IsmLiveInputField(
                            controller: controller.messageFieldController,
                            hintText: 'Say Something…',
                            radius: IsmLiveDimens.fifty,
                            onFieldSubmit: (value) {
                              controller.onFieldSubmit(
                                streamId: streamId,
                                body: value,
                                messageType: 1,
                              );
                            },
                            prefixIcon: Icon(
                              Icons.sentiment_satisfied_alt,
                              size: IsmLiveDimens.twenty,
                            ),
                            borderColor: IsmLiveColors.white,
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
                if (isHost) ...[
                  Positioned(
                    bottom: IsmLiveDimens.eighty,
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
