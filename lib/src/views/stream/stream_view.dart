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
    if (isHost) {
      return _IsmLiveStreamView(
        key: key,
        imageUrl: imageUrl,
        streamId: streamId,
        audioCallOnly: audioCallOnly,
        isHost: isHost,
      );
    }
    return GetX<IsmLiveStreamController>(
      initState: (_) {
        IsmLiveUtility.updateLater(() {
          var controller = Get.find<IsmLiveStreamController>();
          controller.previousStreamIndex = controller.pageController?.page?.toInt() ?? 0;
        });
      },
      builder: (controller) => PageView.builder(
        itemCount: controller.streams.length,
        controller: controller.pageController,
        scrollDirection: Axis.vertical,
        pageSnapping: true,
        onPageChanged: (index) => controller.onStreamScroll(index: index, room: room),
        itemBuilder: (_, index) {
          IsmLiveLog.success('Next Child $index');
          final stream = controller.streams[index];
          return _IsmLiveStreamView(
            key: key,
            imageUrl: stream.streamImage,
            streamId: stream.streamId ?? '',
            audioCallOnly: audioCallOnly,
            isHost: false,
          );
        },
      ),
    );
  }
}

class _IsmLiveStreamView extends StatelessWidget {
  const _IsmLiveStreamView({
    super.key,
    required this.imageUrl,
    required this.streamId,
    required this.audioCallOnly,
    required this.isHost,
  });

  final String? imageUrl;
  final String streamId;
  final bool audioCallOnly;
  final bool isHost;

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: IsmLiveStreamView.updateId,
        initState: (ismLiveBuilder) async {
          var streamController = Get.find<IsmLiveStreamController>()
            ..initializeStream(
              streamId: streamId,
              isHost: isHost,
            );

          IsmLiveUtility.updateLater(() {
            if (isHost) {
              streamController.askPublish(audioCallOnly);
            }
          });
        },
        dispose: (ismLiveBuilder) async {
          await Get.find<IsmLiveStreamController>().room?.dispose();
          Get.find<IsmLiveStreamController>().streamMessagesList = [];
        },
        builder: (controller) => PopScope(
          canPop: false,
          child: Scaffold(
            body: Stack(
              children: [
                Obx(
                  () => controller.participantTracks.isNotEmpty
                      ? ParticipantWidget.widgetFor(
                          controller.participantTracks.first,
                          showStatsLayer: false,
                        )
                      : NoVideoWidget(imageUrl: imageUrl ?? ''),
                ),
                Obx(
                  () => (controller.room?.localParticipant != null)
                      ? SafeArea(
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
                                        isHost: isHost,
                                        streamId: streamId,
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
                        )
                      : const SizedBox.shrink(),
                ),
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
