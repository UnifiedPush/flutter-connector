import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef OnUpdate = void Function();
typedef OnNotification = void Function(
    String title, String body, int importance);

class FlutterUnifiedPush {
  String _endpoint;
  OnUpdate onEndpointMethod;
  OnNotification onNotificationMethod;
  bool _registered = false;
  SharedPreferences prefs;

  bool get registered {
    return _registered;
  }

  String get endpoint {
    try {
      _endpoint = prefs.getString('endpoint') ?? "";
    } on TypeError {
      _endpoint = "";
    }
    return _endpoint;
  }

  set endpoint(String ndpoint) {
    prefs.setString('endpoint', ndpoint ?? "");
    _endpoint = ndpoint;
    _registered = _endpoint.isNotEmpty;
    onEndpointMethod();
  }

  FlutterUnifiedPush(this.onEndpointMethod, this.onNotificationMethod) {
    _channel.setMethodCallHandler(onMethodCall);
    main();
  }

  void main() async {
    prefs = await SharedPreferences.getInstance();
    onEndpointMethod();
  }

  MethodChannel _channel = MethodChannel('flutter_unified_push.method.channel');

  Future<void> onMethodCall(MethodCall call) async {
    // type inference will work here avoiding an explicit cast
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
        debugPrint(call.arguments.toString());
        endpoint = call.arguments["endpoint"];
        onEndpointMethod();
        break;
      case "onUnregister":
        print("unreg");
        endpoint = "";
        break;
    }
  }

  Future<List<String>> get distributors async {
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

  Future<String> register(String providerName) async {
    try {
      return await _channel.invokeMethod('register', {"name": providerName});
    } on PlatformException catch (e) {
      //ans = "Failed to get token: '${e.message}'.";
      return null;
    }
  }

  Future<void> unRegister() async {
    try {
      return await _channel.invokeMethod('unRegister');
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
