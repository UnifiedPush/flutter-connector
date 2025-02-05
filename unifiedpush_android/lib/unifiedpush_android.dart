import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:unifiedpush_platform_interface/data/failed_reason.dart';
import 'package:unifiedpush_platform_interface/data/public_key_set.dart';
import 'package:unifiedpush_platform_interface/data/push_endpoint.dart';
import 'package:unifiedpush_platform_interface/data/push_message.dart';
import 'package:unifiedpush_platform_interface/unifiedpush_platform_interface.dart';

import 'constants.dart';

class UnifiedPushAndroid extends UnifiedPushPlatform {
  static void registerWith() {
    UnifiedPushPlatform.instance = UnifiedPushAndroid();
  }

  static const MethodChannel _channel = MethodChannel(pluginChannel);

  static void Function(PushEndpoint endpoint, String instance)? _onNewEndpoint =
      (PushEndpoint e, String i) {};
  static void Function(FailedReason reason, String instance)? _onRegistrationFailed = (FailedReason r, String i) {};
  static void Function(String instance)? _onUnregistered = (String i) {};
  static void Function(PushMessage message, String instance)? _onMessage =
      (PushMessage m, String i) {};

  @override
  Future<List<String>> getDistributors(List<String> features) async {
    return (await _channel
            .invokeMethod(pluginEventGetDistributors, [jsonEncode(features)]))
        .cast<String>();
  }

  @override
  Future<String?> getDistributor() async {
    return await _channel.invokeMethod(pluginEventGetDistributor);
  }

  @override
  Future<void> saveDistributor(String distributor) async {
    await _channel.invokeMethod(pluginEventSaveDistributor, [distributor]);
  }

  @override
  Future<void> registerApp(String instance, List<String> features) async {
    await _channel.invokeMethod(
        pluginEventRegisterApplication, [instance, jsonEncode(features)]);
  }

  @override
  Future<void> unregister(String instance) async {
    await _channel.invokeMethod(pluginEventUnregister, [instance]);
  }

  @override
  Future<void> initializeCallback({
    void Function(PushEndpoint endpoint, String instance)? onNewEndpoint,
    void Function(FailedReason reason, String instance)? onRegistrationFailed,
    void Function(String instance)? onUnregistered,
    void Function(PushMessage message, String instance)? onMessage,
  }) async {
    _onNewEndpoint = onNewEndpoint;
    _onRegistrationFailed = onRegistrationFailed;
    _onUnregistered = onUnregistered;
    _onMessage = onMessage;

    _channel.setMethodCallHandler(onMethodCall);
    await _channel.invokeMethod(pluginEventInitialized, []);
    debugPrint("initializeCallback finished");
  }

  static Future<void> onMethodCall(MethodCall call) async {
    final instance = call.arguments[pluginArgInstance] as String;
    switch (call.method) {
      case "onNewEndpoint":
        final url = call.arguments[pluginArgEndpointUrl] as String;
        final pubKey = call.arguments[pluginArgEndpointKeyPubKey] as String?;
        final auth = call.arguments[pluginArgEndpointKeyAuth] as String?;
        PublicKeySet? pubKeySet;
        if (pubKey != null && auth != null) {
          pubKeySet = PublicKeySet(pubKey, auth);
        }
        _onNewEndpoint?.call(PushEndpoint(url, pubKeySet), instance);
        break;
      case "onRegistrationFailed":
        _onRegistrationFailed?.call(call.arguments[pluginArgReason], instance);
        break;
      case "onUnregistered":
        _onUnregistered?.call(instance);
        break;
      case "onMessage":
        final content = call.arguments[pluginArgMessageContent] as Uint8List;
        final decrypted = call.arguments[pluginArgMessageDecrypted] as bool;
        _onMessage?.call(PushMessage(content, decrypted), instance);
        break;
    }
  }
}
