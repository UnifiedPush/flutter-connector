import 'dart:async';

import 'package:flutter/services.dart';

typedef OnUpdate = void Function();

class FlutterUnifiedPush {
  String endpoint;
  OnUpdate onEndpointMethod;

  FlutterUnifiedPush(this.endpoint, this.onEndpointMethod) {
    _channel.setMethodCallHandler(onMethodCall);
  }



  FlutterUnifiedPush.first(this.onEndpointMethod){
    _channel.setMethodCallHandler(onMethodCall);
  }



  MethodChannel _channel =
  MethodChannel('flutter_unified_push.method.channel');

  Future<void> onMethodCall(MethodCall call) async {
    // type inference will work here avoiding an explicit cast
    print(call.method);
    switch (call.method) {
      case "onMessage":
        print("onMessage");
        break;
      case "onNewEndpoint":
        print(call.arguments.toString());
        endpoint = call.arguments["endpoint"];
        onEndpointMethod();
        break;
      case "onUnregister":
        endpoint = "";
        onEndpointMethod();
        break;
    }
  }

  Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
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

  Future<String> register(String a) async {
    try {
      return await _channel.invokeMethod('register', {"name": a});
    } on PlatformException catch (e) {
      //ans = "Failed to get token: '${e.message}'.";
      return null;
    }
  }

  Future<void> unRegister(String token) async {
    try {
      return await _channel.invokeMethod('unRegister', {"token": token});
    } on PlatformException catch (e) {
      //ans = "Failed to get token: '${e.message}'.";
    }
  }
}
