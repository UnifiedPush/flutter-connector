import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unifiedpush_platform_interface/unifiedpush_platform_interface.dart';

import 'constants.dart';
import 'dialogs.dart';

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

  static const noDistribAck = "noDistributorAck";

  static Future<void> registerAppWithDialog(BuildContext context,
      [String instance = defaultInstance, List<String>? features]) async {
    var distributor = await getDistributor();
    final prefs = await SharedPreferences.getInstance();
    String? picked;

    if (distributor == null) {
      final distributors = await getDistributors(features = features);
      if (distributors.isEmpty) {
        if (!(prefs.getBool(noDistribAck) ?? false)) {
          return showDialog(
              context: context,
              builder: noDistributorDialog(onDismissed: () {
                prefs.setBool(noDistribAck, true);
              }));
        }
      } else if (distributors.length == 1) {
        picked = distributors.single;
      } else {
        picked = await showDialog<String>(
          context: context,
          builder: pickDistributorDialog(distributors),
        );
      }

      if (picked != null) {
        await saveDistributor(picked);
      }
    }

    await registerApp(instance = instance, features = features);
  }

  static Future<void> removeNoDistributorDialogACK() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(noDistribAck);
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
