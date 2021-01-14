import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

abstract class UPNotificationUtils {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  // static const MethodChannel _platform =
  // MethodChannel('dexterx.dev/flutter_local_notifications_example');

  static bool _notificationInitialized = false;

  static Future<bool> basicOnNotification(
      String title, String body, int priority) async {
    debugPrint("onNotification");
    print(title);
    if (!_notificationInitialized) _initNotifications();

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        playSound: false, importance: Importance.max, priority: Priority.high);
    print(priority);
    var platformChannelSpecifics =
        new NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().microsecondsSinceEpoch % 10000000,
      title,
      body,
      platformChannelSpecifics,
      payload: 'No_Sound',
    );
    return true;
  }

  static void _initNotifications() async {
    WidgetsFlutterBinding.ensureInitialized();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('notification_icon');
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    _notificationInitialized = await _flutterLocalNotificationsPlugin
        .initialize(initializationSettings,
            onSelectNotification: (String payload) async {
      if (payload != null) {
        debugPrint('notification payload: $payload');
      }
    });
  }
}
