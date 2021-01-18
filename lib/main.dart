import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CallbackDispatcher.dart';

typedef OnUpdate = void Function();
typedef OnNotification = void Function(String payload);

enum RegistrationReply { none, newRegistration, failed, refused, timeout }

class UnifiedPush {
  static MethodChannel _channel =
      MethodChannel('org.unifiedpush.flutter.connector.channel');

  static String _endpoint;
  static OnUpdate _onEndpointMethod = () {};
  static bool _registered = false;
  static SharedPreferences prefs;


  static bool get registered {
    return _registered;
  }

  static String get endpoint {
    return _endpoint;
  }

  static set endpoint(String endpoint) {
    prefs.setString('endpoint', endpoint ?? "");
    _endpoint = endpoint;
    _registered = _endpoint.isNotEmpty;
    _onEndpointMethod();
  }

  static Future<void> initialize(
      OnUpdate onEndpoint, OnNotification onNotification) async {
    _onEndpointMethod = onEndpoint;

    _channel.setMethodCallHandler(onMethodCall);

    prefs = await SharedPreferences.getInstance();
    endpoint = prefs.getString('endpoint') ?? "";
    prefs.setInt("notification_method",
        PluginUtilities.getCallbackHandle(onNotification).toRawHandle());

    final callback = PluginUtilities.getCallbackHandle(callbackDispatcher);
    await _channel
        .invokeMethod('initializeService', <dynamic>[callback.toRawHandle()]);
    debugPrint(PluginUtilities.getCallbackHandle(onNotification)
        .toRawHandle()
        .toString());

    _onEndpointMethod();
  }

  static Future<void> onMethodCall(MethodCall call) async {
    // type inference will work here avoiding an explicit cast
    debugPrint(call.method);
    switch (call.method) {
      case "onNewEndpoint":
        endpoint = call.arguments;
        _onEndpointMethod();
        break;
      case "onRegistrationRefused":
        break;
      case "onRegistrationFailed":
        break;
      case "onUnregistered":
        print("unregister");
        endpoint = "";
        break;
    }
  }
  
  static Future<void> unRegister() async {
    try {
      await _channel.invokeMethod('unregister');
    } on PlatformException catch (e) {
      debugPrint("unregister failed ${e.message}");
    }
    endpoint = "";
  }

  static Future<void> registerAppWithDialog() async {
    try{
      await _channel.invokeMethod("registerAppWithDialog");
    } on PlatformException catch (e) {
      debugPrint("registerAppWithDialog failed ${e.message}");
    }
  }
}
