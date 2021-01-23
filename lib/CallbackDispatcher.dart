import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unifiedpush/Constants.dart';
import 'main.dart';

void callbackDispatcher() {

  const MethodChannel _backgroundChannel = MethodChannel(CALLBACK_CHANNEL);

  WidgetsFlutterBinding.ensureInitialized();

  _backgroundChannel.setMethodCallHandler((MethodCall call) async {
    debugPrint("callbackDispatcher: MethodCallHandler");
    final arg = call.arguments as String;

    if (UnifiedPush.prefs == null) {
      UnifiedPush.prefs = await SharedPreferences.getInstance();
      debugPrint("callbackDispatcher: new Preferences");
    }

    var rawHandle;
    debugPrint("callbackDispatcher: call.method: ${call.method}");
    switch(call.method){
      case CALLBACK_EVENT_NEW_ENDPOINT : {
        rawHandle = UnifiedPush.prefs.getInt(PREF_ON_NEW_ENDPOINT);
        break;
      }
      case CALLBACK_EVENT_MESSAGE : {
        rawHandle = UnifiedPush.prefs.getInt(PREF_ON_MESSAGE);
        break;
      }
      case CALLBACK_EVENT_UNREGISTERED : {
        rawHandle = UnifiedPush.prefs.getInt(PREF_ON_UNREGISTERED);
        break;
      }
      default : {
        return;
      }
    }

    final Function callback = PluginUtilities.getCallbackFromHandle(
        CallbackHandle.fromRawHandle(rawHandle)
    );
    assert(callback != null);

    await callback(arg);
  });

  _backgroundChannel.invokeMethod(CALLBACK_EVENT_INITIALIZED);
}
