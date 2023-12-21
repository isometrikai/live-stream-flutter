import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class IsmLiveStreamView extends StatefulWidget {
  const IsmLiveStreamView({
    super.key,
  });

  static const String updateId = 'ismlive-stream-view';

  @override
  State<IsmLiveStreamView> createState() => _IsmLiveStreamViewState();
}

class _IsmLiveStreamViewState extends State<IsmLiveStreamView> {
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
                      (e) => _StreamView(
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

class _StreamView extends StatelessWidget {
  const _StreamView({
    super.key,
  });

  @override
  Widget build(BuildContext context) => GetBuilder<IsmLiveStreamController>(
        id: IsmLiveStreamView.updateId,
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
                  children: [
                    ...controller.streams.map(
                      (e) => Text(
                        e.streamId ?? '',
                      ),
                    ),
                  ],
                ),
        ),
      );
}
