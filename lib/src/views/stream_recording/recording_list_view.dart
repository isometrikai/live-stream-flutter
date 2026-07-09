import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/res/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// Full-screen recording list with grid. Fetches from recordings API.
class IsmLiveRecordingListView extends StatefulWidget {
  const IsmLiveRecordingListView({super.key, this.showBackArrow = true});

  static const String updateId = 'ismlive-recording-list-view';

  static const String route = IsmLiveRoutes.recordingList;

  final bool showBackArrow;

  @override
  State<IsmLiveRecordingListView> createState() =>
      _IsmLiveRecordingListViewState();
}

class _IsmLiveRecordingListViewState extends State<IsmLiveRecordingListView> {
  late final RefreshController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = RefreshController();
    _fetchRecordings();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _fetchRecordings() async {
    final controller = Get.find<IsmLiveStreamController>();
    await controller.fetchRecordings();
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = context.liveTheme?.backgroundColor ??
        (isDarkMode ? const Color(0xFF121212) : Colors.white);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: IsmLiveAppbar(
        showBackArrow: widget.showBackArrow,
        title: IsmLiveStrings.recordings,
      ),
      body: GetBuilder<IsmLiveStreamController>(
          id: IsmLiveRecordingListView.updateId,
          builder: (controller) => SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            onRefresh: _fetchRecordings,
            child: controller.recordingsList.isEmpty
                ? IsmLiveEmptyScreen(
                    label: IsmLiveStrings.noRecordings,
                    placeHolder: IsmLiveAssetConstants.noStreamsPlaceholder,
                  )
                : Padding(
                    padding: IsmLiveDimens.edgeInsets16,
                    child: StaggeredGrid.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: IsmLiveDimens.eight,
                      mainAxisSpacing: IsmLiveDimens.eight,
                      children: controller.recordingsList
                          .asMap()
                          .entries
                          .map((entry) {
                        final index = entry.key;
                        final e = entry.value;
                        return IsmLiveTapHandler(
                          onTap: () {
                            final items = controller.recordingsList
                                .map(IsmLiveStreamDataModelRecordingAdapter.new)
                                .toList();
                            if (items.isEmpty) return;
                            final adapter =
                                IsmLiveStreamDataModelRecordingAdapter(e);
                            if (adapter.recordedUrls.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'No playable recording URL for this stream',
                                  ),
                                ),
                              );
                              return;
                            }
                            final config =
                                IsmLiveDelegate.streamRecordingPlayerConfig ??
                                    IsmLiveDelegate
                                        .defaultStreamRecordingPlayerConfig;
                            IsmLiveRouteManagement.goToStreamRecordingPlayer(
                              recordings: items,
                              initialIndex: index.clamp(0, items.length - 1),
                              config: config,
                            );
                          },
                          child: IsmLiveStreamCard(e, isCreatedByMe: false),
                        );
                      }).toList(),
                    ),
                  ),
        ),
      ),
    );
  }
}
