import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main.dart';

void callbackDispatcher() {
  // 1. Initialize MethodChannel used to communicate with the platform portion of the plugin.
  const MethodChannel _backgroundChannel =
      MethodChannel('org.unifiedpush.flutter.connector.background_channel');

  // 2. Setup internal state needed for MethodChannels.
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Listen for background events from the platform portion of the plugin.
  _backgroundChannel.setMethodCallHandler((MethodCall call) async {
    debugPrint("callbackdispatcher");
    final args = call.arguments as String;
    // 3.1. Retrieve callback instance for handle.
    debugPrint(UnifiedPush.prefs.toString());
    if (UnifiedPush.prefs == null) {
      UnifiedPush.prefs = await SharedPreferences.getInstance();
      debugPrint("new prefs");
    }

    debugPrint(UnifiedPush.prefs.toString());
    final Function callback = PluginUtilities.getCallbackFromHandle(
        CallbackHandle.fromRawHandle(
            UnifiedPush.prefs.getInt('notification_method')));
    debugPrint(callback.toString());
    debugPrint(CallbackHandle.fromRawHandle(
            UnifiedPush.prefs.getInt('notification_method'))
        .toRawHandle()
        .toString());
    assert(callback != null);

    //3.3. Invoke callback.
    bool ans = await callback(args);
    print(ans);
  });

  // 4. Alert plugin that the callback handler is ready for events.
  _backgroundChannel.invokeMethod('initialized');
}
