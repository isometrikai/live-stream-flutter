part of '../stream_controller.dart';

/// Ensures audio routes to the loudspeaker when no external audio device
/// (Bluetooth, wired headset) is connected. Safe to call repeatedly.
///
/// On iOS [setSpeakerphoneOn] already respects connected accessories
/// (Bluetooth / wired headsets take priority by default).
/// On Android [setSpeakerphoneOn(true)] forces the built-in speaker and
/// overrides any connected device, so we guard the call behind a device check.
///
/// When [withRetry] is true (default for the initial connection), delayed
/// re-applies are scheduled. This guards against the common race where
/// WebRTC's remote-track subscription reconfigures the audio session and
/// resets the output back to the earpiece (Android) or where the
/// AVAudioSession hasn't fully activated yet (iOS).
///
/// [forRoom] pins retries to a specific LiveKit room instance. If the
/// controller's room changes before a retry fires (e.g. the user left and
/// re-joined), the stale retry is skipped so it cannot interfere with the
/// new room's audio session.
Future<void> _ensureLoudspeakerRouting({
  bool withRetry = false,
  lk.Room? forRoom,
}) async {
  try {
    await _applySpeakerRoute();
  } catch (e) {
    IsmLiveLog('_ensureLoudspeakerRouting error: $e');
  }

  if (withRetry) {
    final roomAtCallTime = forRoom;

    bool isRoomStillActive() {
      if (roomAtCallTime == null) return true;
      try {
        if (!Get.isRegistered<IsmLiveStreamController>()) return false;
        return Get.find<IsmLiveStreamController>().room == roomAtCallTime;
      } catch (_) {
        return false;
      }
    }

    unawaited(Future<void>.delayed(
      const Duration(milliseconds: 800),
      () async {
        if (!isRoomStillActive()) return;
        try {
          await _applySpeakerRoute();
        } catch (e) {
          IsmLiveLog('_ensureLoudspeakerRouting retry error: $e');
        }
      },
    ));
    // Some devices (notably certain Xiaomi/Redmi builds and some iOS versions)
    // can re-route audio *again* after the first remote track starts rendering.
    // A second delayed re-apply reduces intermittent "earpiece instead of speaker"
    // reports without changing steady-state behavior.
    unawaited(Future<void>.delayed(
      const Duration(milliseconds: 1600),
      () async {
        if (!isRoomStillActive()) return;
        try {
          await _applySpeakerRoute();
        } catch (e) {
          IsmLiveLog('_ensureLoudspeakerRouting 2nd retry error: $e');
        }
      },
    ));
    // On iOS (especially older devices like iPhone 11), rapid
    // join-leave-join cycles can cause the AVAudioSession to finalise its
    // reconfiguration well after 1.6 s. A third, later retry catches this
    // without affecting steady-state behavior on faster devices.
    if (Platform.isIOS) {
      unawaited(Future<void>.delayed(
        const Duration(milliseconds: 3000),
        () async {
          if (!isRoomStillActive()) return;
          try {
            await _applySpeakerRoute();
          } catch (e) {
            IsmLiveLog('_ensureLoudspeakerRouting iOS late retry error: $e');
          }
        },
      ));
    }
  }
}

Future<void> _applySpeakerRoute() async {
  if (Platform.isIOS) {
    await lk.Hardware.instance.setSpeakerphoneOn(true);
    return;
  }

  if (Platform.isAndroid) {
    final hasExternal = await _hasExternalAudioOutputOnAndroid();
    if (!hasExternal) {
      await lk.Hardware.instance.setSpeakerphoneOn(true);
    }
    return;
  }

  await lk.Hardware.instance.setSpeakerphoneOn(true);
}

/// Returns `true` when an external audio output (Bluetooth, wired headset,
/// USB audio) is currently connected on Android.
///
/// Built-in outputs are identified by substring matching against known
/// built-in keywords. This handles OEM-specific labels (e.g. Xiaomi/Redmi
/// reporting "Built-In Speaker", localized names like "æ‰‹æœºå¬ç­’", etc.).
Future<bool> _hasExternalAudioOutputOnAndroid() async {
  try {
    final devices = await lk.Hardware.instance.enumerateDevices();
    final outputs = devices.where((d) => d.kind == 'audiooutput').toList();

    IsmLiveLog.info(
        '_hasExternalAudioOutputOnAndroid: ${outputs.length} outputs: '
        '${outputs.map((d) => '"${d.label}"').join(', ')}');

    // On Android, built-in outputs are typically "Earpiece" + "Speaker"
    // (at most 2 entries). Any additional entry indicates external hardware.
    if (outputs.length > 2) return true;

    // Substring-based matching so OEM-specific labels (e.g. "Built-In Speaker",
    // "phone speaker", localized names) are still recognized as built-in.
    const builtInKeywords = [
      'earpiece',
      'speaker',
      'speakerphone',
      'built-in',
      'builtin',
      'phone',
      'handset',
      'receiver',
    ];
    for (final device in outputs) {
      final label = device.label.toLowerCase().trim();
      if (label.isEmpty) continue;
      final isBuiltIn = builtInKeywords.any(label.contains);
      if (!isBuiltIn) {
        IsmLiveLog.info(
            '_hasExternalAudioOutputOnAndroid: detected external device: "$label"');
        return true;
      }
    }

    return false;
  } catch (e) {
    IsmLiveLog.info('_hasExternalAudioOutputOnAndroid error: $e');
    return false;
  }
}
