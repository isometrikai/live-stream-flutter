part of '../live_delegate.dart';

/// Enum to identify the type of stream disconnection
enum IsmLiveStreamDisconnectType {
  /// Host is ending/stopping the stream
  host,

  /// Viewer is leaving the stream
  viewer,

  /// PK guest is leaving the stream
  pkGuest,

  /// Copublisher is leaving the stream
  copublisher,
}

/// API handler callback for stream disconnect/exit operations.
///
/// This is a unified callback that **replaces the default SDK API calls** for all types of stream disconnections.
/// It replaces the separate `onHostStopStream` and `onLeftStreamAsViewer` callbacks.
///
/// **Purpose**: Allows host applications to provide their own API implementation for stream disconnect operations
/// instead of using the SDK's default API endpoints.
///
/// [streamId] - The current stream ID.
/// [disconnectType] - The type of disconnection (host, viewer, pkGuest, copublisher).
///
/// **Return Value**:
/// - Return `true` if your API call was successful and the SDK should proceed with cleanup
/// - Return `false` if your API call failed and the SDK should abort the disconnect process
///
/// **If this callback is NOT provided**, the SDK will use its default API implementations:
/// - For `host`: calls the SDK's `stopStream` API endpoint
/// - For `viewer`: calls the SDK's `leaveStream` API endpoint
/// - For `pkGuest`: calls the SDK's `pkEnd` operation
/// - For `copublisher`: calls the SDK's `leaveMember` operation
///
/// **Common use cases**:
/// - Replace SDK API calls with your own backend endpoints
/// - Add custom authentication/authorization logic
/// - Implement custom analytics tracking for stream exits
/// - Add business logic specific to your application
/// - Integrate with external services or webhooks
/// - Implement custom retry logic and error handling
/// - Centralize all disconnect API calls in one handler
///
/// **Example**:
/// ```dart
/// IsmLiveApp.configureInterface(
///   streamDisconnectApiHandler: (streamId, disconnectType) async {
///     // Replace SDK's API with your own
///     final response = await myApi.disconnectStream(streamId, disconnectType);
///     return response.success; // true = proceed, false = abort
///   },
/// );
/// ```
typedef StreamDisconnectApiHandler = Future<bool> Function(
  String streamId,
  IsmLiveStreamDisconnectType disconnectType,
);

/// Identifies which SDK send-message endpoint would be called by default.
enum IsmLiveSendMessageOperation {
  /// POST `/streaming/v2/message` — chat text, likes, gifts, etc.
  send,

  /// POST `/streaming/v2/message/reply` — reply to an existing chat message.
  reply,
}

/// API handler callback for sending stream chat messages.
///
/// **Replaces the default SDK API calls** for [IsmLiveSendMessageOperation.send]
/// and [IsmLiveSendMessageOperation.reply] when set via
/// `IsmLiveApp.configureInterface(streamScreenConfigure: ...)`.
///
/// The SDK builds the same [IsmLiveSendMessageModel] it would post internally;
/// use [IsmLiveSendMessageModel.toMap] for the exact JSON body your backend
/// expects.
///
/// [sendMessageModel] — Full request payload (streamId, body, searchableTags,
/// metaData, customType, deviceId, parentMessageId, messageType).
///
/// [operation] — `send` for `POST /streaming/v2/message`, `reply` for
/// `POST /streaming/v2/message/reply`.
///
/// **Return value**
/// - `true` — host API succeeded; SDK keeps existing UI behavior (clear input,
///   analytics, etc.).
/// - `false` — host API failed; SDK restores the message field for text/reply.
///
/// **When not set**, the SDK uses its built-in endpoints unchanged.
///
/// **Example (text chat)**
/// ```dart
/// IsmLiveApp.configureInterface(
///   streamScreenConfigure: IsmLiveStreamScreenConfigure(
///     streamSendMessageApiHandler: (model, operation) async {
///       final payload = model.toMap();
///       if (operation == IsmLiveSendMessageOperation.reply) {
///         return (await myApi.replyStreamMessage(payload)).success;
///       }
///       return (await myApi.postStreamMessage(payload)).success;
///     },
///   ),
/// );
/// ```
typedef StreamSendMessageApiHandler = Future<bool> Function(
  IsmLiveSendMessageModel sendMessageModel,
  IsmLiveSendMessageOperation operation,
);

/// Preferred initial camera position when starting a stream
enum IsmLiveCameraPosition {
  front,
  back,
}

/// Direction for host arrow button clicks
enum IsmLiveArrowDirection {
  previous,
  next,
}

/// Callback for host arrow button clicks (pin item navigation)
///
/// This callback is triggered when the user taps on the left or right arrow buttons
/// in the host interface for product navigation.
///
/// [context] - The BuildContext from the SDK UI.
/// [direction] - The direction of the arrow that was clicked (previous or next).
///
/// This callback is called when arrow buttons are tapped in the host interface.
/// Useful for implementing:
/// - Custom product navigation
/// - Custom content switching
/// - Integration with host app's navigation system
/// - Custom analytics tracking for arrow interactions
/// - Custom UI state management
/// - Custom business logic for arrow actions
typedef PinItemCallback = void Function(
  BuildContext context,
  IsmLiveArrowDirection direction,
);

/// Callback for "Buy now" button clicks
///
/// This callback is triggered when the user taps on the "Buy now" button
/// in the product stream interface.
///
/// This callback is called when the "Buy now" button is tapped.
/// Useful for implementing:
/// - Custom purchase flow
/// - Integration with host app's e-commerce system
/// - Custom analytics tracking for purchase interactions
/// - Custom UI state management
/// - Custom business logic for purchase actions
typedef BuyNowCallback = void Function();

/// Callback for "Add Coins" button clicks
///
/// This callback is triggered when the user taps on the "Add Coins" button
/// in the gifts sheet interface.
///
/// [context] - The BuildContext from the SDK UI.
///
/// This callback is called when the "Add Coins" button is tapped.
/// Useful for implementing:
/// - Custom navigation to coins/wallet screen
/// - Integration with host app's payment system
/// - Custom analytics tracking for add coins interactions
/// - Custom UI state management
/// - Custom business logic for add coins actions
///
/// If this callback is NOT provided, the SDK will use its default navigation
/// to the coins plan wallet screen.
typedef AddCoinsClickCallback = void Function(BuildContext context);

/// Callback for gift item click events in the gifts sheet.
///
/// This callback is triggered whenever a user taps on a gift in the gifts grid.
///
/// [context] - The BuildContext from the SDK UI.
/// [gift] - The selected gift item.
///
/// This is a notification-style callback and **does not** override the default
/// gift sending behavior. The SDK will continue to handle balance checks,
/// dialogs, and sending the gift as usual.
///
/// Useful for:
/// - Custom analytics for gift interactions
/// - Logging or tracking user behavior
/// - Triggering auxiliary UI in the host app
typedef GiftClickCallback = void Function(
  BuildContext context,
  IsmLiveGiftsCategoryModel gift,
);

/// Callback when the SDK flushes accumulated heart (like) taps to the backend.
///
/// **The SDK always awaits `sendHeartMessage` first** (same API as without this
/// callback). This hook runs **after** that call succeeds, in the background, so
/// the like API is never skipped or delayed by host-app work.
///
/// Notification-style only (like [GiftClickCallback]): use for analytics, logging,
/// or auxiliary UI. Errors in the callback are logged and do not affect sending.
///
/// [streamId] - The active stream ID.
/// [likesCount] - Batch size (same value the SDK sends as `metaData.likeCounts` via
/// the standard `sendMessage` / post-message API in `sendHeartMessage`).
///
/// **If this callback is not set**, the SDK posts batched likes to the internal
/// `POST /live/v1/stream/like` endpoint (`sentViaMqtt: true`) after `sendHeartMessage`.
typedef HeartBatchFlushCallback = Future<void> Function(
  String streamId,
  int likesCount,
);

/// Callback for stream listing refresh events.
///
/// This callback is triggered when stream listing data needs to be refreshed
/// due to MQTT events like streamStartPresence, streamStopPresence, or streamStopped.
/// If this callback is provided, the internal stream listing refresh will be skipped.
///
/// [eventType] - The type of event that triggered the refresh (streamStartPresence, streamStopPresence, streamStopped).
/// [streamId] - The stream ID related to the event (null for streamStartPresence).
/// [payload] - The full MQTT payload for additional context.
typedef StreamListingRefreshCallback = void Function(
  String eventType,
  String? streamId,
  Map<String, dynamic> payload,
);

/// Callback for stream scroll events.
///
/// This callback is triggered when the user scrolls to a different stream in the stream view.
/// This is a notification-only callback that does not block or affect the SDK's scroll behavior.
/// The callback is called asynchronously (fire and forget) to notify the host app of the scroll event.
///
/// [context] - The build context where the scroll occurred.
/// [currentStreamId] - The ID of the stream being left.
/// [nextStreamIndex] - The index of the stream being scrolled to.
/// [nextStream] - The stream data model of the stream being scrolled to.
/// [isHost] - Whether the current user is the host of the current stream.
///
/// This callback is called when a stream scroll is initiated, but does not wait for completion.
/// Useful for implementing:
/// - Custom analytics tracking for stream scrolling
/// - Logging stream transitions
/// - Notifying external services about scroll events
/// - Triggering background tasks
/// - Custom event tracking
/// - Stream engagement metrics
typedef OnStreamScrollCallback = void Function(
  BuildContext context,
  String currentStreamId,
  int nextStreamIndex,
  IsmLiveStreamDataModel nextStream,
  bool isHost,
);

/// Called when the backend indicates the `userToken` has expired (401/406 cases).
///
/// Host app should return a fresh token string. Returning `null`/empty means
/// "could not refresh" and the SDK will not retry.
typedef TokenExpiredCallback = FutureOr<String?> Function();