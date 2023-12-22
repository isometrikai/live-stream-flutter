import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class IsmLiveStreamListing extends StatefulWidget {
  const IsmLiveStreamListing({
    super.key,
  });

  static const String updateId = 'ismlive-stream-view';

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
      Get.find<IsmLiveMqttController>().setup(context);
      Get.find<IsmLiveStreamController>().configuration = IsmLiveConfig.of(context);
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: const IsmLiveHeader(),
        floatingActionButton: const IsmLiveCreateStreamFAB(),
        body: GetBuilder<IsmLiveStreamController>(
          builder: (controller) => Column(
            children: [
              TabBar(
                isScrollable: true,
                dividerHeight: 0,
                indicatorColor: Colors.transparent,
                overlayColor: MaterialStateProperty.all(Colors.transparent),
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
                        key: ValueKey('ismlive-stream-view-${e.value}'),
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
              ? const Center(
                  child: Text('No Streams'),
                )
              : StaggeredGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: IsmLiveDimens.sixteen,
                  crossAxisSpacing: IsmLiveDimens.sixteen,
                  children: controller.streams.map(
                    (e) {
                      var isCreatedByMe = e.createdBy == controller.user?.userId;
                      return IsmLiveTapHandler(
                        onTap: () {
                          controller.joinStream(e);
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
      );
}
