import 'package:appscrip_live_stream_component/src/deepar/deepar_effect.dart';
import 'package:flutter/foundation.dart';

/// Optional DeepAR face-filter integration.
///
/// Off by default. When [enabled] is `true` and a platform license key is set,
/// hosts / co-publishers / PK guests publish DeepAR-processed frames instead of
/// the default LiveKit camera track. Viewers are unchanged.
///
/// Place `.deepar` files under the host app's Android
/// `android/app/src/main/assets/` (and iOS Runner bundle) using the same
/// relative [IsmLiveDeepArEffect.assetPath].
@immutable
class IsmLiveDeepArConfig {
  const IsmLiveDeepArConfig({
    this.enabled = false,
    this.androidLicenseKey,
    this.iosLicenseKey,
    this.effects = const [IsmLiveDeepArEffect.none],
    this.outputWidth = 540,
    this.outputHeight = 960,
    this.defaultEffectId,
  });

  /// Master switch. When `false`, existing LiveKit camera publish is untouched.
  final bool enabled;

  /// DeepAR Android license key (bound to the host `applicationId`).
  final String? androidLicenseKey;

  /// DeepAR iOS license key (bound to the host bundle id).
  final String? iosLicenseKey;

  /// Filters shown in the picker. Always include [IsmLiveDeepArEffect.none].
  final List<IsmLiveDeepArEffect> effects;

  /// Off-screen DeepAR output width (portrait: width &lt; height).
  final int outputWidth;

  /// Off-screen DeepAR output height.
  final int outputHeight;

  /// Optional effect id applied when capture starts. Defaults to first effect
  /// or [IsmLiveDeepArEffect.none].
  final String? defaultEffectId;

  /// Platform license for the current OS, or `null` if missing / unsupported.
  String? get licenseKeyForPlatform {
    if (kIsWeb) return null;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return androidLicenseKey;
      case TargetPlatform.iOS:
        return iosLicenseKey;
      default:
        return null;
    }
  }

  /// Ready to run DeepAR on this device (flag on + key present + mobile).
  bool get isActive {
    if (!enabled || kIsWeb) return false;
    final key = licenseKeyForPlatform;
    return key != null && key.isNotEmpty;
  }

  IsmLiveDeepArEffect resolveDefaultEffect() {
    if (defaultEffectId != null) {
      for (final e in effects) {
        if (e.id == defaultEffectId) return e;
      }
    }
    return effects.isNotEmpty ? effects.first : IsmLiveDeepArEffect.none;
  }

  IsmLiveDeepArConfig copyWith({
    bool? enabled,
    String? androidLicenseKey,
    String? iosLicenseKey,
    List<IsmLiveDeepArEffect>? effects,
    int? outputWidth,
    int? outputHeight,
    String? defaultEffectId,
  }) {
    return IsmLiveDeepArConfig(
      enabled: enabled ?? this.enabled,
      androidLicenseKey: androidLicenseKey ?? this.androidLicenseKey,
      iosLicenseKey: iosLicenseKey ?? this.iosLicenseKey,
      effects: effects ?? this.effects,
      outputWidth: outputWidth ?? this.outputWidth,
      outputHeight: outputHeight ?? this.outputHeight,
      defaultEffectId: defaultEffectId ?? this.defaultEffectId,
    );
  }
}
