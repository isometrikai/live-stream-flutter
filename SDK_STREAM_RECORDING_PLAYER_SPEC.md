# SDK: Stream Recording Player Module — Specification & Cursor Prompt

This document is the **single source of truth** for adding the **Stream Recording Player** feature into the **streaming SDK** (a separate Flutter project pulled via GitHub). Use this doc as the prompt/spec when implementing the player inside the SDK. The host app (e.g. flutter_social_commerce) will **not** be changed until the SDK has full player support.

**Reference implementation (host app — SDK cannot reference this project):**  
Full path to the stream_recording module:
```
F:\Flutter\projects\flutter_social_commerce\lib\presentation\screens\stream_recording
```
Parent screens path:
```
F:\Flutter\projects\flutter_social_commerce\lib\presentation\screens
```
Use this spec and the file/structure description below as the source of truth; do not add project references to the host app from the SDK.

---

## 1. Purpose

- **What**: A full-screen stream recording player that plays recorded stream URLs, shows products linked to the stream, and supports vertical swipe between multiple recordings.
- **Where**: Implement inside the **SDK project** (streaming SDK), under an appropriate module path (e.g. `lib/stream_recording/` or `lib/player/`).
- **Constraint**: The player must **not** call host app APIs directly. Two operations are performed on every recording play and **must be dynamic** so any host app can provide its own implementation.

---

## 2. The Two Dynamic APIs (Required)

These two operations are triggered when a recording starts playing (initial load and when user swipes to another recording). The SDK must **not** hardcode endpoints or use cases; the host app must be able to plug in its own API calls.

### 2.1 Record View Count

- **When**: Called once per recording when that recording’s playback is initialized (initial open or after swipe to another recording).
- **Current host behavior**: POST to an endpoint like `/v1/stream/recorded/view/count` with body `{ "id": "<streamId>" }`. Host app uses `GetHomeDataUseCase.recordViewCount(id: streamId)`.
- **SDK contract**:  
  The SDK must call a **callback** provided by the host, e.g.  
  `Future<void> onRecordViewCount(String streamId)`  
  The host is responsible for performing the actual API request (or no-op) inside this callback.

### 2.2 Fetch Stream Products

- **When**: Called once per recording when that recording’s playback is initialized (same moment as record view count).
- **Current host behavior**: GET (or equivalent) to fetch products for a livestream, e.g. endpoint like `/get/livestream/products` with `streamId`, `page`, and optional `q`. Host app uses `GetStreamTagProductsUseCase(streamId: …, page: …, q: …)` and returns a list of `ProductDataModel`.
- **SDK contract**:  
  The SDK must call a **callback** provided by the host that returns the list of products to show, e.g.  
  `Future<StreamRecordingProductList> onFetchStreamProducts(String streamId, int page, String? searchQuery)`  
  where `StreamRecordingProductList` is an SDK-defined type (or interface) that the host can map from its own API response. The host performs the actual API call and returns data in the format the SDK expects.

**Summary**:  
- **Record view count** → host implements `onRecordViewCount(streamId)`.  
- **Stream products** → host implements `onFetchStreamProducts(streamId, page, q)` and returns a list the SDK can render.

---

## 3. Module Structure (Files to Recreate in SDK)

Replicate this structure inside the SDK. The **reference implementation** lives in the host app at this **full path** (SDK cannot reference that project; use this spec only):

**Full path — stream_recording module:**
```
F:\Flutter\projects\flutter_social_commerce\lib\presentation\screens\stream_recording
```

**Full paths — each file in the reference implementation:**

| File (full path in host app) | Role |
|------------------------------|------|
| `F:\Flutter\projects\flutter_social_commerce\lib\presentation\screens\stream_recording\stream_recording_player_view.dart` | Main full-screen player: state, video init, page view for multiple streams, controls overlay, and **calls to the two dynamic APIs via callbacks** (record view count + fetch products). |
| `...\stream_recording\widgets\widgets.dart` | Barrel export for player widgets. |
| `...\stream_recording\widgets\video_player_widget.dart` | Wraps `video_player`’s `VideoPlayer` + loading/error/retry UI. |
| `...\stream_recording\widgets\center_play_button_widget.dart` | Center play/pause button overlay. |
| `...\stream_recording\widgets\bottom_controls_widget.dart` | Bottom bar: product strip, progress bar, play/pause, seek. |
| `...\stream_recording\widgets\top_controls_widget.dart` | Top bar: user chip, viewer count, cart action, close. |
| `...\stream_recording\widgets\right_controls_widget.dart` | Right rail: Products, Share, More. |
| `...\stream_recording\widgets\bottom_sheets\all_products_bottom_sheet.dart` | Bottom sheet listing all products for the current stream. |
| `...\stream_recording\widgets\bottom_sheets\more_options_bottom_sheet.dart` | More options: Delete (own stream) or Report (others). |
| `...\stream_recording\widgets\bottom_sheets\follow_user_bottom_sheet.dart` | Bottom sheet for follow/unfollow streamer. |

*(Above, `...` denotes `F:\Flutter\projects\flutter_social_commerce\lib\presentation\screens`.)*

In the SDK, place the same structure under the SDK’s chosen module root (e.g. `lib/stream_recording/`).

**Important**: In the SDK, replace every **direct** use of host-specific blocs/use cases/repositories (e.g. `LiveBloc`, `GetHomeDataUseCase`, `GetStreamTagProductsUseCase`) with the **two callbacks** above and any other optional callbacks (see section 6).

---

## 4. Data Models the SDK Must Define or Accept

The player depends on:

- **Stream / recording item** (current host: `MissedStream`): at minimum needs `streamId`, `recordedUrl` (list of URLs), `recordViewCount`, `storeId`, `userDetails` (for profile chip and follow), and any fields needed for “more options” (e.g. delete/report). The SDK can define an abstract class or interface (e.g. `StreamRecordingItem`) and require the host to pass objects that conform to it (or an adapter).
- **Product item** (current host: `ProductDataModel` / `ProductDataItem`): used in the product strip, “All products” bottom sheet, and share. The SDK should define a minimal product type (e.g. `StreamRecordingProduct`) with fields needed for display and share (id, name, image URL, price, deep link, etc.). The host’s `onFetchStreamProducts` returns a list of this type (or the host maps its models to it).

The SDK should **not** depend on host-specific model class names; use SDK-owned types or clear interfaces.

---

## 5. Player Behavior (Logic to Preserve)

- **Input**: One “current” stream/recording item + optional list of recordings for vertical swipe (e.g. `PageView`).
- **Initialization**: For the current recording, resolve `recordedUrl` (e.g. first URL), initialize `VideoPlayerController.networkUrl`, then:
  1. Call **record view count** callback with `streamId`.
  2. Call **fetch stream products** callback with `streamId`, `page: 1`, `q: ''` (or equivalent).
- **State**: Products list is updated from the fetch callback result and shown in bottom strip + “All products” sheet.
- **Swipe**: On page change, dispose current controller, set new stream, then again call record view count + fetch products for the new `streamId`, then init video for the new URL.
- **Controls**: Play/pause, seek, progress, auto-hide overlay (e.g. 3s), center play button when controls visible.
- **Actions**: Close, open “All products” sheet, Share (optional callback), More (delete/report via callbacks), Follow (optional callback). Cart/social navigation should be optional host callbacks.

---

## 6. Host Callbacks / Configuration (Recommended API)

Expose a configuration or callback set so the host app can wire its own APIs and navigation:

| Callback / config | Required | Description |
|-------------------|----------|-------------|
| `onRecordViewCount(String streamId)` | **Yes** | Invoked when a recording play starts. Host hits its “record view count” API. |
| `onFetchStreamProducts(String streamId, int page, String? q)` | **Yes** | Invoked when a recording play starts. Host hits its “stream products” API and returns a list in SDK format. |
| `getCurrentUserId()` | Optional | For “my stream” vs “others” and follow button visibility. |
| `getCurrentStoreId()` | Optional | For “my stream” and product ownership display. |
| `onDeleteStream(String streamId, …)` | Optional | Called when user chooses Delete in more options. Host performs delete API and can pop or refresh. |
| `onReportStream(String streamId, String? userId)` | Optional | Called when user chooses Report. Host can open its report flow. |
| `onShare(StreamRecordingProduct? product, StreamRecordingItem stream)` | Optional | Host can share product or stream link. |
| `onNavigateToCart()`, `onNavigateToSocialPost()` | Optional | For top bar actions (e.g. cart icon). |
| Follow / user profile | Optional | If the SDK shows follow or profile, use callbacks (e.g. `onOpenUserProfile(userId)`, `onFollowUser(userId)`) or let host supply a small “profile” widget. |

The two **required** callbacks are **record view count** and **fetch stream products**; the rest can be optional so that different host apps can integrate minimally or fully.

---

## 7. Dependencies

- **video_player**: Used in `VideoPlayerWidget` and the main view for `VideoPlayerController.networkUrl(Uri.parse(url))`.
- Flutter: `material`, `services` (e.g. `SystemUiOverlayStyle`), `widgets`.
- No dependency on host app’s `LiveBloc`, `GetHomeDataUseCase`, `GetStreamTagProductsUseCase`, or API layer.

---

## 8. What Not to Do in the SDK

- Do **not** hardcode API base URLs, endpoints, or request bodies.
- Do **not** depend on host app’s Bloc/GetX/use case/repository types for the two operations; use the two callbacks only.
- Do **not** add any reference or dependency to the host project. The reference implementation path is for documentation only: `F:\Flutter\projects\flutter_social_commerce\lib\presentation\screens\stream_recording`.
- Do **not** change the host app’s existing stream_recording module until the SDK implementation is complete and the host is ready to switch to the SDK player.

---



