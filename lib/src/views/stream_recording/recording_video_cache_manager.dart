import 'dart:async';

import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:video_player/video_player.dart';

/// Lightweight cache manager for recording playback.
///
/// - Maintains a single [VideoPlayerController] per URL.
/// - Reuses controllers across pages to avoid re‑initialization cost.
/// - Supports simple preloading and clearing controllers outside an active range.
class RecordingVideoCacheManager {
  RecordingVideoCacheManager._internal();

  static final RecordingVideoCacheManager instance =
      RecordingVideoCacheManager._internal();

  final Map<String, _CachedVideo> _cache = <String, _CachedVideo>{};

  /// Coalesces concurrent [getOrCreate] / preload calls for the same URL.
  ///
  /// Without this, a second caller could overwrite the cache while the first
  /// `initialize()` is still in flight, causing duplicate HTTP sessions. That
  /// often surfaces on iOS as HTTP 403 (CoreMedia OSStatus -12660) for
  /// long recordings or single-use / presigned URLs.
  final Map<String, Future<VideoPlayerController>> _inflight =
      <String, Future<VideoPlayerController>>{};

  /// Returns a cached controller if it exists and is still usable.
  VideoPlayerController? getCachedController(String url) {
    final entry = _cache[url];
    if (entry == null) return null;
    if (entry.disposed) {
      _cache.remove(url);
      return null;
    }
    entry.lastAccess = DateTime.now();
    return entry.controller;
  }

  /// Ensure a controller exists for [url] and is initialized.
  ///
  /// If the controller is already cached and initialized, it is reused.
  /// Otherwise a new controller is created, initialized and cached.
  Future<VideoPlayerController> getOrCreate(String url) async {
    if (url.isEmpty) {
      throw ArgumentError.value(url, 'url', 'Video URL must not be empty');
    }

    final existing = _cache[url];
    if (existing != null && !existing.disposed) {
      if (existing.controller.value.isInitialized) {
        existing.lastAccess = DateTime.now();
        return existing.controller;
      }
    }

    var tracked = _inflight[url];
    if (tracked == null) {
      tracked = _createAndInitialize(url);
      _inflight[url] = tracked;
    }
    try {
      return await tracked;
    } finally {
      final current = _inflight[url];
      if (identical(current, tracked)) {
        final removed = _inflight.remove(url);
        if (removed != null) await removed;
      }
    }
  }

  Future<VideoPlayerController> _createAndInitialize(String url) async {
    final stale = _cache.remove(url);
    if (stale != null && !stale.disposed) {
      stale.disposed = true;
      await stale.controller.dispose();
    }

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    final entry = _CachedVideo(controller: controller);
    _cache[url] = entry;
    try {
      await controller.initialize();
      entry.lastAccess = DateTime.now();
      return controller;
    } catch (_) {
      await controller.dispose();
      _cache.remove(url);
      rethrow;
    }
  }

  /// Preload a list of video URLs in the background.
  ///
  /// Errors are swallowed; callers can still attempt playback on demand.
  Future<void> precacheMedia(List<String> urls) async {
    if (urls.isEmpty) return;

    Future<void> runOne(String url) async {
      if (_cache[url]?.disposed == true) {
        _cache.remove(url);
      }
      if (_cache[url]?.controller.value.isInitialized == true) {
        return;
      }
      await _preload(url);
    }

    // iOS + long assets: parallel AVPlayer HTTP sessions can trigger CDN/WAF
    // 403 (CoreMedia -12660). Preload neighbors one at a time on iOS only.
    final serialPrecache =
        !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
    if (serialPrecache) {
      for (final url in urls) {
        if (url.isEmpty) continue;
        await runOne(url);
      }
      return;
    }

    final futures = <Future<void>>[];
    for (final url in urls) {
      if (url.isEmpty) continue;
      futures.add(runOne(url));
    }
    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  Future<void> _preload(String url) async {
    try {
      await getOrCreate(url);
    } catch (_) {
      // Ignore preload failures; playback can retry on demand.
    }
  }

  /// Mark a URL as currently visible in the viewport.
  void markVisible(String url) {
    final entry = _cache[url];
    if (entry == null || entry.disposed) return;
    entry.isVisible = true;
    entry.lastAccess = DateTime.now();
  }

  /// Mark a URL as not visible.
  void markNotVisible(String url) {
    final entry = _cache[url];
    if (entry == null || entry.disposed) return;
    entry.isVisible = false;
    entry.lastAccess = DateTime.now();
  }

  /// Clear and dispose controllers for all URLs not in [activeUrls].
  ///
  /// This should be called from the feed when the visible window changes.
  Future<void> clearOutsideRange(List<String> activeUrls) async {
    final activeSet = activeUrls.toSet();
    final futures = <Future<void>>[];
    final keysToRemove = <String>[];

    _cache.forEach((url, entry) {
      if (activeSet.contains(url)) return;
      if (entry.disposed) {
        keysToRemove.add(url);
        return;
      }
      entry.disposed = true;
      futures.add(entry.controller.dispose());
      keysToRemove.add(url);
    });

    if (keysToRemove.isNotEmpty) {
      for (final key in keysToRemove) {
        _cache.remove(key);
      }
    }

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
  }

  /// Dispose and evict a single URL from the cache.
  Future<void> clear(String url) async {
    final entry = _cache.remove(url);
    if (entry == null || entry.disposed) return;
    entry.disposed = true;
    await entry.controller.dispose();
  }

  /// Dispose all controllers and clear the cache.
  Future<void> clearAll() async {
    final futures =
        _cache.values.where((e) => !e.disposed).map((e) async {
      e.disposed = true;
      await e.controller.dispose();
    }).toList();

    if (futures.isNotEmpty) {
      await Future.wait(futures);
    }
    _cache.clear();
  }
}

class _CachedVideo {
  _CachedVideo({
    required this.controller,
  })  : isVisible = false,
        disposed = false,
        lastAccess = DateTime.now();

  final VideoPlayerController controller;
  bool isVisible;
  bool disposed;
  DateTime lastAccess;
}

