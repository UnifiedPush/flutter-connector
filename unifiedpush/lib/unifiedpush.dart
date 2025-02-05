import 'dart:async';
import 'dart:typed_data';
import 'package:unifiedpush_platform_interface/unifiedpush_platform_interface.dart';

import 'constants.dart';

class UnifiedPush {
  static Future<void> initialize({
    void Function(String endpoint, String instance)? onNewEndpoint,
    void Function(String instance)? onRegistrationFailed,
    void Function(String instance)? onUnregistered,
    void Function(Uint8List message, String instance)? onMessage,
  }) async {
    await UnifiedPushPlatform.instance.initializeCallback(
        onNewEndpoint: (String e, String i) async => onNewEndpoint?.call(e, i),
        onRegistrationFailed: (String i) async => onRegistrationFailed?.call(i),
        onUnregistered: (String i) async => onUnregistered?.call(i),
        onMessage: (Uint8List m, String i) async => onMessage?.call(m, i));
  }


  static Future<void> registerApp(
      [String instance = defaultInstance,
      List<String>? features = const []]) async {
    await UnifiedPushPlatform.instance.registerApp(instance, features ?? []);
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
