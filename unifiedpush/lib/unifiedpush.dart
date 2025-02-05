import 'dart:async';
import 'package:unifiedpush_platform_interface/data/failed_reason.dart';
import 'package:unifiedpush_platform_interface/data/push_endpoint.dart';
import 'package:unifiedpush_platform_interface/data/push_message.dart';
import 'package:unifiedpush_platform_interface/unifiedpush_platform_interface.dart';

import 'constants.dart';

export 'package:unifiedpush_platform_interface/data/failed_reason.dart';
export 'package:unifiedpush_platform_interface/data/push_endpoint.dart';
export 'package:unifiedpush_platform_interface/data/push_message.dart';


class UnifiedPush {
  static Future<void> initialize({
    void Function(PushEndpoint endpoint, String instance)? onNewEndpoint,
    void Function(FailedReason reason, String instance)? onRegistrationFailed,
    void Function(String instance)? onUnregistered,
    void Function(PushMessage message, String instance)? onMessage,
  }) async {
    await UnifiedPushPlatform.instance.initializeCallback(
        onNewEndpoint: (PushEndpoint e, String i) async => onNewEndpoint?.call(e, i),
        onRegistrationFailed: (FailedReason r,String i) async => onRegistrationFailed?.call(r, i),
        onUnregistered: (String i) async => onUnregistered?.call(i),
        onMessage: (PushMessage m, String i) async => onMessage?.call(m, i));
  }

  static Future<void> register(
      [String instance = defaultInstance,
      List<String>? features = const []]) async {
    await UnifiedPushPlatform.instance.registerApp(instance, features ?? []);
  }

  @Deprecated("Renamed register")
  static Future<void> registerApp(
      [String instance = defaultInstance,
        List<String>? features = const []]) async {
    await register(instance, features);
  }

  static Future<void> unregister([String instance = defaultInstance]) async {
    await UnifiedPushPlatform.instance.unregister(instance);
  }

  static Future<List<String>> getDistributors(
      [List<String>? features = const []]) async {
    return await UnifiedPushPlatform.instance.getDistributors(features ?? []);
  }

  static Future<String?> getDistributor() async {
    return await UnifiedPushPlatform.instance.getDistributor();
  }

  static Future<void> saveDistributor(String distributor) async {
    await UnifiedPushPlatform.instance.saveDistributor(distributor);
  }
}
