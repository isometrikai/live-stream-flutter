import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:get/get.dart';

/// A service class that uses the stream API functionality from the package
class StreamService {
  factory StreamService() => instance;
  const StreamService._();
  static const StreamService instance = StreamService._();

  IsmLiveStreamController get _controller => Get.find<IsmLiveStreamController>();

  /// Get streams based on the specified type
  Future<List<IsmLiveStreamDataModel>> getStreams({
    IsmLiveStreamType? type,
    int skip = 0,
  }) async {
    var streamType = type ?? _controller.streamType;
    
    if (streamType == IsmLiveStreamType.scheduledStreams) {
      return _getScheduledStreams(skip: skip);
    }

    return _controller.viewModel.getStreams(
      queryModel: streamType.queryModel(skip: skip),
    );
  }

  /// Get scheduled streams
  Future<List<IsmLiveStreamDataModel>> _getScheduledStreams({int skip = 0}) async {
    return _controller.viewModel.getStreams(
      queryModel: IsmLiveStreamType.scheduledStreams.queryModel(skip: skip),
    );
  }

  /// Join a stream
  Future<void> joinStream(IsmLiveStreamDataModel stream, bool isCreatedByMe) async {
    if ((stream.isPaid ?? false) && !(stream.isBuy ?? false)) {
      // Handle paid stream
      final res = await _controller.buyStream(stream.streamId ?? '');
      if (res) {
        await _controller.initializeAndJoinStream(stream, isCreatedByMe);
      }
    } else {
      await _controller.initializeAndJoinStream(stream, isCreatedByMe);
    }
  }

  /// Get current user ID
  String? get currentUserId => _controller.user?.userId;
} 