import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:get/get.dart';

/// A service class that uses the stream API functionality from the package
class StreamService {
  factory StreamService() => instance;
  const StreamService._();
  static const StreamService instance = StreamService._();

  IsmLiveStreamController get _controller => Get.find<IsmLiveStreamController>();
  IsmLiveMqttController get _mqttController => Get.find<IsmLiveMqttController>();

  /// Initialize the service and set up MQTT event listeners
  void initialize() {
    // Listen to MQTT events
    _mqttController.actionStreamController.stream.listen((event) {
      if (event.payload['action'] == IsmLiveActions.streamStartPresence.name) {
        refreshStreams();
      }
    });
  }

  /// Refresh streams based on current type
  Future<void> refreshStreams() async {
    await getStreams(
      type: _controller.streamType,
      skip: 0,
    );
  }

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
  Future<List<IsmLiveStreamDataModel>> _getScheduledStreams({int skip = 0}) async => _controller.viewModel.getStreams(
      queryModel: IsmLiveStreamType.scheduledStreams.queryModel(skip: skip),
    );

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

  /// Start a new live stream with the specified parameters
  /// 
  /// [streamTitle] - The title of the stream
  /// [streamDescription] - Description of the stream
  /// [streamImage] - Optional image for the stream thumbnail
  /// [isPaid] - Whether this is a paid stream
  /// [amount] - Amount for paid streams
  /// [isPublicStream] - Whether the stream is public
  /// [hdBroadcast] - Whether to broadcast in HD
  /// [rtmpIngest] - Whether to use RTMP ingest
  /// [restream] - Whether to restream
  /// [audioOnly] - Whether this is an audio-only stream
  /// [enableRecording] - Whether to enable recording
  /// [isScheduledStream] - Whether this is a scheduled stream
  /// [scheduledStartTime] - Start time for scheduled streams
  /// [members] - List of member IDs who can join the stream
  /// [products] - List of products to be shown in the stream
  /// [productsLinked] - Whether products are linked to the stream
  /// [eventId] - Event ID for scheduled streams
  /// [paymentCurrencyCode] - Currency code for paid streams
  /// [saleType] - Type of sale for paid streams
  /// 
  /// Returns the created stream data model if successful, null otherwise
  Future<IsmLiveStreamDataModel?> startLiveStream({
    required String streamTitle,
    required String streamDescription,
    String? streamImage,
    bool isPaid = false,
    double? amount,
    bool isPublicStream = true,
    bool hdBroadcast = false,
    bool rtmpIngest = false,
    bool restream = false,
    bool audioOnly = false,
    bool enableRecording = false,
    bool isScheduledStream = false,
    DateTime? scheduledStartTime,
    List<String>? members,
    required List products,
    bool productsLinked = false,
    String? eventId,
    String? paymentCurrencyCode,
  }) async {
    try {
      // Set up stream details
      _controller.streamDetails = IsmLiveStreamDataModel(
        streamTitle: streamTitle,
        streamDescription: streamDescription,
        streamImage: streamImage,
        isPaid: isPaid,
        amount: amount,
        isPublicStream: isPublicStream,
        hdBroadcast: hdBroadcast,
        rtmpIngest: rtmpIngest,
        restream: restream,
        audioOnly: audioOnly,
        isRecorded: enableRecording,
        isScheduledStream: isScheduledStream,
        startDateTime: scheduledStartTime,
        members: members,
        products: products,
        productsLinked: productsLinked,
        eventId: eventId,
        paymentCurrencyCode: paymentCurrencyCode,
      );

      // Set description in controller
      _controller.descriptionController.text = streamDescription;

      // Create stream directly with the image URL
      var data = await _controller.createStream(streamImage: streamImage);
      if (data == null || data.model == null) {
        return null;
      }

      // Connect to the created stream
      await _controller.connectStream(
        token: data.model!.rtcToken,
        streamId: data.model!.streamId!,
        streamImage: data.image,
        isHost: true,
        isNewStream: true,
        hdBroadcast: hdBroadcast,
        restream: restream,
      );

      return _controller.streamDetails;
    } catch (e) {
      IsmLiveLog.error('Error starting live stream: $e');
      return null;
    }
  }
} 