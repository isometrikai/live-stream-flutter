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

  /// Optional Flutter asset path for the filter picker thumbnail.
  ///
  /// Example: `assets/effects/thumbs/aviators.jpg`
  ///
  /// Declared in the host app `pubspec.yaml`. When null, the picker shows
  /// the effect name initial instead.
  final String? thumbnailAssetPath;

  /// Built-in "no filter" option.
  static const none = IsmLiveDeepArEffect(
    id: 'none',
    name: 'None',
  );

  bool get isNone => assetPath == null || assetPath == 'None';
}
