import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component_example/services/stream_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

/// A custom stream listing screen that uses the IsmLiveStreamListingService
/// from the appscrip_live_stream_component package
class CustomStreamListing extends StatefulWidget {
  const CustomStreamListing({super.key});

  @override
  State<CustomStreamListing> createState() => _CustomStreamListingState();
}

class _CustomStreamListingState extends State<CustomStreamListing> {
  final _streamService = StreamService();
  final _refreshController = RefreshController();
  final _streams = <IsmLiveStreamDataModel>[].obs;
  final _isLoading = false.obs;
  final _selectedStreamType = IsmLiveStreamType.all.obs;

  @override
  void initState() {
    super.initState();
    _loadStreams();
  }

  Future<void> _loadStreams({bool refresh = false}) async {
    if (_isLoading.value) return;
    _isLoading.value = true;

    try {
      final streams = await _streamService.getStreams(
        type: _selectedStreamType.value,
        skip: refresh ? 0 : _streams.length,
      );

      if (refresh) {
        _streams.clear();
      }
      _streams.addAll(streams);
    } finally {
      _isLoading.value = false;
      if (refresh) {
        _refreshController.refreshCompleted();
      } else {
        _refreshController.loadComplete();
      }
    }
  }

  @override
  Widget build(BuildContext context) => Column(
        children: [
          // Custom stream type selector
          Container(
            height: 50,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: IsmLiveStreamType.values.length,
              itemBuilder: (context, index) {
                final type = IsmLiveStreamType.values[index];
                return Obx(() {
                  final isSelected = _selectedStreamType.value == type;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(
                        type.name.toUpperCase(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          _selectedStreamType.value = type;
                          _loadStreams(refresh: true);
                        }
                      },
                      backgroundColor: Colors.grey[200],
                      selectedColor: Theme.of(context).primaryColor,
                    ),
                  );
                });
              },
            ),
          ),

          // Stream list
          Expanded(
            child: Obx(() {
              if (_isLoading.value && _streams.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (_streams.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.live_tv,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No streams available',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                );
              }

              return SmartRefresher(
                controller: _refreshController,
                enablePullDown: true,
                enablePullUp: true,
                onRefresh: () => _loadStreams(refresh: true),
                onLoading: _loadStreams,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _streams.length,
                  itemBuilder: (context, index) {
                    final stream = _streams[index];
                    final isCreatedByMe =
                        stream.userId == _streamService.currentUserId;

                    return _StreamListItem(
                      stream: stream,
                      isCreatedByMe: isCreatedByMe,
                      onTap: () => _streamService.joinStream(
                          stream, isCreatedByMe, context),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      );

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}

class _StreamListItem extends StatelessWidget {
  const _StreamListItem({
    required this.stream,
    required this.isCreatedByMe,
    required this.onTap,
  });

  final IsmLiveStreamDataModel stream;
  final bool isCreatedByMe;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 16),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stream thumbnail with overlay
              Stack(
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: stream.streamImage != null
                          ? Image.network(
                              stream.streamImage!,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.live_tv,
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),
                    ),
                  ),

                  // Live indicator
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.circle,
                            color: Colors.white,
                            size: 8,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Viewer count
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.remove_red_eye,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${stream.viewersCount ?? 0}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              // Stream info
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            stream.streamDescription ?? 'No description',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (stream.isPaid == true)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.lock,
                                  size: 16,
                                  color: Colors.orange[800],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'PAID',
                                  style: TextStyle(
                                    color: Colors.orange[800],
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundImage: stream.userDetails?.userProfile !=
                                  null
                              ? NetworkImage(stream.userDetails!.userProfile!)
                              : null,
                          child: stream.userDetails?.userProfile == null
                              ? const Icon(Icons.person, size: 16)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            stream.userDetails?.userName ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
