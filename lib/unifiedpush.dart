import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Constants.dart';
import 'CallbackDispatcher.dart';

const PREF_ON_NEW_ENDPOINT = "unifiedpush/method:onNewEnpoint";
const PREF_ON_REGISTRATION_REFUSED = "unifiedpush/method:onRegistrationRefused";
const PREF_ON_REGISTRATION_FAILED = "unifiedpush/method:onRegistrationFailed";
const PREF_ON_UNREGISTERED = "unifiedpush/method:onUnregistered";
const PREF_ON_MESSAGE = "unifiedpush/method:onMessage";

enum RegistrationReply { none, newRegistration, failed, refused, timeout }

class UnifiedPush {
  static MethodChannel _channel = MethodChannel(PLUGIN_CHANNEL);

  static SharedPreferences prefs;
  static final _msg = <String>[];

  static void Function(String endpoint) _onNewEndpoint = (String _) {};
  static void Function() _onRegistrationRefused = () {};
  static void Function() _onRegistrationFailed = () {};
  static void Function() _onUnregistered = () {};
  static void Function(String message) _onMessage = (String _) {};

  static Future<void> initializeWithCallback(
      void Function(String endpoint) onNewEndpoint,
      void Function() onRegistrationFailed,
      void Function() onRegistrationRefused,
      void Function() onUnregistered,
      void Function(String message) onMessage,
      void Function(String endpoint) callbackOnNewEndpoint, //need to be static
      void Function() callbackOnUnregistered, //need to be static
      void Function(String message) callbackOnMessage //need to be static
      ) async {

    prefs = await SharedPreferences.getInstance();

    _onNewEndpoint = onNewEndpoint;
    _onRegistrationFailed = onRegistrationFailed;
    _onRegistrationRefused = onRegistrationRefused;
    _onUnregistered = onUnregistered;
    _onMessage = onMessage;

    _channel.setMethodCallHandler(onMethodCall);

    prefs.setInt(
        PREF_ON_NEW_ENDPOINT,
        PluginUtilities.getCallbackHandle(callbackOnNewEndpoint)?.toRawHandle()
    );
    prefs.setInt(
        PREF_ON_UNREGISTERED,
        PluginUtilities.getCallbackHandle(callbackOnUnregistered)?.toRawHandle()
    );
    prefs.setInt(
        PREF_ON_MESSAGE,
        PluginUtilities.getCallbackHandle(callbackOnMessage)?.toRawHandle()
    );

    final callback = PluginUtilities.getCallbackHandle(callbackDispatcher);

    await _channel.invokeMethod(
        PLUGIN_EVENT_INITIALIZE_CALLBACK,
        <dynamic>[callback.toRawHandle()]
    );
    debugPrint("initialization finished");
  }

  static Future<void> initializeWithReceiver({
    void Function(String endpoint) onNewEndpoint,
    void Function() onRegistrationFailed,
    void Function() onRegistrationRefused,
    void Function() onUnregistered,
    void Function(String message) onMessage,
  }) async {
    _onNewEndpoint = onNewEndpoint;
    _onRegistrationFailed = onRegistrationFailed;
    _onRegistrationRefused = onRegistrationRefused;
    _onUnregistered = onUnregistered;
    _onMessage = (String message) {
      if (onMessage != null) {
        onMessage(message);
      } else {
        _msg.add(message);
      }
    };

    if (_onMessage != null) {
      _msg.forEach(_onMessage);
      _msg.clear();
    }

    _channel.setMethodCallHandler(onMethodCall);

    await _channel.invokeMethod(
        PLUGIN_EVENT_INITIALIZE_CALLBACK,
        null
    );
    debugPrint("initialization finished");
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
    await _channel.invokeMethod(PLUGIN_EVENT_UNREGISTER);
  }

  static Future<void> registerAppWithDialog() async {
    await _channel.invokeMethod(PLUGIN_EVENT_REGISTER_APP_WITH_DIALOG);
  }

  static Future<List<String>> getDistributors() async {
    return (await _channel.invokeMethod(PLUGIN_EVENT_GET_DISTRIBUTORS)).cast<String>();
  }

  static Future<String> getDistributor() async {
    return (await _channel.invokeMethod(PLUGIN_EVENT_GET_DISTRIBUTOR)) as String;
  }

  static Future<void> saveDistributor(String distributor) async {
    await _channel.invokeMethod(PLUGIN_EVENT_SAVE_DISTRIBUTOR, distributor);
  }

  static Future<void> registerApp() async {
    await _channel.invokeMethod(PLUGIN_EVENT_REGISTER_APP);
  }
}
