import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CallbackDispatcher.dart';

typedef OnUpdate = void Function();
typedef OnMessage = void Function(String message);

enum RegistrationReply { none, newRegistration, failed, refused, timeout }

class UnifiedPush {
  static MethodChannel _channel =
      MethodChannel('org.unifiedpush.flutter.connector.channel');

  static String _endpoint;
  static OnUpdate _onNewEndpoint = () {};
  static OnUpdate _onRegistrationRefused = () {};
  static OnUpdate _onRegistrationFailed = () {};
  static OnUpdate _onUnregistered = () {};
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
    _onNewEndpoint();
  }

  static Future<void> initialize(OnUpdate onNewEndpoint, OnUpdate onRegistrationFailed,
      OnUpdate onRegistrationRefused, OnUpdate onUnregistered,
      OnMessage onMessage) async {
    _onNewEndpoint = onNewEndpoint;
    _onRegistrationFailed = onRegistrationFailed;
    _onRegistrationRefused = onRegistrationRefused;
    _onUnregistered = onUnregistered;

    _channel.setMethodCallHandler(onMethodCall);

    prefs = await SharedPreferences.getInstance();
    endpoint = prefs.getString('endpoint') ?? "";
    prefs.setInt("notification_method",
        PluginUtilities.getCallbackHandle(onMessage).toRawHandle());

    final callback = PluginUtilities.getCallbackHandle(callbackDispatcher);
    await _channel
        .invokeMethod('initializeService', <dynamic>[callback.toRawHandle()]);
    debugPrint(PluginUtilities.getCallbackHandle(onMessage)
        .toRawHandle()
        .toString());

    _onNewEndpoint();
  }

  static Future<void> onMethodCall(MethodCall call) async {
    // type inference will work here avoiding an explicit cast
    debugPrint(call.method);
    switch (call.method) {
      case "onNewEndpoint":
        endpoint = call.arguments;
        _onNewEndpoint();
        break;
      case "onRegistrationRefused":
        _onRegistrationRefused();
        break;
      case "onRegistrationFailed":
        _onRegistrationFailed();
        break;
      case "onUnregistered":
        print("unregistered");
        _onUnregistered();
        endpoint = "";
        break;
    }
  }
  
  static Future<void> unregister() async {
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
