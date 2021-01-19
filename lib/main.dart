import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum RegistrationReply { none, newRegistration, failed, refused, timeout }

class UnifiedPush {
  static MethodChannel _channel =
      MethodChannel('org.unifiedpush.flutter.connector.channel');


  static void Function(String endpoint) _onNewEndpoint = (String _) {};
  static void Function() _onRegistrationRefused = () {};
  static void Function() _onRegistrationFailed = () {};
  static void Function() _onUnregistered = () {};
  static void Function(String message) _onMessage = (String _) {};

  static Future<void> initialize(
      void Function(String endpoint) onNewEndpoint,
      void Function() onRegistrationFailed,
      void Function() onRegistrationRefused,
      void Function() onUnregistered,
      void Function(String message) onMessage
      ) async {
    _onNewEndpoint = onNewEndpoint;
    _onRegistrationFailed = onRegistrationFailed;
    _onRegistrationRefused = onRegistrationRefused;
    _onUnregistered = onUnregistered;
    _onMessage = onMessage;

    _channel.setMethodCallHandler(onMethodCall);
  }

  static Future<void> onMethodCall(MethodCall call) async {
    // type inference will work here avoiding an explicit cast
    debugPrint(call.method);
    switch (call.method) {
      case "onNewEndpoint":
        _onNewEndpoint(call.arguments);
        break;
      case "onRegistrationRefused":
        _onRegistrationRefused();
        break;
      case "onRegistrationFailed":
        _onRegistrationFailed();
        break;
      case "onUnregistered":
        _onUnregistered();
        break;
      case "onMessage":
        _onMessage(call.arguments);
        break;
    }
  }
  
  static Future<void> unregister() async {
    try {
      await _channel.invokeMethod('unregister');
    } on PlatformException catch (e) {
      debugPrint("unregister failed ${e.message}");
    }
  }

  static Future<void> registerAppWithDialog() async {
    try{
      await _channel.invokeMethod("registerAppWithDialog");
    } on PlatformException catch (e) {
      debugPrint("registerAppWithDialog failed ${e.message}");
    }
  }
}
