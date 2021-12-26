import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:unifiedpush_android/unifiedpush_android.dart';

import 'constants.dart';

void callbackDispatcher() {
  const MethodChannel _backgroundChannel = MethodChannel(CALLBACK_CHANNEL);

  WidgetsFlutterBinding.ensureInitialized();

  _backgroundChannel.setMethodCallHandler((MethodCall call) async {
    debugPrint("callbackDispatcher: MethodCallHandler");
    final arg = call.arguments;

    var rawHandle;
    debugPrint("callbackDispatcher: call.method: ${call.method}");
    switch (call.method) {
      case CALLBACK_EVENT_NEW_ENDPOINT:
        {
          rawHandle = UnifiedPushAndroid.prefs.getInt(PREF_ON_NEW_ENDPOINT);
          break;
        }
      case CALLBACK_EVENT_MESSAGE:
        {
          rawHandle = UnifiedPushAndroid.prefs.getInt(PREF_ON_MESSAGE);
          break;
        }
      case CALLBACK_EVENT_UNREGISTERED:
        {
          rawHandle = UnifiedPushAndroid.prefs.getInt(PREF_ON_UNREGISTERED);
          break;
        }
      default:
        {
          return;
        }
    }

    final callback = PluginUtilities.getCallbackFromHandle(
        CallbackHandle.fromRawHandle(rawHandle));
    assert(callback != null);

    await callback?.call(arg);
  });

  _backgroundChannel.invokeMethod(CALLBACK_EVENT_INITIALIZED);
}
