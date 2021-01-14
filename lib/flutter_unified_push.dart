import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/services.dart';

import 'CallbackDispatcher.dart';

typedef OnUpdate = void Function();
typedef OnNotification = void Function(
    String title, String body, int importance);


class FlutterUnifiedPush {
  static MethodChannel _channel = MethodChannel('flutter_unified_push.method.channel');
  static OnNotification onNotificationMethod;

  static String _endpoint;
  static OnUpdate onEndpointMethod;
  static bool _registered = false;
  static SharedPreferences prefs;

  static bool get registered {
    return _registered;
  }

   static String get endpoint {
 //   try {
 //     _endpoint = prefs?.getString('endpoint') ?? "";
 //   } on TypeError {
 //     _endpoint = "";
 //   }
    return _endpoint;
  }

  static set endpoint(String ndpoint) {
    prefs.setString('endpoint', ndpoint ?? "");
    _endpoint = ndpoint;
    _registered = _endpoint.isNotEmpty;
    onEndpointMethod();
  }


  static Future<bool> initialize(OnUpdate onEndpoint) async {
    onEndpointMethod = onEndpoint;
    _channel.setMethodCallHandler(onMethodCall);
    prefs = await SharedPreferences.getInstance();
endpoint = prefs.getString('endpoint') ?? "";

    final callback = PluginUtilities.getCallbackHandle(callbackDispatcher);
    await _channel.invokeMethod('FlutterUnifiedPushPlugin.initializeService',
        <dynamic>[callback.toRawHandle()]);
    onEndpointMethod();
  }



  static Future<void> onMethodCall(MethodCall call) async {
    // type inference will work here avoiding an explicit cast
    debugPrint(call.arguments.toString());
    print("aa");

    switch (call.method) {
      case "onMessage":
        debugPrint("onMessage");
        var message = decodeUri(call.arguments["message"]);
        print(message);
        await onNotificationMethod(message["title"] ?? "title not available",
            message["message"] ?? "no message?", int.parse(message["priority"]??"8"));
        print("done awaiting");
        break;
      case "onNewEndpoint":
        endpoint = call.arguments["endpoint"];
        onEndpointMethod();
        break;
      case "onUnregister":
        print("unreg");
        endpoint = "";
        break;
    }
  }

  static Future<List<String>> get distributors async {
    try {
      final List<String> result =
      (await _channel.invokeMethod('FlutterUnifiedPushPlugin.getDistributors')).cast<String>();
      return result;
    } on PlatformException catch (e) {
      //ans = "Failed to get dist: '${e.message}'.";
      //throw e;
      return null;
    }
  }

  static Future<String> register(String providerName) async {
    try {
      return await _channel.invokeMethod('FlutterUnifiedPushPlugin.register', [ providerName]);
    } on PlatformException catch (e) {
      //ans = "Failed to get token: '${e.message}'.";
      return null;
    }
  }

  static Future<void> unRegister() async {
    try {
      return await _channel.invokeMethod('FlutterUnifiedPushPlugin.unRegister');
    } on PlatformException catch (e) {
      //ans = "Failed to get token: '${e.message}'.";
    }
  }

  static Map<String, String> decodeUri(String message) {
    var uri = Uri.decodeComponent(message).split("&");
    Map<String, String> decoded = {};
    uri.forEach((String i) {
      try {
        decoded[i.split("=")[0]] = i.split("=")[1];
        print(i);
      } on Exception {}
    });
    return decoded;
  }
}
