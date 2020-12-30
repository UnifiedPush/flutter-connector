import 'dart:async';

import 'package:flutter/services.dart';

class FlutterUnifiedPush {
  static const MethodChannel _channel =
      const MethodChannel('flutter_unified_push');

  static Future<void> initiateHandling() async {
    _channel.setMethodCallHandler(onMethodCall);
  }

  static Future<void> onMethodCall(MethodCall call) async {
    // type inference will work here avoiding an explicit cast
    print(call.method);
    switch (call.method) {
      case "onMessage":
        print("onMessage");
        break;
      case "onNewEndpoint":
        print("New Endpoint");
        print(call.arguments.toString());
        break;
    }
  }

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<List<String>> get distributors async {
    try {
      final List<String> result =
          (await _channel.invokeMethod('getDistributors')).cast<String>();
      return result;
    } on PlatformException catch (e) {
      //ans = "Failed to get dist: '${e.message}'.";
      //throw e;
      return null;
    }
  }

  static Future<String> register(String a) async {
    try {
      return await _channel.invokeMethod('register', {"name": a});
    } on PlatformException catch (e) {
      //ans = "Failed to get token: '${e.message}'.";
      return null;
    }
  }
}
