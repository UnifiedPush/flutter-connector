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

class Message {
  String message;
  String instance;
  Message(this.message, this.instance);
}

class UnifiedPush {
  static MethodChannel _channel = MethodChannel(PLUGIN_CHANNEL);

  static late SharedPreferences prefs;
  static bool initialized = false;
  static final _msg = <Message>[];

  static void Function(String endpoint)? _onNewEndpointNoInstance =
      (String _) {};
  static void Function()? _onRegistrationRefusedNoInstance = () {};
  static void Function()? _onRegistrationFailedNoInstance = () {};
  static void Function()? _onUnregisteredNoInstance = () {};
  static void Function(String message)? _onMessageNoInstance = (String _) {};

  static void Function(String endpoint, String instance)? _onNewEndpoint =
      (String e, String _) {
    _onNewEndpointNoInstance?.call(e);
  };
  static void Function(String instance)? _onRegistrationRefused = (String _) {
    _onRegistrationRefusedNoInstance?.call();
  };
  static void Function(String instance)? _onRegistrationFailed = (String _) {
    _onRegistrationFailedNoInstance?.call();
  };
  static void Function(String instance)? _onUnregistered = (String _) {
    _onUnregisteredNoInstance?.call();
  };
  static void Function(String message, String instance)? _onMessage =
      (String m, String _) {
    _onMessageNoInstance?.call(m);
  };

  /// INIT: 1.A With Callback, Default Instance
  static Future<void> initializeWithCallback(
      void Function(String endpoint) onNewEndpoint,
      void Function() onRegistrationFailed,
      void Function() onRegistrationRefused,
      void Function() onUnregistered,
      void Function(String message) onMessage,
      void Function(dynamic args) callbackOnNewEndpoint, //need to be static
      void Function(dynamic args) callbackOnUnregistered, //need to be static
      void Function(dynamic args) callbackOnMessage //need to be static
      ) async {
    prefs = await SharedPreferences.getInstance();

    _onNewEndpointNoInstance = onNewEndpoint;
    _onRegistrationFailedNoInstance = onRegistrationFailed;
    _onRegistrationRefusedNoInstance = onRegistrationRefused;
    _onUnregisteredNoInstance = onUnregistered;
    _onMessageNoInstance = onMessage;

    _channel.setMethodCallHandler(onMethodCall);

    prefs.setInt(
        PREF_ON_NEW_ENDPOINT,
        PluginUtilities.getCallbackHandle(callbackOnNewEndpoint)
                ?.toRawHandle() ??
            0);
    prefs.setInt(
        PREF_ON_UNREGISTERED,
        PluginUtilities.getCallbackHandle(callbackOnUnregistered)
                ?.toRawHandle() ??
            0);
    prefs.setInt(
        PREF_ON_MESSAGE,
        PluginUtilities.getCallbackHandle(callbackOnMessage)?.toRawHandle() ??
            0);

    final callback = PluginUtilities.getCallbackHandle(callbackDispatcher);

    await _channel.invokeMethod(
        PLUGIN_EVENT_INITIALIZE_CALLBACK, <dynamic>[callback?.toRawHandle()]);
    debugPrint("initialization finished");
  }

  /// INIT: 1.B With Callback, Multi Instance
  static Future<void> initializeWithCallbackInstanciated(
      void Function(String endpoint, String instance) onNewEndpoint,
      void Function(String instance) onRegistrationFailed,
      void Function(String instance) onRegistrationRefused,
      void Function(String instance) onUnregistered,
      void Function(String message, String instance) onMessage,
      void Function(dynamic args) callbackOnNewEndpoint, //need to be static
      void Function(dynamic args) callbackOnUnregistered, //need to be static
      void Function(dynamic args) callbackOnMessage //need to be static
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
        PluginUtilities.getCallbackHandle(callbackOnNewEndpoint)
                ?.toRawHandle() ??
            0);
    prefs.setInt(
        PREF_ON_UNREGISTERED,
        PluginUtilities.getCallbackHandle(callbackOnUnregistered)
                ?.toRawHandle() ??
            0);
    prefs.setInt(
        PREF_ON_MESSAGE,
        PluginUtilities.getCallbackHandle(callbackOnMessage)?.toRawHandle() ??
            0);

    final callback = PluginUtilities.getCallbackHandle(callbackDispatcher);

    await _channel.invokeMethod(
        PLUGIN_EVENT_INITIALIZE_CALLBACK, <dynamic>[callback?.toRawHandle()]);
    initialized = true;
    debugPrint("initialization finished");
  }

  /// INIT: 2.A With Receiver, Default Instance
  static Future<void> initializeWithReceiver({
    void Function(String endpoint)? onNewEndpoint,
    void Function()? onRegistrationFailed,
    void Function()? onRegistrationRefused,
    void Function()? onUnregistered,
    void Function(String message)? onMessage,
  }) async {
    _onNewEndpointNoInstance = onNewEndpoint;
    _onRegistrationFailedNoInstance = onRegistrationFailed;
    _onRegistrationRefusedNoInstance = onRegistrationRefused;
    _onUnregisteredNoInstance = onUnregistered;
    _onMessageNoInstance = (String message) {
      if (onMessage != null) {
        onMessage(message);
      } else {
        _msg.add(Message(message, ""));
      }
    };

    if (_onMessageNoInstance != null) {
      _msg.forEach((msg) => _onMessageNoInstance?.call(msg.message));
      _msg.clear();
    }

    _channel.setMethodCallHandler(onMethodCall);

    await _channel.invokeMethod(PLUGIN_EVENT_INITIALIZE_CALLBACK, null);
    debugPrint("initialization finished");
  }

  /// INIT: 2.B With Receiver, Multi Instance
  static Future<void> initializeWithReceiverInstanciated({
    void Function(String endpoint, String instance)? onNewEndpoint,
    void Function(String instance)? onRegistrationFailed,
    void Function(String instance)? onRegistrationRefused,
    void Function(String instance)? onUnregistered,
    void Function(String message, String instance)? onMessage,
  }) async {
    _onNewEndpoint = onNewEndpoint;
    _onRegistrationFailed = onRegistrationFailed;
    _onRegistrationRefused = onRegistrationRefused;
    _onUnregistered = onUnregistered;
    _onMessage = (String message, String instance) {
      if (onMessage != null) {
        onMessage(message, instance);
      } else {
        _msg.add(Message(message, instance));
      }
    };

    if (_onMessage != null) {
      _msg.forEach((msg) => _onMessage?.call(msg.message, msg.instance));
      _msg.clear();
    }

    _channel.setMethodCallHandler(onMethodCall);

    await _channel.invokeMethod(PLUGIN_EVENT_INITIALIZE_CALLBACK, null);
    debugPrint("initialization finished");
  }

  /// Call handler
  static Future<void> onMethodCall(MethodCall call) async {
    // type inference will work here avoiding an explicit cast
    debugPrint(call.method);
    final instance = call.arguments["instance"];
    switch (call.method) {
      case "onNewEndpoint":
        _onNewEndpoint?.call(call.arguments["endpoint"], instance);
        break;
      case "onRegistrationRefused":
        _onRegistrationRefused?.call(instance);
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

  static Future<void> unregister([String instance = ""]) async {
    await _channel.invokeMethod(PLUGIN_EVENT_UNREGISTER, [instance]);
  }

  static Future<void> registerAppWithDialog([String instance = ""]) async {
    await _channel
        .invokeMethod(PLUGIN_EVENT_REGISTER_APP_WITH_DIALOG, [instance]);
  }

  static Future<List<String>> getDistributors() async {
    return (await _channel.invokeMethod(PLUGIN_EVENT_GET_DISTRIBUTORS))
        .cast<String>();
  }

  static Future<String> getDistributor() async {
    return (await _channel.invokeMethod(PLUGIN_EVENT_GET_DISTRIBUTOR))
        as String;
  }

  static Future<void> saveDistributor(String distributor) async {
    await _channel.invokeMethod(PLUGIN_EVENT_SAVE_DISTRIBUTOR, [distributor]);
  }

  static Future<void> registerApp([String instance = ""]) async {
    await _channel.invokeMethod(PLUGIN_EVENT_REGISTER_APP, [instance]);
  }
}
