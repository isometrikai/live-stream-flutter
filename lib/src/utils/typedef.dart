import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:appscrip_live_stream_component/src/controllers/mqtt/mqtt_helper.dart';
import 'package:flutter/widgets.dart';
import 'package:livekit_client/livekit_client.dart';

typedef DynamicMap = Map<String, dynamic>;

typedef MapFunction = Function(DynamicMap);

typedef EventFunction = Function(EventModel);

typedef MapStreamSubscription = StreamSubscription<DynamicMap>;

typedef EventStreamSubscription = StreamSubscription<EventModel>;

typedef ViewerBuilder = Widget Function(BuildContext, IsmLiveViewerModel);

typedef FutureFunction = Future<void> Function();

typedef RoomListener = EventsListener<RoomEvent>;

typedef IsmLiveHeaderBuilder = Widget Function(
  BuildContext context,
  IsmLiveMemberDetailsModel? hostDetails,
  String description,
);

/// Builder for the stream header. Receives [defaultHeader] so the host can use
/// it as-is, wrap it, or replace it with a fully custom widget.
typedef IsmLiveStreamHeaderBuilder = Widget Function(
  BuildContext context,
  IsmLiveMemberDetailsModel? hostDetails,
  String description,
  Widget defaultHeader,
);

typedef IsmLiveInputBuilder = Widget Function(BuildContext, Widget);

/// Builder for custom bottom sheet UI.
///
/// This builder allows host applications to provide a custom bottom sheet widget
/// that will be used instead of the default IsmLiveCustomButtomSheet.
///
/// [context] - The BuildContext from the SDK UI.
/// [title] - The title text to display in the bottom sheet.
/// [leftLabel] - The label for the left button.
/// [rightLabel] - The label for the right button.
/// [onLeft] - The callback function for the left button action.
/// [onRight] - The callback function for the right button action.
///
/// Return a Widget that will be displayed as the custom bottom sheet.
/// The widget should handle its own layout and styling but must provide
/// the required functionality for the left and right button actions.
///
/// This builder is called when showing confirmation dialogs, action sheets,
/// and similar bottom sheet UI components throughout the SDK.
/// Useful for implementing:
/// - Custom bottom sheet design and branding
/// - Integration with host app's design system
/// - Custom button layouts and styling
/// - Custom animations and transitions
/// - Analytics tracking for bottom sheet interactions
typedef IsmLiveCustomBottomSheetBuilder = Widget Function(
  BuildContext context,
  String title,
  String leftLabel,
  String rightLabel,
  VoidCallback? onLeft,
  VoidCallback? onRight,
);
