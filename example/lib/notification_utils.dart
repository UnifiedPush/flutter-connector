import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:unifiedpush/unifiedpush.dart';

import 'main.dart';

abstract class UPNotificationUtils {
  static final FlutterLocalNotificationsPlugin
      _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static bool _notificationInitialized = false;

  static Map<String, String> decodeMessageContentsUri(String message) {
    List<String> uri = Uri.decodeComponent(message).split("&");
    Map<String, String> decoded = {};
    for (var i in uri) {
      try {
        decoded[i.split("=")[0]] = i.split("=")[1];
      } on Exception {
        debugPrint("Couldn't decode $i");
      }
    }
    return decoded;
  }

  static Future<bool> basicOnNotification(
    PushMessage message,
    String instance,
  ) async {
    debugPrint("instance $instance");
    if (instance != localInstance) {
      return false;
    }
    debugPrint("onNotification");
    var payload = utf8.decode(message.content);

    String title = 'UP-Example'; // Default title
    String body = 'Could not get the content'; // Default body

    try {
      // Try to decode title and message (JSON)
      Map<String, String> decodedMessage = decodeMessageContentsUri(payload);
      title = decodedMessage['title'] ?? title;
      body = decodedMessage['message'] ?? body;
    } catch (e) {
      // If decoding fails, use plain payload as body
      body = payload.isNotEmpty ? payload : 'Empty message';
    }

    debugPrint(title);
    if (!_notificationInitialized) _initNotifications();

    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
        'UP-Example', 'UP-Example',
        playSound: false, importance: Importance.max, priority: Priority.high);
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
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
    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'open');
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      linux: initializationSettingsLinux,
    );
    _notificationInitialized = await _flutterLocalNotificationsPlugin
            .initialize(initializationSettings) ??
        false;
  }
}
