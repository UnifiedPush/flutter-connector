import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

void callbackDispatcher() {

   // 1. Initialize MethodChannel used to communicate with the platform portion of the plugin.
   const MethodChannel _backgroundChannel =
   MethodChannel('flutter_unified_push.method.background_channel');
  
   // 2. Setup internal state needed for MethodChannels.
   WidgetsFlutterBinding.ensureInitialized();
  
   // 3. Listen for background events from the platform portion of the plugin.
   _backgroundChannel.setMethodCallHandler((MethodCall call) async {
     final args = call.arguments as String;
 print(args); 
print("arg");
//     // 3.1. Retrieve callback instance for handle.
//     final Function callback = PluginUtilities.getCallbackFromHandle(
//         CallbackHandle.fromRawHandle(args[0]));
//     assert(callback != null);
  
     // 3.3. Invoke callback.
     //callback(triggeringGeofences, triggeringLocation, event);
   });
  
   // 4. Alert plugin that the callback handler is ready for events.
   _backgroundChannel.invokeMethod('FlutterUnifiedPushService.initialized');
}
