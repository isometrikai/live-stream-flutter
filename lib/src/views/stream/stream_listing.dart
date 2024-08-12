import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class IsmLiveStreamListing extends StatefulWidget {
  const IsmLiveStreamListing({super.key});

  static const String updateId = 'ismlive-stream-view';

  static const String route = IsmLiveRoutes.streamListing;

  @override
  State<IsmLiveStreamListing> createState() => _IsmLiveStreamListingState();
}

class _IsmLiveStreamListingState extends State<IsmLiveStreamListing> {
  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<IsmLiveMqttController>()) {
      IsmLiveMqttBinding().dependencies();
    }
    if (!Get.isRegistered<IsmLiveStreamController>()) {
      IsmLiveStreamBinding().dependencies();
    }
    IsmLiveUtility.updateLater(() {
      Get.find<IsmLiveMqttController>().setup();
    });
  }

  @override
  Widget build(BuildContext context) =>
      IsmLiveDelegate.homeScreen ??
      Scaffold(
        appBar: const IsmLiveAppbar(),
        floatingActionButton: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const IsmLiveCreateStreamFAB(),
            IsmLiveDimens.boxWidth10,
            const IsmLiveStreamingScrolling(),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: GetBuilder<IsmLiveStreamController>(
          builder: (controller) => Column(
            children: [
              TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                dividerHeight: 0,
                indicatorColor: Colors.black,
                labelPadding: IsmLiveDimens.edgeInsets8_0,
                overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                controller: controller.tabController,
                onTap: (index) {
                  controller.streamType = IsmLiveStreamType.values[index];

                  if (controller.streamType ==
                      IsmLiveStreamType.scheduledStreams) {
                    controller.fetchScheduledStream(
                        type: controller.streamType);
                    return;
                  }
                  controller.getStreams(type: controller.streamType);
                },
                tabs: [
                  ...IsmLiveStreamType.values.map(
                    IsmLiveTabButton.new,
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: controller.tabController,
                  children: [
                    ...IsmLiveStreamType.values.map(
                      (e) => _StreamListing(
                        key: ValueKey(
                            '${IsmLiveStreamListing.updateId}-${e.value}'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}

class _StreamListing extends StatelessWidget {
  const _StreamListing({
    super.key,
  });

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: IsmLiveStreamListing.updateId,
        builder: (controller) => SmartRefresher(
          controller: controller.streamRefreshController,
          enablePullDown: true,
          enablePullUp: true,
          onRefresh: () {
            if (controller.streamType == IsmLiveStreamType.scheduledStreams) {
              controller.fetchScheduledStream(type: controller.streamType);
              return;
            }
            controller.getStreams(type: controller.streamType);
          },
          onLoading: () {
            if (controller.streamType == IsmLiveStreamType.scheduledStreams) {
              controller.fetchScheduledStream(
                  type: controller.streamType, skip: controller.streams.length);
              return;
            }

            controller.getStreams(
                type: controller.streamType, skip: controller.streams.length);
          },
          child: controller.streams.isEmpty
              ? const IsmLiveEmptyScreen(
                  label: IsmLiveStrings.noStreams,
                  placeHolder: IsmLiveAssetConstants.noStreamsPlaceholder,
                )
              : Padding(
                  padding: IsmLiveDimens.edgeInsets16,
                  child: StaggeredGrid.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: IsmLiveDimens.eight,
                    mainAxisSpacing: IsmLiveDimens.eight,
                    children: controller.streams.map(
                      (e) {
                        var isCreatedByMe = e.userId == controller.user?.userId;
                        return IsmLiveTapHandler(
                          onTap: () {
                            if ((e.isPaid ?? false) && !(e.isBuy ?? false)) {
                              controller.paidStreamSheet(
                                  coins: e.amount ?? 0,
                                  onTap: () async {
                                    Get.back();
                                    var res = await controller
                                        .buyStream(e.streamId ?? '');
                                    if (res) {
                                      await controller.initializeAndJoinStream(
                                          e, isCreatedByMe);
                                    }
                                  });
                            } else {
                              controller.initializeAndJoinStream(
                                  e, isCreatedByMe);
                            }
                          },
                          child: IsmLiveStreamCard(
                            e,
                            isCreatedByMe: isCreatedByMe,
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
        ),
      );
}
