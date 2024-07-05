import 'dart:async';
import 'dart:convert';

import 'package:appscrip_live_stream_component/appscrip_live_stream_component.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class LocalNotificationService {
  LocalNotificationService._internal();

  factory LocalNotificationService() => _notificationService;

  // Singleton of the LocalNoticeService
  static final LocalNotificationService _notificationService =
      LocalNotificationService._internal();

  static FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  StreamController<NotificationResponse> streamController = StreamController();
  onTap(NotificationResponse notificationResponse) {
    streamController.add(notificationResponse);
  }

  static var channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  Future<void> init() async {
    final androidSetting =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSetting =
        DarwinInitializationSettings(requestSoundPermission: true);

    final initSettings =
        InitializationSettings(android: androidSetting, iOS: iosSetting);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    /// Create an Android Notification Channel.
    ///
    /// We use this channel in the `AndroidManifest.xml` file to override the
    /// default FCM channel to enable heads up notifications.
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await flutterLocalNotificationsPlugin
        .initialize(
      initSettings,
    )
        .then((_) {
      IsmLiveLog.info('setupPlugin: setup success');
    }).catchError((Object error) {
      IsmLiveLog.error('Error: $error');
    });
  }

  //basic Notification
  static void showBasicNotification({
    required String title,
    required String body,
    required String payload,
  }) {
    cancelNotification();
    addNotification(
      title, // Add the  sender user name here
      body, // MessageName
      DateTime.now().millisecondsSinceEpoch + 1 * 1000,
      sound: '',
      channel: 'message',
      payload: {},
    );

    if (GetPlatform.isAndroid) {
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
        android: android,
      );
      flutterLocalNotificationsPlugin.show(
        0,
        title,
        body,
        details,
        payload: payload,
      );
    }
  }

  static void addNotification(
    String title,
    String body,
    int endTime, {
    String sound = '',
    String channel = 'default',
    required Map<String, dynamic> payload,
  }) async {
    tz_data.initializeTimeZones();

    final scheduleTime =
        tz.TZDateTime.fromMillisecondsSinceEpoch(tz.local, endTime);

    // #3
    final iosDetail = sound == ''
        ? null
        : DarwinNotificationDetails(presentSound: true, sound: sound);

    final soundFile = sound.replaceAll('.mp3', '');
    final notificationSound =
        sound == '' ? null : RawResourceAndroidNotificationSound(soundFile);

    final androidDetail = AndroidNotificationDetails(
        channel, // channel Id
        channel, // channel Name
        playSound: true,
        sound: notificationSound);

    final noticeDetail = NotificationDetails(
      iOS: iosDetail,
      android: androidDetail,
    );

    // #4
    const id = 0;

    await flutterLocalNotificationsPlugin.zonedSchedule(
        id, title, body, scheduleTime, noticeDetail,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: jsonEncode(payload));
  }

  static void cancelNotification() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
