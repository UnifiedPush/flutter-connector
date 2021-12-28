import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unifiedpush_platform_interface/unifiedpush_platform_interface.dart';

import 'constants.dart';
import 'dialogs.dart';

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
  static List<String>? _availDistributors;

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
    final prefs = await getSharedPreferences();
    prefs?.setInt(
        PREF_ON_NEW_ENDPOINT_ADAPTER,
        PluginUtilities.getCallbackHandle(callbackOnNewEndpoint)?.toRawHandle() ??
            0);
    prefs?.setInt(
        PREF_ON_UNREGISTERED_ADAPTER,
        PluginUtilities.getCallbackHandle(callbackOnUnregistered)?.toRawHandle() ??
            0);
    prefs?.setInt(
        PREF_ON_MESSAGE_ADAPTER,
        PluginUtilities.getCallbackHandle(callbackOnMessage)?.toRawHandle() ??
            0);
    await UnifiedPushPlatform.instance.initializeBackgroundCallback(
      staticOnNewEndpoint: onNewEndpointAdapter,
      staticOnUnregistered: onUnregisteredAdapter,
      staticOnMessage: onMessageAdapter
    );
  }

  static onNewEndpointAdapter(dynamic args) async {
    final callback = await getCallbackFromPrefHandle(PREF_ON_NEW_ENDPOINT_ADAPTER);
    final instance = await getInstance(args["token"]);
    callback?.call({
      "instance" : instance,
      "endpoint" : args["endpoint"],
    });
  }

    static onUnregisteredAdapter(dynamic args) async {
    final callback = await getCallbackFromPrefHandle(PREF_ON_UNREGISTERED_ADAPTER);
    final instance = await getInstance(args["token"]);
    callback?.call({"instance" : instance});
  }

  static onMessageAdapter(dynamic args) async {
    final callback = await getCallbackFromPrefHandle(PREF_ON_MESSAGE_ADAPTER);
    final instance = await getInstance(args["token"]);
    callback?.call({
      "instance" : instance,
      "message" : args["message"],
    });
  }

  static Future<String?> getInstance(String token) async {
    final prefs = await getSharedPreferences();
    if (prefs != null) {
      for (String p in prefs.getKeys()) {
        final v = prefs.get(p);
        if (v == token) {
          return p.replaceFirst("/UP-lib_token", "");
        }
      }
    }
  }

  static Future<Function?> getCallbackFromPrefHandle(String prefKey) async {
    final prefs = await getSharedPreferences();
    final rawHandle = prefs?.getInt(prefKey);
    if (rawHandle != null && rawHandle != 0) {
      return PluginUtilities.getCallbackFromHandle(CallbackHandle.fromRawHandle(rawHandle));
    }
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
      onNewEndpoint: (String t, String e) async => onNewEndpoint?.call(e, (await getInstance(t))??UNKNOWN_INSTANCE),
      onRegistrationFailed: (String t, String? m) async => onRegistrationFailed?.call((await getInstance(t))??UNKNOWN_INSTANCE),
      onRegistrationRefused: (String t, String? m) async => onRegistrationRefused?.call((await getInstance(t))??UNKNOWN_INSTANCE),
      onUnregistered: (String t) async => onUnregistered?.call((await getInstance(t))??UNKNOWN_INSTANCE),
      onMessage: (String t, String m) async => onMessage?.call(m, (await getInstance(t))??UNKNOWN_INSTANCE),
    );
  }

  static Future<void> unregister([String instance = "default"]) async {
    UnifiedPushPlatform.instance.unregister(await getToken(instance));
  }

  static Future<void> registerAppWithDialog(BuildContext context, [String instance = "default"]) async {
    var distributor = getDistributor();
    if (distributor == "") {
      final distributors = await getDistributors();
      if (distributors.isEmpty) {
        await showDialog(context: context, builder: noDistributorDialog());
      } else {
        final picked = await showDialog<String>(
          context: context,
          builder: pickDistributorDialog(distributors),
        );
        if (picked != null) {
          await saveDistributor(picked);
        }
      }
    }

    await registerApp(instance = instance);
  }

  static Future<void> registerApp([String instance = "default"]) async {
    UnifiedPushPlatform.instance.registerApp(await getDistributor(), await getToken(instance));
  }

  static Future<List<String>> getDistributors() async {
    if (_availDistributors == null) {
      _availDistributors = await UnifiedPushPlatform.instance.getDistributors();
    }
    return _availDistributors??List.empty();
  }

  static Future<String> getDistributor() async {
    if (_preferredDistributor != null) {
      return _preferredDistributor!;
    }
    // Check the prefs
    final prefs = await getSharedPreferences();
    _preferredDistributor = prefs?.getString("UP-lib_distributor");
    if (_preferredDistributor != null) {
      return _preferredDistributor!;
    }
    // If there is only one avail just use it
    final distributors = await getDistributors();
    if (distributors.length == 1) {
      saveDistributor(distributors.first);
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

    return token;
  }
}
