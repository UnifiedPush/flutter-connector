import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Exceptions.dart';
import 'CallbackDispatcher.dart';

typedef OnUpdate = void Function();
typedef OnNotification = void Function(
    String title, String body, int importance);

enum RegistrationReply { none, newRegistration, failed, refused, timeout }

class FlutterUnifiedPush {
  static MethodChannel _channel =
      MethodChannel('org.unifiedpush.flutter.connector.channel');

  static String _endpoint;
  static OnUpdate onEndpointMethod;
  static bool _registered = false;
  static SharedPreferences prefs;

  static RegistrationReply _registrationReply = RegistrationReply.none;

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

  static Future<void> initialize(
      OnUpdate onEndpoint, OnNotification onNotification) async {
    onEndpointMethod = onEndpoint;
    _channel.setMethodCallHandler(onMethodCall);
    prefs = await SharedPreferences.getInstance();
    endpoint = prefs.getString('endpoint') ?? "";

    final callback = PluginUtilities.getCallbackHandle(callbackDispatcher);
    await _channel.invokeMethod('initializeService',
        <dynamic>[callback.toRawHandle()]);

    prefs.setInt("notification_method",
        PluginUtilities.getCallbackHandle(onNotification).toRawHandle());
    debugPrint(PluginUtilities.getCallbackHandle(onNotification)
        .toRawHandle()
        .toString());
    onEndpointMethod();
  }

  static Future<void> onMethodCall(MethodCall call) async {
    // type inference will work here avoiding an explicit cast
    debugPrint(call.arguments.toString());
    print("aa");
    debugPrint(call.method);
    switch (call.method) {
      case "onNewEndpoint":
        endpoint = call.arguments;
        _registrationReply = RegistrationReply.newRegistration;
        print("set");

        onEndpointMethod();
        break;
      case "onRegistrationRefused":
        _registrationReply = RegistrationReply.refused;
        break;
      case "onRegistrationFailed":
        _registrationReply = RegistrationReply.failed;
        break;
      case "onUnregister":
        print("unreg");
        endpoint = "";
        break;
    }
  }

  static Future<List<String>> get distributors async {
    try {
      final List<String> result = (await _channel
              .invokeMethod('getDistributors'))
          .cast<String>();
      return result;
    } on PlatformException catch (e) {
      debugPrint("Failed to get dist: '${e.message}'.");
      //throw e;
      return null;
    }
  }

  static Future<void> register(String providerName) async {
    try {
      await _channel
          .invokeMethod('register', [providerName]);
    } on PlatformException catch (e) {
      //ans = "Failed to get token: '${e.message}'.";
      throw RegistrationException("Unknown AAAA ${e.message}");
    }

    int n = 50;
    int interval = 200;

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
        throw RegistrationException("failed");
        break;
      case RegistrationReply.refused:
        throw RegistrationException("refused");
        break;
      case RegistrationReply.timeout:
        throw RegistrationException("timeout");
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
      await _channel.invokeMethod('unRegister');
    } on PlatformException catch (e) {
//ans = "Failed to get token: '${e.message}'.";
      debugPrint("unregister failed ${e.message}");
      //TODO
    }
    endpoint = "";
  }
}
