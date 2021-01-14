import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_unified_push.dart';

void callbackDispatcher() {
  // 1. Initialize MethodChannel used to communicate with the platform portion of the plugin.
  const MethodChannel _backgroundChannel =
      MethodChannel('flutter_unified_push.method.background_channel');

  // 2. Setup internal state needed for MethodChannels.
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Listen for background events from the platform portion of the plugin.
  _backgroundChannel.setMethodCallHandler((MethodCall call) async {
    debugPrint("callbackdispatcher");
    final args = call.arguments as String;
    // 3.1. Retrieve callback instance for handle.
    debugPrint("aaa");
    debugPrint(FlutterUnifiedPush.prefs.toString());
    if (FlutterUnifiedPush.prefs == null) {
      FlutterUnifiedPush.prefs = await SharedPreferences.getInstance();
      debugPrint("new prefs");
    }

    debugPrint(FlutterUnifiedPush.prefs.toString());
    final Function callback = PluginUtilities.getCallbackFromHandle(
        CallbackHandle.fromRawHandle(
            FlutterUnifiedPush.prefs.getInt('notification_method')));
    debugPrint(callback.toString());
    debugPrint(CallbackHandle.fromRawHandle(
            FlutterUnifiedPush.prefs.getInt('notification_method'))
        .toRawHandle()
        .toString());
    assert(callback != null);

    //3.3. Invoke callback.
    Map<String, String> message = decodeMessageContentsUri(args);
    String title = message['title'] ?? "";
    String messageBody = message['message'] ?? "";
    int priority = int.parse(message['priority']) ?? 5;
    debugPrint(message.toString());
    debugPrint(messageBody);

    bool ans = await callback(title, messageBody, priority);
    print(ans);
  });

  // 4. Alert plugin that the callback handler is ready for events.
  _backgroundChannel.invokeMethod('FlutterUnifiedPushService.initialized');
}

Map<String, String> decodeMessageContentsUri(String message) {
  List<String> uri = Uri.decodeComponent(message).split("&");
  Map<String, String> decoded = {};
  uri.forEach((String i) {
    try {
      decoded[i.split("=")[0]] = i.split("=")[1];
      // print(i);
    } on Exception {}
  });
  return decoded;
}
