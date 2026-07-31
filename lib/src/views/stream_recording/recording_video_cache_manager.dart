import 'dart:async';

import 'package:appscrip_live_stream_component/src/res/constants/string_contants.dart';
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

  /// The URL currently being initialized for the visible page. Neighbor
  /// preloads yield until this completes so the active recording always gets
  /// the full bandwidth / decoder budget first.
  String? _highPriorityUrl;
  Completer<void>? _highPriorityCompleter;

  /// Serializes background (neighbor) preloads so we never open two low-
  /// priority HTTP sessions at once.
  Future<void> _backgroundPreloadChain = Future<void>.value();

  /// Bumped on every [abandonOutside] call so stale [_preload] work from a
  /// previous page does not block the chain for the new retention window.
  int _preloadGeneration = 0;

  /// URLs the feed currently wants to keep warm (active + neighbors). Updated
  /// on every page change so stale preload work can't resurrect controllers for
  /// pages the user has already scrolled past.
  Set<String> _retentionWindow = <String>{};

  /// Session-scoped record of URLs that already failed with a permanent
  /// (e.g. 4xx) error. Lets [IsmLiveRecordingAutoVideoPlayer] short-circuit
  /// the spinner and surface the retry CTA immediately on subsequent mounts
  /// of the same broken URL (scroll back / re-entry), instead of forcing the
  /// user to wait for a fresh HTTP round-trip to discover the same failure.
  final Map<String, String> _knownFailures = <String, String>{};

  /// Returns the cached failure message for [url] if we've already seen it
  /// fail with a permanent error this session, otherwise null.
  String? getKnownFailure(String url) => _knownFailures[url];

  /// Forgets any cached failure for [url]. Call from the retry path so the
  /// next [getOrCreate] takes a fresh swing at the network.
  void forgetKnownFailure(String url) {
    _knownFailures.remove(url);
  }

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
  ///
  /// Begin loading [url] as early as possible (e.g. on page change before the
  /// player widget mounts). Errors are swallowed - the widget retries on demand.
  Future<void> warmup(String url, {bool highPriority = true}) async {
    if (url.isEmpty) return;
    try {
      await getOrCreate(url, highPriority: highPriority);
    } on _RecordingInitAbortedException {
      // Bumped aside by a newer page change - expected during fast scroll.
    } catch (_) {
      // Widget path / retry will surface failures to the user.
    }
  }

  /// Pass [highPriority] for the visible page's player so neighbor preloads
  /// and stale in-flight work are bumped aside instead of blocking first-frame.
  Future<VideoPlayerController> getOrCreate(
    String url, {
    bool highPriority = false,
  }) async {
    if (url.isEmpty) {
      throw ArgumentError.value(url, 'url', 'Video URL must not be empty');
    }

    // Fast-fail for URLs proven broken this session. Stops neighbor preload
    // from re-burning HTTP sessions / decoder budget on a URL whose server
    // already told us "no". The widget path also short-circuits earlier via
    // [getKnownFailure], so this primarily protects the preload path.
    final knownFailure = _knownFailures[url];
    if (knownFailure != null) {
      throw _RecordingPlaybackException(knownFailure);
    }

    final existing = _cache[url];
    if (existing != null && !existing.disposed) {
      final value = existing.controller.value;
      // Never hand back a controller that already errored (e.g. 403 / source
      // error during a previous attempt). Drop it and fall through to fresh
      // init so the UI gets a usable controller instead of an endless spinner.
      if (value.hasError) {
        existing.disposed = true;
        unawaited(existing.controller.dispose());
        _cache.remove(url);
      } else if (value.isInitialized) {
        existing.lastAccess = DateTime.now();
        return existing.controller;
      }
    }

    if (highPriority) {
      // Fire-and-forget competitor teardown so first-frame init is not delayed
      // waiting for native decoder release on URLs outside the retention window.
      unawaited(_abortCompetingInits(keepUrl: url));
      return _runAsHighPriority(url, () => _getOrCreateTracked(url));
    }

    final highPriorityWaiter = _highPriorityCompleter;
    if (highPriorityWaiter != null) {
      await highPriorityWaiter.future;
    }
    return _getOrCreateTracked(url);
  }

  Future<VideoPlayerController> _getOrCreateTracked(String url) async {
    final existing = _inflight[url];
    if (existing != null) {
      return existing;
    }

    // Register before any await so concurrent callers coalesce instead of
    // each running [_createAndInitialize] and thrashing ExoPlayer.
    final completer = Completer<VideoPlayerController>();
    final tracked = completer.future;
    _inflight[url] = tracked;

    try {
      final controller = await _createAndInitialize(url);
      if (!completer.isCompleted) {
        completer.complete(controller);
      }
      return controller;
    } catch (e, st) {
      if (!completer.isCompleted) {
        completer.completeError(e, st);
      }
      rethrow;
    } finally {
      if (identical(_inflight[url], tracked)) {
        _inflight.remove(url);
      }
    }
  }

  Future<VideoPlayerController> _runAsHighPriority(
    String url,
    Future<VideoPlayerController> Function() action,
  ) async {
    _highPriorityUrl = url;
    final gate = Completer<void>();
    _highPriorityCompleter = gate;
    try {
      return await action();
    } finally {
      if (_highPriorityUrl == url) {
        _highPriorityUrl = null;
      }
      if (!gate.isCompleted) {
        gate.complete();
      }
      if (identical(_highPriorityCompleter, gate)) {
        _highPriorityCompleter = null;
      }
    }
  }

  /// Hard cap so a misbehaving CDN / hung HTTP socket / silent native failure
  /// can't leave the UI on an endless spinner. Sized to fit genuinely long
  /// recordings on slow mobile networks - QA observed real-world inits of
  /// 45-70s for large non-fast-start MP4s on weak 4G, which the previous 45s
  /// cap was cutting off (especially when a neighbor preload had already
  /// started the in-flight future before the user reached that page and
  /// joined it via [_inflight] coalescing).
  static const Duration _initializeTimeout = Duration(seconds: 90);

  /// Dispose not-yet-initialized controllers outside the retention window so a
  /// newly visible recording is not stuck behind HTTP work for old pages.
  Future<void> _abortCompetingInits({required String keepUrl}) async {
    final keepUrls = _retentionWindow.isEmpty
        ? {keepUrl}
        : {..._retentionWindow, keepUrl};

    final competitors = <String>{
      ..._cache.keys,
      ..._inflight.keys,
    }..removeWhere(keepUrls.contains);

    if (competitors.isEmpty) return;

    for (final competitorUrl in competitors) {
      final entry = _cache[competitorUrl];
      if (entry == null || entry.disposed) continue;
      if (entry.controller.value.isInitialized) continue;
      entry.disposed = true;
      _cache.remove(competitorUrl);
      unawaited(entry.controller.dispose());
    }
  }

  Future<VideoPlayerController> _createAndInitialize(String url) async {
    final stale = _cache[url];
    if (stale != null && !stale.disposed) {
      final value = stale.controller.value;
      if (value.isInitialized && !value.hasError) {
        stale.lastAccess = DateTime.now();
        return stale.controller;
      }
      // Orphaned / errored session from a prior attempt - tear down before
      // opening a fresh HTTP session (rare now that [_inflight] registers
      // before the first await).
      stale.disposed = true;
      _cache.remove(url);
      await stale.controller.dispose();
    }

    final controller = VideoPlayerController.networkUrl(Uri.parse(url));
    final entry = _CachedVideo(controller: controller);
    _cache[url] = entry;

    // Some platform versions (notably media3/ExoPlayer on Android) surface
    // source errors like HTTP 403 via `controller.value.hasError` instead of
    // rejecting the [initialize] future. Bridge both paths so we never silently
    // sit on an initialized-but-broken controller.
    final settled = Completer<void>();
    void onValueChanged() {
      if (settled.isCompleted) return;
      final value = controller.value;
      if (value.hasError) {
        settled.completeError(
          _RecordingPlaybackException(
            value.errorDescription ?? IsmLiveStrings.videoPlayerError,
          ),
        );
      }
    }

    controller.addListener(onValueChanged);

    final initFuture = controller.initialize();
    // Mirror init future completion into [settled] without leaving an
    // unhandled async error if the listener wins the race.
    unawaited(initFuture.then(
      (_) {
        if (!settled.isCompleted) settled.complete();
      },
      onError: (Object e, StackTrace s) {
        if (!settled.isCompleted) settled.completeError(e, s);
      },
    ));

    try {
      await settled.future.timeout(_initializeTimeout);
      if (entry.disposed) {
        throw _RecordingInitAbortedException();
      }
      if (_retentionWindow.isNotEmpty &&
          !_retentionWindow.contains(url) &&
          _highPriorityUrl != url) {
        throw _RecordingInitAbortedException();
      }
      if (controller.value.hasError) {
        throw _RecordingPlaybackException(
          controller.value.errorDescription ?? IsmLiveStrings.videoPlayerError,
        );
      }
      controller.removeListener(onValueChanged);
      entry.lastAccess = DateTime.now();
      // A previously-bad URL that is now reachable should not stay marked
      // as broken for the rest of the session.
      _knownFailures.remove(url);
      return controller;
    } catch (e) {
      controller.removeListener(onValueChanged);
      await controller.dispose();
      _cache.remove(url);
      if (e is _RecordingInitAbortedException) {
        rethrow;
      }
      if (_isPermanentFailure(e)) {
        _knownFailures[url] = e.toString();
      }
      rethrow;
    }
  }

  /// Heuristic: is [error] the kind of failure where retrying immediately is
  /// going to fail the same way (closed S3 ACL, deleted object, expired
  /// presigned URL, etc.)?
  ///
  /// Conservative on purpose - we never want to permanently blacklist a URL
  /// over a transient socket / timeout / decoder hiccup. Only well-known
  /// "the server told us no" responses qualify.
  static bool _isPermanentFailure(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('response code: 4')) return true;
    if (message.contains('http 4')) return true;
    if (message.contains('status 4')) return true;
    if (message.contains('403')) return true;
    if (message.contains('404')) return true;
    if (message.contains('410')) return true;
    return false;
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

    // Always preload one URL at a time. Originally serial was iOS-only (to
    // dodge CoreMedia/AVPlayer 403s on parallel sessions), but parallel
    // neighbor preloads on Android were splitting bandwidth between two long
    // MP4 downloads and routinely pushing each one past [_initializeTimeout].
    // Serial keeps each download on the full pipe and finishes the most
    // important neighbor (the next one) first - callers should pass URLs in
    // priority order.
    for (final url in urls) {
      if (url.isEmpty) continue;
      await runOne(url);
    }
  }

  Future<void> _preload(String url) async {
    if (_retentionWindow.isNotEmpty && !_retentionWindow.contains(url)) {
      return;
    }

    final generation = _preloadGeneration;
    final previous = _backgroundPreloadChain;
    final gate = Completer<void>();
    _backgroundPreloadChain = gate.future;
    await previous;
    if (generation != _preloadGeneration) return;

    try {
      if (_retentionWindow.isNotEmpty && !_retentionWindow.contains(url)) {
        return;
      }
      await getOrCreate(url);
    } on _RecordingInitAbortedException {
      // Preload was bumped aside for the visible recording - expected.
    } catch (_) {
      // Ignore preload failures; playback can retry on demand.
    } finally {
      if (!gate.isCompleted) {
        gate.complete();
      }
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

  /// Immediately dispose controllers (and abort in-flight inits) for every URL
  /// outside [keepUrls]. Called on page change so stale neighbor preloads from
  /// a previous index stop competing for bandwidth / decoders.
  Future<void> abandonOutside(Set<String> keepUrls) async {
    _retentionWindow = keepUrls;
    // Drop queued neighbor work from previous pages immediately. Without this,
    // a slow preload started 5 pages ago can block the chain and leave the
    // visible recording on a 60s+ cold start even for short clips.
    _preloadGeneration++;
    _backgroundPreloadChain = Future<void>.value();

    if (_highPriorityUrl != null && !keepUrls.contains(_highPriorityUrl)) {
      _highPriorityUrl = null;
      _highPriorityCompleter?.complete();
      _highPriorityCompleter = null;
    }

    final urlsToDrop = <String>{
      ..._cache.keys,
      ..._inflight.keys,
    }..removeWhere(keepUrls.contains);

    if (urlsToDrop.isEmpty) return;

    final disposeFutures = <Future<void>>[];
    for (final url in urlsToDrop) {
      final entry = _cache[url];
      if (entry != null && !entry.disposed) {
        entry.disposed = true;
        disposeFutures.add(entry.controller.dispose());
      }
      _cache.remove(url);
    }

    if (disposeFutures.isNotEmpty) {
      await Future.wait(disposeFutures);
    }
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
    _retentionWindow = <String>{};
    _highPriorityUrl = null;
    _highPriorityCompleter?.complete();
    _highPriorityCompleter = null;
    _backgroundPreloadChain = Future<void>.value();
    _preloadGeneration++;
    // Player screen is going away entirely - drop any known-bad markings so
    // a future re-open of the player can take a fresh swing at each URL.
    _knownFailures.clear();
  }
}

/// Thrown when a background preload is intentionally cancelled so the visible
/// recording can initialize without waiting in a global queue.
class _RecordingInitAbortedException implements Exception {
  @override
  String toString() => 'Recording init aborted';
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

/// Thin error type so callers (and analytics) can distinguish recording
/// playback failures from generic [Exception]s.
class _RecordingPlaybackException implements Exception {
  _RecordingPlaybackException(this.message);

  final String message;

  @override
  String toString() => message;
}

