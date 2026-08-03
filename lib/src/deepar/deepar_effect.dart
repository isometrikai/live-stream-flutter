/// A selectable DeepAR filter / effect.
class IsmLiveDeepArEffect {
  const IsmLiveDeepArEffect({
    required this.id,
    required this.name,
    this.assetPath,
    this.thumbnailAssetPath,
  });

  /// Stable id used for selection / analytics.
  final String id;

  /// Label shown in the filter picker.
  final String name;

  /// Path relative to the host app's Flutter / Android `assets` root.
  ///
  /// Example: `effects/aviators.deepar`
  ///
  /// Pass `null` for "no effect" (clear filter).
  ///
  /// Android (`flutter_deepar`) loads via `file:///android_asset/<assetPath>`,
  /// so also place the file under `android/app/src/main/assets/`.
  final String? assetPath;

  /// Optional local asset for the picker thumbnail.
  final String? thumbnailAssetPath;

  /// Built-in "no filter" option.
  static const none = IsmLiveDeepArEffect(
    id: 'none',
    name: 'None',
  );

  bool get isNone => assetPath == null || assetPath == 'None';
}
