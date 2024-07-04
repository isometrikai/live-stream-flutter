import 'dart:async';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotificationService {
  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static StreamController<NotificationResponse> streamController =
      StreamController();
  static onTap(NotificationResponse notificationResponse) {
    streamController.add(notificationResponse);
  }

  static Future init() async {
    var settings = const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await flutterLocalNotificationsPlugin.initialize(
      settings,
      onDidReceiveNotificationResponse: onTap,
      onDidReceiveBackgroundNotificationResponse: onTap,
    );
  }

  //basic Notification
  static void showBasicNotification({
    required String title,
    required String body,
    required String payload,
  }) async {
    var channel = const AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // title
      description:
          'This channel is used for important notifications.', // description
      importance: Importance.high,
    );
    var android = AndroidNotificationDetails(
      channel.id,
      channel.name,
      channelDescription: channel.description ?? '',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'ticker',
      playSound: true,
      icon: '@mipmap/ic_launcher',
      color: IsmLiveColors.black,
    );
    var details = NotificationDetails(
        iOS: const DarwinNotificationDetails(
          presentBadge: true,
          presentAlert: true,
          presentSound: true,
        ),
        android: android);
    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      details,
      payload: payload,
    );
  }

  static void cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
