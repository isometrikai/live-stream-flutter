import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/widgets/custom_icon_button.dart';
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
          Get.find<IsmLiveStreamController>().streamMessagesList = [];
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
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                IsmLiveChat(
                                  messagesList: controller.streamMessagesList,
                                  messageListController: controller.messagesListController,
                                ),
                                const Spacer(),
                                IsmLiveControlsWidget(
                                  room,
                                  room.localParticipant!,
                                  meetingId: streamId,
                                  audioCallOnly: audioCallOnly,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: IsmLiveDimens.fifty,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: Get.width * 0.75,
                                  height: IsmLiveDimens.fortyFive,
                                  child: IsmLiveInputField(
                                    controller: controller.messageFieldController,
                                    hintText: 'Say Something…',
                                    radius: IsmLiveDimens.fifty,
                                    onchange: (value) => controller.update([IsmLiveStreamView.updateId]),
                                    textInputAction: TextInputAction.send,
                                    onFieldSubmit: (value) {
                                      controller.sendTextMessage(
                                        streamId: streamId,
                                        body: value,
                                      );
                                    },
                                    suffixIcon: IconButton(
                                        icon: Icon(
                                          Icons.send,
                                          size: IsmLiveDimens.twenty,
                                          color: controller.messageFieldController.isEmpty ? null : IsmLiveColors.primary,
                                        ),
                                        onPressed: () {
                                          // FocusScope.of(context).unfocus();
                                          if (controller.messageFieldController.isNotEmpty) {
                                            controller.sendTextMessage(
                                              streamId: streamId,
                                              body: controller.messageFieldController.text,
                                            );
                                          }
                                        }),
                                    prefixIcon: Icon(
                                      Icons.sentiment_satisfied_alt,
                                      size: IsmLiveDimens.twenty,
                                    ),
                                    borderColor: IsmLiveColors.white,
                                  ),
                                ),
                                if (!isHost) ...[
                                  const Spacer(),
                                  CustomIconButton(
                                    icon: Padding(
                                      padding: IsmLiveDimens.edgeInsets8,
                                      child: const IsmLiveImage.svg(
                                        IsmLiveAssetConstants.heart,
                                        color: IsmLiveColors.white,
                                      ),
                                    ),
                                    onTap: () async {},
                                    color: IsmLiveColors.red,
                                  ),
                                ]
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
