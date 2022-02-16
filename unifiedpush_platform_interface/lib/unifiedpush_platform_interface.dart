import 'dart:async';
import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// The interface that implementations of unifiedpush must implement.
abstract class UnifiedPushPlatform extends PlatformInterface {
  UnifiedPushPlatform() : super(token: _token);

  static final Object _token = Object();

  static UnifiedPushPlatform _instance = DefaultUnifiedPush();

  static UnifiedPushPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [UnifiedPushPlatform] when they register themselves.
  static set instance(UnifiedPushPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Returns the qualified identifier of all available distributors on the system.
  Future<List<String>> getDistributors() {
    throw UnimplementedError('getDistributors has not been implemented.');
  }

  /// Returns the qualified identifier of the distributor used.
  Future<String> getDistributor() {
    throw UnimplementedError('getDistributor has not been implemented.');
  }

  /// Save the distributor to be used.
  Future<void> saveDistributor(String distributor) {
    throw UnimplementedError('saveDistributor has not been implemented.');
  }

  /// Register the app to the saved distributor with a specified token
  /// identified with the instance parameter
  /// This method needs to be called at every app startup with the same
  /// distributor and token.
  Future<void> registerApp(String instance) {
    throw UnimplementedError('registerApp has not been implemented.');
  }

  Future<void> unregister(String instance) {
    throw UnimplementedError('unregister has not been implemented.');
  }

  /// Register callbacks to receive the push messages and other infos.
  /// Please see the spec for more infos on those callbacks and their
  /// parameters.
  /// This needs to be called BEFORE registerApp so onNewEndpoint get called
  /// and you get the info in your app, or this will be lost.
  Future<void> initializeCallback({
    void Function(String endpoint, String instance)? onNewEndpoint,
    void Function(String instance)? onRegistrationFailed,
    void Function(String instance)? onUnregistered,
    void Function(Uint8List message, String instance)? onMessage,
  }) {
    throw UnimplementedError('initializeCallback has not been implemented.');
  }

  /// Do not implement, it is there only to provide a migration path
  /// from old Android native code, and will be removed at some point.
  @deprecated
  Future<Map<String, dynamic>?> getAllNativeSharedPrefs() async {
    return null;
  }
}

class DefaultUnifiedPush extends UnifiedPushPlatform {}
