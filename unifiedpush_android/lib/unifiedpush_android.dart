import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unifiedpush_platform_interface/unifiedpush_platform_interface.dart';

import 'CallbackDispatcher.dart';
import 'constants.dart';


class UnifiedPushAndroid extends UnifiedPushPlatform {
  static void registerWith() {
    UnifiedPushPlatform.instance = UnifiedPushAndroid();
  }
  
  static SharedPreferences? _prefs;
  static get prefs async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
    }
    return _prefs;
  }

  static const MethodChannel _channel = MethodChannel(PLUGIN_CHANNEL);

  static void Function(String token, String endpoint)? _onNewEndpoint = (String _, String e) {};
  static void Function(String token, String? message)? _onRegistrationRefused = (String _, String? r) {};
  static void Function(String token, String? message)? _onRegistrationFailed = (String _, String? r) {};
  static void Function(String token)? _onUnregistered = (String _) {};
  static void Function(String token, String message)? _onMessage = (String _, String m) {};

  @override
  Future<List<String>> getDistributors() async {
    return (await _channel.invokeMethod(PLUGIN_EVENT_GET_DISTRIBUTORS))
        .cast<String>();
  }

  @override
  Future<void> registerApp(String distributor, String token) async {
    await _channel.invokeMethod(PLUGIN_EVENT_REGISTER_APP, [distributor, token]);
  }
  
  @override
  Future<void> unregister(String token) async {
    await _channel.invokeMethod(PLUGIN_EVENT_UNREGISTER, [token]);
  }

  @override
  Future<void> initializeCallback({
    void Function(String token, String endpoint)? onNewEndpoint,
    void Function(String token, String? message)? onRegistrationFailed,
    void Function(String token, String? message)? onRegistrationRefused,
    void Function(String token)? onUnregistered,
    void Function(String token, String message)? onMessage,
  }) async {
    _onNewEndpoint = onNewEndpoint;
    _onRegistrationFailed = onRegistrationFailed;
    _onRegistrationRefused = onRegistrationRefused;
    _onUnregistered = onUnregistered;
    _onMessage = onMessage;

    _channel.setMethodCallHandler(onMethodCall);
    debugPrint("initializeCallback finished");
  }

  @override
  Future<void> initializeBackgroundCallback({
    void Function(dynamic args)? staticOnNewEndpoint,
    void Function(dynamic args)? staticOnUnregistered,
    void Function(dynamic args)? staticOnMessage,
  }) async {
    if (staticOnNewEndpoint != null) {
      prefs.setInt(
          PREF_ON_NEW_ENDPOINT,
          PluginUtilities.getCallbackHandle(staticOnNewEndpoint)
                  ?.toRawHandle() ??
              0);
    }
    if (staticOnUnregistered != null) {
      prefs.setInt(
          PREF_ON_UNREGISTERED,
          PluginUtilities.getCallbackHandle(staticOnUnregistered)
                  ?.toRawHandle() ??
              0);
    }
    if (staticOnMessage != null) {
      prefs.setInt(
          PREF_ON_MESSAGE,
          PluginUtilities.getCallbackHandle(staticOnMessage)?.toRawHandle() ??
              0);
    }

    var callbackRawHandle = null;
    if (staticOnNewEndpoint != null || staticOnUnregistered != null || staticOnMessage != null) {
      final callback = PluginUtilities.getCallbackHandle(callbackDispatcher);
      callbackRawHandle = callback?.toRawHandle();
    }

    await _channel.invokeMethod(
        PLUGIN_EVENT_INITIALIZE_BG_CALLBACK, <dynamic>[callbackRawHandle]);
    debugPrint("initializeBackgroundCallback finished");
  }

  @override
  Future<Map<String, dynamic>> getAllNativeSharedPrefs() async {
    return Map<String, dynamic>.from(await _channel.invokeMethod(PLUGIN_EVENT_GET_ALL_NATIVE_SHARED_PREFS));
  }

  static Future<void> onMethodCall(MethodCall call) async {
    // type inference will work here avoiding an explicit cast
    debugPrint(call.method);
    final token = call.arguments["token"] as String;
    switch (call.method) {
      case "onNewEndpoint":
        _onNewEndpoint?.call(token, call.arguments["endpoint"]);
        break;
      case "onRegistrationRefused":
        _onRegistrationRefused?.call(token, call.arguments["message"]);
        break;
      case "onRegistrationFailed":
        _onRegistrationFailed?.call(token, call.arguments["message"]);
        break;
      case "onUnregistered":
        _onUnregistered?.call(token);
        break;
      case "onMessage":
        _onMessage?.call(token, call.arguments["message"]);
        break;
    }
  }
}
