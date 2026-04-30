/// Stream identifier checks shared across views (headers, overlays, inputs).
class IsmLiveStreamId {
  const IsmLiveStreamId._();

  /// Returns true when [streamId] is non-empty and not the placeholder prefix
  /// (`00000`), which indicates a real stream id is not available yet.
  static bool isValid(String? streamId) {
    if (streamId == null || streamId.isEmpty) {
      return false;
    }
    if (streamId.startsWith('00000')) {
      return false;
    }
    return true;
  }
}
