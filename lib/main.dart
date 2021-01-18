import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
      case "onUnregister":
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

  static Future<void> registerWithPopup(BuildContext inpContext) async {
    List<String> dist = await distributors;
    String selected;

    if (dist.length == 1) {
      selected = dist[0]; //use default distributor
    } else {
      selected = await showDialog<String>(
          context: inpContext,
          builder: (BuildContext context) => SimpleDialog(
                title: const Text('Select distributors'),
                children: dist
                    .map<Widget>((v) => ListTile(
                        onTap: () => Navigator.pop(context, v), title: Text(v)))
                    .toList(),
              ));
    }
    
    if (selected != null) {
    BuildContext loadingContext;
      try {
        showDialog(
          context: inpContext,
          barrierDismissible: false,
          builder: (BuildContext context) {
          loadingContext = context;
            return Dialog(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    new CircularProgressIndicator(),
                    Text("    Loading ..."),
                  ],
                ),
              ),
            );
          },
        );
        await register(selected);
      } on UPRegistrationException catch (e) {
        Scaffold.of(inpContext).showSnackBar(SnackBar(content: Text(e.cause)));
      }
      Navigator.pop(loadingContext);

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
      await _channel.invokeMethod('unRegister');
    } on PlatformException catch (e) {
      debugPrint("unregister failed ${e.message}");
    }
    endpoint = "";
  }
}
