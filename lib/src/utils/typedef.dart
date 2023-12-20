import 'dart:async';

typedef DynamicMap = Map<String, dynamic>;

typedef MapFunction = Function(DynamicMap);

typedef MapStreamSubscription = StreamSubscription<DynamicMap>;
