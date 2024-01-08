import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter/widgets.dart';
import 'package:livekit_client/livekit_client.dart';

typedef DynamicMap = Map<String, dynamic>;

typedef MapFunction = Function(DynamicMap);

typedef MapStreamSubscription = StreamSubscription<DynamicMap>;

typedef ViewerBuilder = Widget Function(BuildContext, IsmLiveViewerModel);

typedef FutureFunction = Future<void> Function();

typedef RoomListener = EventsListener<RoomEvent>;
