import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CallbackDispatcher.dart';
import 'package:unifiedpush_platform_interface/unifiedpush_platform_interface.dart';
import 'package:url_launcher/url_launcher.dart' show launch;

const PREF_ON_NEW_ENDPOINT = "unifiedpush/method:onNewEnpoint";
const PREF_ON_REGISTRATION_REFUSED = "unifiedpush/method:onRegistrationRefused";
const PREF_ON_REGISTRATION_FAILED = "unifiedpush/method:onRegistrationFailed";
const PREF_ON_UNREGISTERED = "unifiedpush/method:onUnregistered";
const PREF_ON_MESSAGE = "unifiedpush/method:onMessage";

enum RegistrationReply { none, newRegistration, failed, refused, timeout }

class _Message {
  String message;
  String instance;
  _Message(this.message, this.instance);
}

class UnifiedPush {
  static late SharedPreferences prefs;
  static bool initialized = false;
  static final _msg = <_Message>[];

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
    _onNewEndpointNoInstance = onNewEndpoint;
    _onRegistrationFailedNoInstance = onRegistrationFailed;
    _onRegistrationRefusedNoInstance = onRegistrationRefused;
    _onUnregisteredNoInstance = onUnregistered;
    _onMessageNoInstance = onMessage;

    UnifiedPushPlatform.instance.initializeWithCallback(
      _onNewEndpoint ?? (_, _1) {},
      _onRegistrationFailed ?? (_) {},
      _onRegistrationRefused ?? (_) {},
      _onUnregistered ?? (_) {},
      _onMessage ?? (_, _1) {},
    );
    UnifiedPushPlatform.instance.initCallback(callbackDispatcher);

    await _initCallbackPrefs(
        callbackOnNewEndpoint, callbackOnUnregistered, callbackOnMessage);
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
    _onNewEndpoint = onNewEndpoint;
    _onRegistrationFailed = onRegistrationFailed;
    _onRegistrationRefused = onRegistrationRefused;
    _onUnregistered = onUnregistered;
    _onMessage = onMessage;

    UnifiedPushPlatform.instance.initializeWithCallback(
      _onNewEndpoint ?? (_, _1) {},
      _onRegistrationFailed ?? (_) {},
      _onRegistrationRefused ?? (_) {},
      _onUnregistered ?? (_) {},
      _onMessage ?? (_, _1) {},
    );
    UnifiedPushPlatform.instance.initCallback(callbackDispatcher);

    await _initCallbackPrefs(
        callbackOnNewEndpoint, callbackOnUnregistered, callbackOnMessage);
    debugPrint("initialization finished");
  }

  static Future<void> _initCallbackPrefs(
      void Function(dynamic args) callbackOnNewEndpoint, //need to be static
      void Function(dynamic args) callbackOnUnregistered, //need to be static
      void Function(dynamic args) callbackOnMessage //need to be static

      ) async {
    prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
        PREF_ON_NEW_ENDPOINT,
        PluginUtilities.getCallbackHandle(callbackOnNewEndpoint)
                ?.toRawHandle() ??
            0);
    await prefs.setInt(
        PREF_ON_UNREGISTERED,
        PluginUtilities.getCallbackHandle(callbackOnUnregistered)
                ?.toRawHandle() ??
            0);
    await prefs.setInt(
        PREF_ON_MESSAGE,
        PluginUtilities.getCallbackHandle(callbackOnMessage)?.toRawHandle() ??
            0);

    initialized = true;
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
        _msg.add(_Message(message, ""));
      }
    };

    if (_onMessageNoInstance != null) {
      _msg.forEach((msg) => _onMessageNoInstance?.call(msg.message));
      _msg.clear();
    }

    UnifiedPushPlatform.instance.initializeWithCallback(
      _onNewEndpoint ?? (_, _1) {},
      _onRegistrationFailed ?? (_) {},
      _onRegistrationRefused ?? (_) {},
      _onUnregistered ?? (_) {},
      _onMessage ?? (_, _1) {},
    );

    await UnifiedPushPlatform.instance.initCallback(null);
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
        _msg.add(_Message(message, instance));
      }
    };

    if (_onMessage != null) {
      _msg.forEach((msg) => _onMessage?.call(msg.message, msg.instance));
      _msg.clear();
    }

    UnifiedPushPlatform.instance.initializeWithCallback(
      _onNewEndpoint ?? (_, _1) {},
      _onRegistrationFailed ?? (_) {},
      _onRegistrationRefused ?? (_) {},
      _onUnregistered ?? (_) {},
      _onMessage ?? (_, _1) {},
    );

    await UnifiedPushPlatform.instance.initCallback(null);
    debugPrint("initialization finished");
  }

  static Future<void> unregister({String instance = ""}) =>
      UnifiedPushPlatform.instance.tryUnregister(instance);

  static Future<void> registerAppWithDialog(BuildContext context,
      {String instance = ""}) async {
    if ((await getDistributor()).isEmpty) {
      var dists = await getDistributors();
      switch (dists.length) {
        case 0:
          await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Push Notifications'),
                  content: SingleChildScrollView(
                      child: SelectableText(
                          "You need to install a distributor for push notifications to work.\nYou can find more information at: https://unifiedpush.org/users/intro/")),
                  actions: [
                    TextButton(
                      child: const Text('More Info'),
                      onPressed: () =>
                          launch('https://unifiedpush.org/users/intro/'),
                    ),
                    TextButton(
                      child: const Text('Close'),
                      onPressed: Navigator.of(context).pop,
                    ),
                  ],
                );
              });
          break;
        case 1:
          await saveDistributor(dists[0]);
          break;
        default:
          final picked = await showDialog<String>(
              context: context,
              builder: (BuildContext context) {
                return SimpleDialog(
                    title: const Text('Select push distributor'),
                    children: dists
                        .map<Widget>(
                          (String o) => SimpleDialogOption(
                            onPressed: () {
                              Navigator.pop(context, o);
                            },
                            child: Text(o),
                          ),
                        )
                        .toList());
              });

          if (picked != null) await saveDistributor(picked);

          break;
      }
    }
    registerApp();
  }

  static Future<List<String>> getDistributors() async =>
      UnifiedPushPlatform.instance.getDistributors();

  static Future<String> getDistributor() async =>
      UnifiedPushPlatform.instance.distributor;

  static Future<void> saveDistributor(String distributor) =>
      UnifiedPushPlatform.instance.saveDistributor(distributor);

  static Future<void> registerApp({String instance = ""}) =>
      UnifiedPushPlatform.instance.register(instance);
}
