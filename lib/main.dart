import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Exceptions.dart';
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

  static RegistrationReply _registrationReply = RegistrationReply.none;

  static bool get registered {
    return _registered;
  }

  static String get endpoint {
    return _endpoint;
  }

  static set endpoint(String ndpoint) {
    prefs.setString('endpoint', ndpoint ?? "");
    _endpoint = ndpoint;
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
        _registrationReply = RegistrationReply.newRegistration;
        _onEndpointMethod();
        break;
      case "onRegistrationRefused":
        _registrationReply = RegistrationReply.refused;
        break;
      case "onRegistrationFailed":
        _registrationReply = RegistrationReply.failed;
        break;
      case "onUnregistered":
        print("unregister");
        endpoint = "";
        break;
    }
  }

  static Future<List<String>> get distributors async {
    try {
      final List<String> result =
          (await _channel.invokeMethod('getDistributors')).cast<String>();
      return result;
    } on PlatformException catch (e) {
      debugPrint("Failed to get distributors: '${e.message}'.");
      return null;
    }
  }

  static Future<void> register(String providerName) async {
    try {
      await _channel.invokeMethod('register', [providerName]);
    } on PlatformException catch (e) {
      throw UPRegistrationException("Unknown AAAA ${e.message}");
    }

    int n = 16;
    int interval = 250;

    while (_registrationReply == RegistrationReply.none) {
      print(_registrationReply);
      await Future.delayed(Duration(milliseconds: interval));
      if (n-- < 0) {
        _registrationReply = RegistrationReply.timeout;
      }
    }
    var tmpRegReply = _registrationReply;
    _registrationReply = RegistrationReply.none;

    switch (tmpRegReply) {
      case RegistrationReply.failed:
        throw UPRegistrationException("failed");
        break;
      case RegistrationReply.refused:
        throw UPRegistrationException("refused");
        break;
      case RegistrationReply.timeout:
        throw UPRegistrationException("timeout");
        break;
      case RegistrationReply.newRegistration:
        break;
      default:
        print("default in register function shouldn't happen");
        print(_registrationReply);
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
