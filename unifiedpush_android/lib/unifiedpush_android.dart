import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:unifiedpush_platform_interface/unifiedpush_platform_interface.dart';

import 'constants.dart';

class UnifiedPushAndroid extends UnifiedPushPlatform {
  static void registerWith() {
    UnifiedPushPlatform.instance = UnifiedPushAndroid();
  }

  static const MethodChannel _channel = MethodChannel(PLUGIN_CHANNEL);

  static void Function(String endpoint, String instance)? _onNewEndpoint =
      (String e, String i) {};
  static void Function(String instance)? _onRegistrationFailed = (String i) {};
  static void Function(String instance)? _onUnregistered = (String i) {};
  static void Function(Uint8List message, String instance)? _onMessage =
      (Uint8List m, String i) {};

  @override
  Future<List<String>> getDistributors(List<String> features) async {
    return (await _channel.invokeMethod(
            PLUGIN_EVENT_GET_DISTRIBUTORS, [jsonEncode(features)]))
        .cast<String>();
  }

  @override
  Future<String> getDistributor() async {
    return await _channel.invokeMethod(PLUGIN_EVENT_GET_DISTRIBUTOR);
  }

  @override
  Future<void> saveDistributor(String distributor) async {
    await _channel.invokeMethod(PLUGIN_EVENT_SAVE_DISTRIBUTOR, [distributor]);
  }

  @override
  Future<void> registerApp(String instance, List<String> features) async {
    await _channel.invokeMethod(
        PLUGIN_EVENT_REGISTER_APP, [instance, jsonEncode(features)]);
  }

  @override
  Future<void> unregister(String instance) async {
    _onUnregistered?.call(instance);
    await _channel.invokeMethod(PLUGIN_EVENT_UNREGISTER, [instance]);
  }

  @override
  Future<void> initializeCallback({
    void Function(String endpoint, String instance)? onNewEndpoint,
    void Function(String instance)? onRegistrationFailed,
    void Function(String instance)? onUnregistered,
    void Function(Uint8List message, String instance)? onMessage,
  }) async {
    _onNewEndpoint = onNewEndpoint;
    _onRegistrationFailed = onRegistrationFailed;
    _onUnregistered = onUnregistered;
    _onMessage = onMessage;

    _channel.setMethodCallHandler(onMethodCall);
    debugPrint("initializeCallback finished");
  }

  static Future<void> onMethodCall(MethodCall call) async {
    // type inference will work here avoiding an explicit cast
    debugPrint(call.method);
    final instance = call.arguments["instance"] as String;
    switch (call.method) {
      case "onNewEndpoint":
        _onNewEndpoint?.call(call.arguments["endpoint"], instance);
        break;
      case "onRegistrationFailed":
        _onRegistrationFailed?.call(instance);
        break;
      case "onUnregistered":
        _onUnregistered?.call(instance);
        break;
      case "onMessage":
        _onMessage?.call(call.arguments["message"], instance);
        break;
    }
  }
}
