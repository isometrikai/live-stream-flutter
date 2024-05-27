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
  Widget build(BuildContext context) => Scaffold(
        appBar: const IsmLiveAppbar(),
        floatingActionButton: const IsmLiveCreateStreamFAB(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: GetBuilder<IsmLiveStreamController>(
          builder: (controller) => Column(
            children: [
              TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                dividerHeight: 0,
                indicatorColor: Colors.transparent,
                labelPadding: IsmLiveDimens.edgeInsets8_0,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                controller: controller.tabController,
                onTap: (index) {
                  controller.streamType = IsmLiveStreamType.values[index];
                },
                tabs: [
                  ...IsmLiveStreamType.values.map(
                    IsmLiveTabButton.new,
                  ),
                ],
              ),
              Expanded(
                child: TabBarView(
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
          onRefresh: () => controller.getStreams(controller.streamType),
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
                        var isCreatedByMe =
                            e.createdBy == controller.user?.userId;
                        return IsmLiveTapHandler(
                          onTap: () => controller.initializeAndJoinStream(
                              e, isCreatedByMe),
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
