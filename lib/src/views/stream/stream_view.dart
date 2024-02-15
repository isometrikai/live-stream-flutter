import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livekit_client/livekit_client.dart';

class IsmLiveStreamView extends StatelessWidget {
  IsmLiveStreamView({
    super.key,
  })  : room = Get.arguments['room'],
        listener = Get.arguments['listener'],
        streamImage = Get.arguments['streamImage'],
        streamId = Get.arguments['streamId'],
        audioCallOnly = Get.arguments['audioCallOnly'],
        isHost = Get.arguments['isHost'],
        isNewStream = Get.arguments['isNewStream'];

  final RoomListener listener;
  final Room room;
  final String? streamImage;
  final String streamId;
  final bool audioCallOnly;
  final bool isHost;
  final bool isNewStream;

  bool get fastConnection => room.engine.fastConnectOptions != null;

  static const String route = IsmLiveRoutes.streamView;

  static const String updateId = 'ismlive-stream-view';

  @override
  Widget build(BuildContext context) {
    if (isHost) {
      return _IsmLiveStreamView(
        key: key,
        streamImage: streamImage,
        streamId: streamId,
        audioCallOnly: audioCallOnly,
        isHost: isHost,
        isNewStream: isNewStream,
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
        physics: const NeverScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
        pageSnapping: true,
        onPageChanged: (index) => controller.onStreamScroll(
          index: index,
          room: room,
        ),
        itemBuilder: (_, index) {
          // IsmLiveLog.success('Next Child $index');
          final stream = controller.streams[index];
          return _IsmLiveStreamView(
            key: key,
            streamImage: stream.streamImage,
            streamId: stream.streamId ?? '',
            audioCallOnly: audioCallOnly,
            isHost: false,
            isNewStream: false,
          );
        },
      ),
    );
  }
}

class _IsmLiveStreamView extends StatelessWidget {
  const _IsmLiveStreamView({
    super.key,
    required this.streamImage,
    required this.streamId,
    required this.audioCallOnly,
    required this.isHost,
    required this.isNewStream,
  });

  final String? streamImage;
  final String streamId;
  final bool audioCallOnly;
  final bool isHost;
  final bool isNewStream;

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: IsmLiveStreamView.updateId,
        initState: (_) async {
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
        dispose: (_) async {
          var controller = Get.find<IsmLiveStreamController>();
          await controller.room?.dispose();
          controller.memberStatus = IsmLiveMemberStatus.notMember;
          controller.streamMessagesList.clear();
          controller.streamViewersList.clear();
          controller.searchUserFieldController.clear();
          controller.descriptionController.clear();
          controller.messageFieldController.clear();
          controller.searchModeratorFieldController.clear();
          controller.searchCopublisherFieldController.clear();
          controller.searchExistingMembesFieldController.clear();
          controller.searchMembersFieldController.clear();
        },
        builder: (controller) => PopScope(
          canPop: false,
          child: Scaffold(
            body: Stack(
              children: [
                IsmLiveStreamBanner(streamImage),
                IsmLivePublisherGrid(streamImage: streamImage ?? ''),
                ...controller.giftList,
                ...controller.heartList,
                Obx(
                  () => (controller.room?.localParticipant != null)
                      ? SafeArea(
                          child: Padding(
                            padding: IsmLiveDimens.edgeInsets8,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                StreamHeader(
                                  name: controller.hostDetails?.userName ?? 'U',
                                  imageUrl: controller.hostDetails?.userProfileImageUrl ?? '',
                                  onTapCross: () {
                                    FocusScope.of(context).unfocus();
                                    controller.onExit(
                                      isHost: controller.isHost ?? false,
                                      streamId: streamId,
                                    );
                                  },
                                  onTapModerators: () {
                                    IsmLiveUtility.openBottomSheet(
                                      const IsmLiveModeratorsSheet(),
                                      isScrollController: true,
                                    );
                                  },
                                  onTapViewers: () {
                                    IsmLiveUtility.openBottomSheet(
                                      GetBuilder<IsmLiveStreamController>(
                                        id: IsmLiveStreamView.updateId,
                                        builder: (controller) => IsmLiveListSheet(
                                          scrollController: controller.viewerListController,
                                          items: controller.streamViewersList,
                                          trailing: (_, viewer) => controller.isModerator
                                              ? IsmLiveButton.icon(
                                                  icon: Icons.person_remove_rounded,
                                                  onTap: () {
                                                    controller.kickoutViewer(
                                                      streamId: streamId,
                                                      viewerId: viewer.userId,
                                                    );
                                                  },
                                                )
                                              : const IsmLiveButton.icon(
                                                  icon: Icons.group_add_rounded,
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
                                      IsmLiveChatView(
                                        isHost: controller.isHost ?? false,
                                        streamId: streamId,
                                      ),
                                      const Spacer(),
                                      IsmLiveControlsWidget(
                                        isHost: (controller.isHost ?? false) || (controller.isCopublisher ?? false),
                                        streamId: streamId,
                                        audioCallOnly: audioCallOnly,
                                      ),
                                    ],
                                  ),
                                ),
                                IsmLiveDimens.boxHeight8,
                                IsmLiveMessageField(
                                  streamId: streamId,
                                  isHost: (controller.isHost ?? false) || (controller.isCopublisher ?? false),
                                ),
                              ],
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                if (controller.isHost ?? false) ...[
                  Positioned(
                    bottom: IsmLiveDimens.eighty,
                    left: IsmLiveDimens.sixteen,
                    child: const IsmLiveModerationWarning(),
                  ),
                  if (isNewStream)
                    const IsmLiveCounterView(
                      onCompleteSheet: YourLiveSheet(),
                    ),
                ],
              ],
            ),
          ),
        ),
      );
}
