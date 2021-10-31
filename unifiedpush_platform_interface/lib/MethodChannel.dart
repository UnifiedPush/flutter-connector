import 'package:flutter/foundation.dart';
import 'package:unifiedpush_platform_interface/unifiedpush_platform_interface.dart';
import 'dart:ui';

import 'package:flutter/services.dart';

//TODO remove unused consts
const PLUGIN_EVENT_INITIALIZE_CALLBACK = "initializeCallback";
const PLUGIN_EVENT_REGISTER_APP_WITH_DIALOG = "registerAppWithDialog";
const PLUGIN_EVENT_GET_DISTRIBUTORS = "getDistributors";
const PLUGIN_EVENT_GET_DISTRIBUTOR = "getDistributor";
const PLUGIN_EVENT_SAVE_DISTRIBUTOR = "saveDistributor";
const PLUGIN_EVENT_REGISTER_APP = "registerApp";
const PLUGIN_EVENT_UNREGISTER = "unregister";
const PLUGIN_CHANNEL = "org.unifiedpush.flutter.connector.PLUGIN_CHANNEL";

const CALLBACK_EVENT_MESSAGE = "message";
const CALLBACK_EVENT_NEW_ENDPOINT = "new_endpoint";
const CALLBACK_EVENT_UNREGISTERED = "unregistered";
const CALLBACK_EVENT_INITIALIZED = "initialized";
const CALLBACK_DISPATCHER_HANDLE_KEY = "callback_dispatch_handler";
const CALLBACK_CHANNEL = "org.unifiedpush.flutter.connector.CALLBACK_CHANNEL";

const SHARED_PREFERENCES_KEY = "flutter-connector_plugin_cache";

class UnifiedPushMethodChannel extends UnifiedPushPlatform {
  //static UnifiedPushMethodChannel instance = UnifiedPushMethodChannel();

  //static void registerWith() {
  //  UnifiedPushPlatform.instance = instance;
  //}

  static MethodChannel _channel = MethodChannel(PLUGIN_CHANNEL);

  /// Call handler
  Future<void> onMethodCall(MethodCall call) async {
    // type inference will work here avoiding an explicit cast
    debugPrint(call.method);
    final instance = call.arguments["instance"];
    switch (call.method) {
      case "onNewEndpoint":
        onNewEndpoint(call.arguments["endpoint"], instance);
        break;
      case "onRegistrationRefused":
        onRegistrationRefused(instance);
        break;
      case "onRegistrationFailed":
        onRegistrationFailed(instance);
        break;
      case "onUnregistered":
        onUnregistered(instance);
        break;
      case "onMessage":
        onMessage(call.arguments["message"], instance);
        break;
    }
  }

  @override
  Future<void> initCallback(Function()? callbackDispatcher) async {
    _channel.setMethodCallHandler(onMethodCall);

    if (callbackDispatcher != null) {
      final callback = PluginUtilities.getCallbackHandle(callbackDispatcher);
      await _channel.invokeMethod(
          PLUGIN_EVENT_INITIALIZE_CALLBACK, <dynamic>[callback?.toRawHandle()]);
    }
  }

  @override
  Future<List<String>> getDistributors() async {
    return (await _channel.invokeMethod(PLUGIN_EVENT_GET_DISTRIBUTORS))
        .cast<String>();
  }

  @override
  Future<String> get distributor async =>
      (await _channel.invokeMethod(PLUGIN_EVENT_GET_DISTRIBUTOR)) as String;

  @override
  Future<void> saveDistributor(String dist) =>
      _channel.invokeMethod(PLUGIN_EVENT_SAVE_DISTRIBUTOR, [dist]);

  @override
  Future<void> register(String instance) =>
      _channel.invokeMethod(PLUGIN_EVENT_REGISTER_APP, [instance]);

  Future<void> tryUnregister(String instance) =>
      _channel.invokeMethod(PLUGIN_EVENT_UNREGISTER, [instance]);
}
