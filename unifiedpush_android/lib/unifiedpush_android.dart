import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unifiedpush_platform_interface/unifiedpush_platform_interface.dart';

import 'constants.dart';

class UnifiedPushAndroid extends UnifiedPushPlatform {
  static void registerWith() {
    UnifiedPushPlatform.instance = UnifiedPushAndroid();
  }
  
  static SharedPreferences? _prefs;
  static Future<SharedPreferences?> getSharedPreferences() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    return _prefs;
  }

  static const MethodChannel _channel = MethodChannel(PLUGIN_CHANNEL);

  static void Function(String endpoint, String instance)? _onNewEndpoint = (String e, String i) {};
  static void Function(String instance)? _onRegistrationFailed = (String i) {};
  static void Function(String instance)? _onUnregistered = (String i) {};
  static void Function(String message, String instance)? _onMessage = (String m, String i) {};

  @override
  Future<List<String>> getDistributors() async {
    return (await _channel.invokeMethod(PLUGIN_EVENT_GET_DISTRIBUTORS))
        .cast<String>();
  }

  @override
  Future<String> getDistributor() async {
    return await _channel.invokeMethod(PLUGIN_EVENT_GET_DISTRIBUTOR);
  }

  @override
  Future<void> saveDistributor(String distributor) async {
    await _channel.invokeMethod(PLUGIN_EVENT_SAVE_DISTRIBUTOR, [distributor]);
  }

  @override
  Future<void> registerApp(String instance) async {
    await _channel.invokeMethod(PLUGIN_EVENT_REGISTER_APP, [instance]);
  }
  
  @override
  Future<void> unregister(String instance) async {
    await _channel.invokeMethod(PLUGIN_EVENT_UNREGISTER, [instance]);
  }

  @override
  Future<void> initializeCallback({
    void Function(String endpoint, String instance)? onNewEndpoint,
    void Function(String instance)? onRegistrationFailed,
    void Function(String instance)? onUnregistered,
    void Function(String message, String instance)? onMessage,
  }) async {
    _onNewEndpoint = onNewEndpoint;
    _onRegistrationFailed = onRegistrationFailed;
    _onUnregistered = onUnregistered;
    _onMessage = onMessage;

    _channel.setMethodCallHandler(onMethodCall);
    debugPrint("initializeCallback finished");
  }

  @override
  Future<Map<String, dynamic>> getAllNativeSharedPrefs() async {
    return Map<String, dynamic>.from(await _channel.invokeMethod(PLUGIN_EVENT_GET_ALL_NATIVE_SHARED_PREFS));
  }

  static Future<void> onMethodCall(MethodCall call) async {
    // type inference will work here avoiding an explicit cast
    debugPrint(call.method);
    final instance = call.arguments["instance"] as String;
    switch (call.method) {
      case "onNewEndpoint":
        _onNewEndpoint?.call(call.arguments["endpoint"], instance);
        break;
      case "onRegistrationFailed":
        _onRegistrationFailed?.call(instance);
        break;
      case "onUnregistered":
        _onUnregistered?.call(instance);
        break;
      case "onMessage":
        _onMessage?.call(call.arguments["message"], instance);
        break;
    }
  }
}
