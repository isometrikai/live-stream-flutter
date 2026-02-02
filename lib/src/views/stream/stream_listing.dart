import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/res/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class IsmLiveStreamListing extends StatefulWidget {
  const IsmLiveStreamListing({super.key, this.showBackArrow = false});

  static const String updateId = 'ismlive-stream-view';

  static const String route = IsmLiveRoutes.streamListing;

  final bool showBackArrow;

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
  }

  @override
  Widget build(BuildContext context) =>
      IsmLiveDelegate.homeScreen ??
      Scaffold(
        appBar: IsmLiveAppbar(showBackArrow: widget.showBackArrow),
        floatingActionButton: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const IsmLiveCreateStream(),
            IsmLiveDimens.boxWidth10,
            const IsmLiveStreamingScrolling(),
            // IsmLiveDimens.boxWidth10,
            // IsmLiveTapHandler(
            //   onTap: () => Get.to<void>(() => const IsmLiveRecordingListView()),
            //   child: Container(
            //     padding: IsmLiveDimens.edgeInsets16,
            //     decoration: BoxDecoration(
            //       color:
            //           context.liveTheme?.primaryColor ?? IsmLiveColors.primary,
            //       borderRadius: BorderRadius.circular(IsmLiveDimens.sixteen),
            //     ),
            //     child: const Icon(
            //       Icons.video_library_outlined,
            //       color: Colors.white,
            //     ),
            //   ),
            // ),
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
                        streamType: e,
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

class _StreamListing extends StatefulWidget {
  const _StreamListing({
    Key? key,
    required this.streamType,
  }) : super(key: key);
  final IsmLiveStreamType streamType;

  @override
  State<_StreamListing> createState() => _StreamListingState();
}

class _StreamListingState extends State<_StreamListing> {
  late final RefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: IsmLiveStreamListing.updateId,
        builder: (controller) => SmartRefresher(
          controller: _refreshController,
          enablePullDown: true,
          enablePullUp: true,
          onRefresh: () async {
            try {
              if (widget.streamType == IsmLiveStreamType.scheduledStreams) {
                await controller.fetchScheduledStream(type: widget.streamType);
              } else {
                await controller.getStreams(type: widget.streamType);
              }
            } catch (e, st) {
              print(st);
            } finally {
              _refreshController.refreshCompleted();
            }
          },
          onLoading: () async {
            try {
              if (widget.streamType == IsmLiveStreamType.scheduledStreams) {
                await controller.fetchScheduledStream(
                    type: widget.streamType,
                    skip:
                        controller.streamsMap[widget.streamType]?.length ?? 0);
              } else {
                await controller.getStreams(
                    type: widget.streamType,
                    skip:
                        controller.streamsMap[widget.streamType]?.length ?? 0);
              }
            } catch (e, st) {
              print(st);
            } finally {
              _refreshController.loadComplete();
            }
          },
          child: controller.streamsMap[widget.streamType]!.isEmpty
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
                    children: controller.streamsMap[widget.streamType]!.map(
                      (e) {
                        var isCreatedByMe = e.userId == controller.user?.userId;
                        return IsmLiveTapHandler(
                          onTap: () {
                            if (widget.streamType ==
                                    IsmLiveStreamType.scheduledStreams &&
                                isCreatedByMe) {
                              controller.startSeduleStream(e);
                              return;
                            }

                            if ((e.isPaid ?? false) && !(e.isBuy ?? false)) {
                              controller.paidStreamSheet(
                                  coins: e.amount ?? 0,
                                  onTap: () async {
                                    IsmLiveRoute.pop();
                                    var res = await controller
                                        .buyStream(e.streamId ?? '');
                                    if (res) {
                                      await controller.initializeAndJoinStream(
                                        e,
                                        isCreatedByMe,
                                        context: context,
                                      );
                                    }
                                  });
                            } else {
                              controller.initializeAndJoinStream(
                                e,
                                isCreatedByMe,
                                context: context,
                              );
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
