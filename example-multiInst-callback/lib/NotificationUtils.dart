import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'main.dart';

abstract class UPNotificationUtils {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static bool _notificationInitialized = false;

  static Map<String, String> decodeMessageContentsUri(String message) {
    List<String> uri = Uri.decodeComponent(message).split("&");
    Map<String, String> decoded = {};
    uri.forEach((String i) {
      try {
        decoded[i.split("=")[0]] = i.split("=")[1];
      } on Exception {}
    });
    return decoded;
  }

  static Future<bool> basicOnNotification(String payload, String _instance) async {
    debugPrint("onNotification");
    if (_instance != instance) {
      debugPrint("wrong instance");
      return false;
    }
    Map<String, String> message = decodeMessageContentsUri(payload);
    String title = message['title'] ?? "UP - Example";
    String body = message['message'] ?? "with flutter-connector";
    int priority = int.parse(message['priority'] ?? "5");
    print(title);
    if (!_notificationInitialized) _initNotifications();

    var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
        'UP-Example', 'UP-Example',
        playSound: false, importance: Importance.max, priority: Priority.high);
    print(priority);
    var platformChannelSpecifics =
        new NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      DateTime.now().microsecondsSinceEpoch % 100000000,
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
