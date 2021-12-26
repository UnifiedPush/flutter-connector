import 'dart:async';
import 'dart:math';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unifiedpush_platform_interface/unifiedpush_platform_interface.dart';

String generateRandomToken() {
  final len = 32;
  final r = Random();
  return String.fromCharCodes(List.generate(len, (index) => r.nextInt(33) + 89));
}

final UNKNOWN_INSTANCE = "UNKNOWN_INSTANCE";

class UnifiedPush {
  static SharedPreferences? _prefs;

  static Future<SharedPreferences?> getSharedPreferences() async {
    if (_prefs == null) {
      _prefs = await SharedPreferences.getInstance();
      var migrated = _prefs?.getBool("migrated");
      if (migrated == null || !migrated) {
        final nativePrefs = await UnifiedPushPlatform.instance.getAllNativeSharedPrefs();
        if (nativePrefs != null) {
          nativePrefs.forEach((key, value) {
            if (value is String) {
              _prefs?.setString(key, value);
            } else if (value is Iterable) {
              _prefs?.setStringList(key, List.from(value));
            }
          });
        }
        _prefs?.setBool("migrated", true);
      }
    }
    return _prefs;
  }

  static String? _preferredDistributor;
  static Map<String, String> tokenToInstance = Map();

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
    await initializeWithCallbackInstantiated(
      (String e, String i) => onNewEndpoint.call(e),
      (String i) => onRegistrationFailed.call(),
      (String i) => onRegistrationRefused.call(),
      (String i) => onUnregistered.call(),
      (String m, String i) => onMessage.call(m),
      callbackOnNewEndpoint,
      callbackOnUnregistered,
      callbackOnMessage
    );
  }

  /// INIT: 1.B With Callback, Multi Instance
  static Future<void> initializeWithCallbackInstantiated(
      void Function(String endpoint, String instance) onNewEndpoint,
      void Function(String instance) onRegistrationFailed,
      void Function(String instance) onRegistrationRefused,
      void Function(String instance) onUnregistered,
      void Function(String message, String instance) onMessage,
      void Function(dynamic args) callbackOnNewEndpoint, //need to be static
      void Function(dynamic args) callbackOnUnregistered, //need to be static
      void Function(dynamic args) callbackOnMessage //need to be static
      ) async {
    await initializeWithReceiverInstantiated(
      onNewEndpoint: onNewEndpoint,
      onRegistrationFailed: onRegistrationFailed,
      onRegistrationRefused: onRegistrationRefused,
      onUnregistered: onUnregistered,
      onMessage: onMessage,
    );
    await UnifiedPushPlatform.instance.initializeBackgroundCallback(
      staticOnNewEndpoint: callbackOnNewEndpoint,
      staticOnUnregistered: callbackOnUnregistered,
      staticOnMessage: callbackOnMessage
    );
  }

  /// INIT: 2.A With Receiver, Default Instance
  static Future<void> initializeWithReceiver({
    void Function(String endpoint)? onNewEndpoint,
    void Function()? onRegistrationFailed,
    void Function()? onRegistrationRefused,
    void Function()? onUnregistered,
    void Function(String message)? onMessage,
  }) async {
    await initializeWithReceiverInstantiated(
      onNewEndpoint: (String e, String i) => onNewEndpoint?.call(e),
      onRegistrationFailed: (String i) => onRegistrationFailed?.call(),
      onRegistrationRefused: (String i) => onRegistrationRefused?.call(),
      onUnregistered: (String i) => onUnregistered?.call(),
      onMessage: (String m, String i) => onMessage?.call(m),
    );
  }

  /// INIT: 2.B With Receiver, Multi Instance
  static Future<void> initializeWithReceiverInstantiated({
    void Function(String endpoint, String instance)? onNewEndpoint,
    void Function(String instance)? onRegistrationFailed,
    void Function(String instance)? onRegistrationRefused,
    void Function(String instance)? onUnregistered,
    void Function(String message, String instance)? onMessage,
  }) async {
    await UnifiedPushPlatform.instance.initializeCallback(
      onNewEndpoint: (String t, String e) => onNewEndpoint?.call(e, tokenToInstance[t]??UNKNOWN_INSTANCE),
      onRegistrationFailed: (String t, String? m) => onRegistrationFailed?.call(tokenToInstance[t]??UNKNOWN_INSTANCE),
      onRegistrationRefused: (String t, String? m) => onRegistrationRefused?.call(tokenToInstance[t]??UNKNOWN_INSTANCE),
      onUnregistered: (String t) => onUnregistered?.call(tokenToInstance[t]??UNKNOWN_INSTANCE),
      onMessage: (String t, String m) => onMessage?.call(m, tokenToInstance[t]??UNKNOWN_INSTANCE),
    );
  }

  static Future<void> unregister([String instance = "default"]) async {
    UnifiedPushPlatform.instance.unregister(await getToken(instance));
  }

  static Future<void> registerAppWithDialog([String instance = "default"]) async {
    // TODO implements dialog selection
    await registerApp(instance = instance);
  }

  static Future<void> registerApp([String instance = "default"]) async {
    UnifiedPushPlatform.instance.registerApp(await getDistributor(), await getToken(instance));
  }

  static Future<List<String>> getDistributors() async {
    return UnifiedPushPlatform.instance.getDistributors();
  }

  static Future<String> getDistributor() async {
    if (_preferredDistributor != null) {
      return _preferredDistributor!;
    }
    final prefs = await getSharedPreferences();
    _preferredDistributor = prefs?.getString("UP-lib_distributor");
    if (_preferredDistributor != null) {
      return _preferredDistributor!;
    }

    final distributors = await getDistributors();
    if (distributors.isNotEmpty) {
      _preferredDistributor = distributors.first;
      return _preferredDistributor!;
    }
    return "";
  }

  static Future<void> saveDistributor(String distributor) async {
    _preferredDistributor = distributor;
    (await getSharedPreferences())?.setString("UP-lib_distributor", distributor);
  }

  static Future<String> getToken(String instance) async {
    final prefs = await getSharedPreferences();
    final prefKey = instance + "/UP-lib_token";

    var token = prefs?.getString(prefKey);

    if (token == null) {
      token = generateRandomToken();
      prefs?.setString(prefKey, token);
    }
    tokenToInstance[token] = instance;

    return token;
  }
}
