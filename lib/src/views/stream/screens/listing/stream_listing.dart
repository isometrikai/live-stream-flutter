import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/res/navigation/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class IsmLiveStreamListing extends StatefulWidget {
  const IsmLiveStreamListing({super.key, this.showBackArrow = false});

  static const String updateId = 'ismlive-stream-view';

  static const String route = IsmLiveRoutes.streamListing;

  static final List<VoidCallback> _pendingRefreshListeners = [];

  /// Wakes mounted SDK listing screens to consume
  /// [IsmLiveStreamController.scheduledStreamsListingRefreshPending].
  static void notifyPendingRefresh() {
    for (final listener in List<VoidCallback>.from(_pendingRefreshListeners)) {
      listener();
    }
  }

  static void _registerPendingRefreshListener(VoidCallback listener) {
    if (!_pendingRefreshListeners.contains(listener)) {
      _pendingRefreshListeners.add(listener);
    }
  }

  static void _unregisterPendingRefreshListener(VoidCallback listener) {
    _pendingRefreshListeners.remove(listener);
  }

  final bool showBackArrow;

  @override
  State<IsmLiveStreamListing> createState() => _IsmLiveStreamListingState();
}

class _IsmLiveStreamListingState extends State<IsmLiveStreamListing> {
  late final VoidCallback _pendingRefreshListener;
  bool _isPendingRefreshInFlight = false;

  /// Timestamp of the last system back press while on the root listing screen.
  /// Used to implement the standard Android "tap again to exit" behaviour.
  DateTime? _lastBackPressTime;

  /// Handles the Android system back button when the listing is the root
  /// route (nothing left to pop). First press shows a toast, a second press
  /// within [_exitInterval] closes the app.
  static const Duration _exitInterval = Duration(seconds: 2);

  void _handleRootBackPress() {
    final now = DateTime.now();
    final canExit = _lastBackPressTime != null &&
        now.difference(_lastBackPressTime!) <= _exitInterval;

    if (canExit) {
      SystemNavigator.pop();
      return;
    }

    _lastBackPressTime = now;
    Fluttertoast.showToast(
      msg: IsmLiveStrings.tapAgainToExit,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }
  // static const List<String> _debugRecordingUrls = [
  //   'https://streamrecordings.isometrik.ai/670f56a22ad940512be88f33/e07899be-0771-4cbf-9514-18fc4d2197cf/6a2a6259a1db8f0001c10530.mp4',
  //   'https://streamrecordings.isometrik.ai/670f56a22ad940512be88f33/e07899be-0771-4cbf-9514-18fc4d2197cf/6a293963a1db8f0001478812.mp4',
  //   'https://streamrecordings.isometrik.ai/670f56a22ad940512be88f33/e07899be-0771-4cbf-9514-18fc4d2197cf/6a2915eaa1db8f0001cc93dc.mp4',
  //   'https://streamrecordings.isometrik.ai/670f56a22ad940512be88f33/e07899be-0771-4cbf-9514-18fc4d2197cf/6a2a5280a1db8f0001056115.mp4',
  //   'https://streamrecordings.isometrik.ai/670f56a22ad940512be88f33/18dee27d-eed2-4909-a682-c69a124d6d0f/69fd008c53541c000183f046.mp4',
  //   'https://streamrecordings.isometrik.ai/670f56a22ad940512be88f33/18dee27d-eed2-4909-a682-c69a124d6d0f/69fb81ac53541c0001b37242.mp4',
  //   'https://streamrecordings.isometrik.ai/670f56a22ad940512be88f33/e07899be-0771-4cbf-9514-18fc4d2197cf/69f2b15b86a376000162a58b.mp4',
  //   'https://streamrecordings.isometrik.ai/670f56a22ad940512be88f33/e07899be-0771-4cbf-9514-18fc4d2197cf/69de348126f22b0001fc6e65.mp4',
  //   'https://streamrecordings.isometrik.ai/670f56a22ad940512be88f33/e07899be-0771-4cbf-9514-18fc4d2197cf/69c1ffc2477a660001ce6385.mp4',
  //   'https://streamrecordings.isometrik.ai/670f56a22ad940512be88f33/e07899be-0771-4cbf-9514-18fc4d2197cf/69c1ff7e477a660001d08b55.mp4',
  //   'https://streamrecordings.isometrik.ai/670f56a22ad940512be88f33/e07899be-0771-4cbf-9514-18fc4d2197cf/69c1ff38477a660001df09b9.mp4',
  //   'https://streamrecordings.isometrik.ai/670f56a22ad940512be88f33/e07899be-0771-4cbf-9514-18fc4d2197cf/69c1fec4477a6600013718db.mp4',
  //   'https://streamrecordings.isometrik.ai/670f56a22ad940512be88f33/e07899be-0771-4cbf-9514-18fc4d2197cf/69c1fe4d477a660001a2b833.mp4',
  //   'https://streamrecordings.isometrik.ai/670f56a22ad940512be88f33/e07899be-0771-4cbf-9514-18fc4d2197cf/69c1fd46477a660001cf386e.mp4',
  // ];

  /// Test-only poster images. Rotated across [_debugRecordingUrls] so the
  /// loading UI in the recording player has something to show while the
  /// underlying MP4 is buffering.
  // static const List<String> _debugThumbnailUrls = [
  //   'https://storage.googleapis.com/trulyfree-production/FileData/0/0/1777042551236.jpg',
  //   'https://storage.googleapis.com/trulyfree-production/FileData/0/0/1778007380993.jpg',
  //   'https://storage.googleapis.com/trulyfree-production/FileData/0/0/1778268686454.jpg',
  //   'https://storage.googleapis.com/trulyfree-production/FileData/0/0/1777042464583.jpg',
  // ];

  // List<IsmLiveStreamRecordingItem> get _debugRecordings => _debugRecordingUrls
  //     .asMap()
  //     .entries
  //     .map(
  //       (entry) => _DebugRecordingItem(
  //         streamId: 'debug-recording-${entry.key + 1}',
  //         recordedUrls: [entry.value],
  //         recordViewCount: 0,
  //         userName: 'Test User',
  //         userId: 'debug-user',
  //         userImageUrl: null,
  //         storeId: null,
  //         thumbnailUrl:
  //             _debugThumbnailUrls[entry.key % _debugThumbnailUrls.length],
  //       ),
  //     )
  //     .toList();

  @override
  void initState() {
    super.initState();

    if (!Get.isRegistered<IsmLiveMqttController>()) {
      IsmLiveMqttBinding().dependencies();
    }
    if (!Get.isRegistered<IsmLiveStreamController>()) {
      IsmLiveStreamBinding().dependencies();
    }

    _pendingRefreshListener = () {
      unawaited(_refreshAndRebuildIfPendingWithRetry());
    };
    IsmLiveStreamListing._registerPendingRefreshListener(
      _pendingRefreshListener,
    );
  }

  @override
  void dispose() {
    IsmLiveStreamListing._unregisterPendingRefreshListener(
      _pendingRefreshListener,
    );
    super.dispose();
  }

  Future<void> _refreshAndRebuildIfPendingWithRetry() async {
    for (var attempt = 0; attempt < 8; attempt++) {
      if (!mounted) {
        return;
      }
      if (ModalRoute.of(context)?.isCurrent == true) {
        await _refreshAndRebuildIfPending();
        return;
      }
      await Future<void>.delayed(const Duration(milliseconds: 80));
    }
  }

  Future<void> _refreshAndRebuildIfPending() async {
    if (_isPendingRefreshInFlight || !mounted) {
      return;
    }
    if (ModalRoute.of(context)?.isCurrent != true) {
      return;
    }
    if (!Get.isRegistered<IsmLiveStreamController>()) {
      return;
    }

    final controller = Get.find<IsmLiveStreamController>();
    if (!controller.scheduledStreamsListingRefreshPending) {
      return;
    }

    _isPendingRefreshInFlight = true;
    try {
      await controller.refreshScheduledStreamsListingIfNeeded();
      if (mounted) {
        setState(() {});
      }
    } finally {
      _isPendingRefreshInFlight = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (ModalRoute.of(context)?.isCurrent ?? false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        unawaited(_refreshAndRebuildIfPending());
      });
    }

    if (IsmLiveDelegate.homeScreen != null) {
      return IsmLiveDelegate.homeScreen!;
    }

    // When the listing is pushed on top of another route (e.g. a host app
    // navigates to it), [canPop] is true so the system back button performs a
    // normal pop. When it is the root route, [canPop] is false and the
    // standard "tap again to exit" flow runs via [_handleRootBackPress].
    final canPopRoute = ModalRoute.of(context)?.canPop ?? false;

    return PopScope(
      canPop: canPopRoute,
      onPopInvoked: (didPop) {
        if (didPop) return;
        _handleRootBackPress();
      },
      child: Scaffold(
        appBar: IsmLiveAppbar(showBackArrow: widget.showBackArrow),
        floatingActionButton: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const IsmLiveCreateStream(),
            IsmLiveDimens.boxWidth10,
            const IsmLiveStreamingScrolling(),
            // IsmLiveDimens.boxWidth10,
            // IsmLiveTapHandler(
            //   onTap: () {
            //     final items = _debugRecordings;
            //     if (items.isEmpty) return;
            //     IsmLiveRouteManagement.goToStreamRecordingPlayer(
            //       recordings: items,
            //       initialIndex: 0,
            //       config: IsmLiveDelegate.streamRecordingPlayerConfig,
            //     );
            //   },
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
                indicator: const BoxDecoration(), // hide the indicator
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
      ),
    );
  }
}

class _DebugRecordingItem implements IsmLiveStreamRecordingItem {
  const _DebugRecordingItem({
    required this.streamId,
    required this.recordedUrls,
    required this.recordViewCount,
    required this.storeId,
    required this.userId,
    required this.userName,
    required this.userImageUrl,
    this.thumbnailUrl,
  });

  @override
  final String streamId;

  @override
  final List<String> recordedUrls;

  @override
  final int recordViewCount;

  @override
  final String? storeId;

  @override
  final String? userId;

  @override
  final String? userName;

  @override
  final String? userImageUrl;

  @override
  final String? thumbnailUrl;
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

  void _openRecordedStreamPlayer(
    BuildContext context,
    IsmLiveStreamController controller,
    IsmLiveStreamDataModel streamModel,
  ) {
    final list = controller.streamsMap[widget.streamType]!;
    final items =
        list.map(IsmLiveStreamDataModelRecordingAdapter.new).toList();
    if (items.isEmpty) return;
    final index =
        list.indexWhere((s) => s.streamId == streamModel.streamId);
    final adapter = IsmLiveStreamDataModelRecordingAdapter(streamModel);
    if (adapter.recordedUrls.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No playable recording URL for this stream'),
        ),
      );
      return;
    }
    final config = IsmLiveDelegate.streamRecordingPlayerConfig ??
        IsmLiveDelegate.defaultStreamRecordingPlayerConfig;
    IsmLiveRouteManagement.goToStreamRecordingPlayer(
      recordings: items,
      initialIndex: (index >= 0 ? index : 0).clamp(0, items.length - 1),
      config: config,
    );
  }

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
                              unawaited(
                                IsmLiveUtility.precacheStreamCover(
                                  e.streamImage,
                                  context,
                                ),
                              );
                              controller.startSeduleStream(e);
                              return;
                            }

                            if (widget.streamType ==
                                IsmLiveStreamType.recorded) {
                              if ((e.isPaid ?? false) && !(e.isBuy ?? false)) {
                                controller.paidStreamSheet(
                                  coins: e.amount ?? 0,
                                  onTap: () async {
                                    IsmLiveRoute.pop();
                                    var res = await controller
                                        .buyStream(e.streamId ?? '');
                                    if (res) {
                                      _openRecordedStreamPlayer(
                                        context,
                                        controller,
                                        e,
                                      );
                                    }
                                  },
                                );
                              } else {
                                _openRecordedStreamPlayer(
                                  context,
                                  controller,
                                  e,
                                );
                              }
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
                            showOwnerBadge: widget.streamType !=
                                IsmLiveStreamType.recorded,
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ),
        ),
      );
}
