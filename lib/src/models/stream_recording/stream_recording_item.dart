/// Abstract contract for a single stream recording item.
///
/// The host app provides objects that implement this interface (or an adapter).
/// The SDK does not depend on host-specific model types (e.g. MissedStream).
abstract class IsmLiveStreamRecordingItem {
  /// Unique stream/recording identifier.
  String get streamId;

  /// URLs for the recorded video. Playback typically uses the first URL.
  List<String> get recordedUrls;

  /// Display view count for this recording.
  int get recordViewCount;

  /// Store identifier; used for "my stream" and product ownership.
  String? get storeId;

  /// Streamer user identifier; used for profile and follow.
  String? get userId;

  /// Streamer display name.
  String? get userName;

  /// Streamer profile image URL.
  String? get userImageUrl;
}
