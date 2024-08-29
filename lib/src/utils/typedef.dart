import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/widgets.dart';
import 'package:livekit_client/livekit_client.dart';
import 'package:mqtt_helper/mqtt_helper.dart';

typedef DynamicMap = Map<String, dynamic>;

typedef MapFunction = Function(DynamicMap);

typedef EventFunction = Function(EventModel);

typedef MapStreamSubscription = StreamSubscription<DynamicMap>;

typedef EventStreamSubscription = StreamSubscription<EventModel>;

typedef ViewerBuilder = Widget Function(BuildContext, IsmLiveViewerModel);

typedef FutureFunction = Future<void> Function();

typedef RoomListener = EventsListener<RoomEvent>;

typedef IsmLiveHeaderBuilder = Widget Function(
  BuildContext,
  IsmLiveMemberDetailsModel?,
  String,
);

typedef IsmLiveInputBuilder = Widget Function(BuildContext, Widget);
