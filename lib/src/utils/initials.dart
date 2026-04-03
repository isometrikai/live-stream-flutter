/// Utility for extracting uppercase initials from display names.
///
/// Designed to be dependency-free so it can be safely imported by any
/// model, widget, or utility class without risk of circular imports.
class IsmLiveInitials {
  IsmLiveInitials._();

  static final _whitespace = RegExp(r'\s+');

  /// Extracts up to two uppercase initials from [name].
  ///
  /// Splits on whitespace and takes the first character of the first
  /// and last parts (e.g. "John Doe" → "JD", "Alice" → "A").
  /// Returns `null` when [name] is null or blank.
  static String? extract(String? name) {
    final trimmed = name?.trim() ?? '';
    if (trimmed.isEmpty) return null;
    final parts =
        trimmed.split(_whitespace).where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  /// Tries [primary] first, then [secondary], returning [fallback] if both
  /// are null or blank. Useful when a model has a rich name (e.g. fullName
  /// from metadata) and a simpler fallback (e.g. userName).
  static String fromNames({
    String? primary,
    String? secondary,
    String fallback = 'U',
  }) =>
      extract(primary) ?? extract(secondary) ?? fallback;
}
