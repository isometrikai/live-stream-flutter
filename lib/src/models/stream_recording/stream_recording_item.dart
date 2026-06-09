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

  /// Poster or thumbnail URL for this recording (e.g. preview before playback).
  String? get thumbnailUrl;
}

/// Optional capability for chat replay sync on a recording item.
///
/// Host apps that `implement` [IsmLiveStreamRecordingItem] are not required to
/// adopt this interface. Chat replay can use config `resolveStreamStartTime`
/// or the first message timestamp when start time is unavailable.
abstract class IsmLiveStreamRecordingReplayCapable {
  /// When the live stream started. Used to align comments with video position.
  DateTime? get streamStartTime;
}
