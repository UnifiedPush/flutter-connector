import 'dart:async';

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

  /// Register the app to a specified distributor with a specified token
  /// This method needs to be called at every app startup with the same
  /// distributor and token.
  Future<void> registerApp(String distributor, String token) {
    throw UnimplementedError('registerApp has not been implemented.');
  }
  
  Future<void> unregister(String token) {
    throw UnimplementedError('unregister has not been implemented.');
  }

  /// Register callbacks to receive the push messages and other infos.
  /// Please see the spec for more infos on those callbacks and their
  /// parameters.
  /// This needs to be called BEFORE registerApp so onNewEndpoint get called
  /// and you get the info in your app, or this will be lost.
  Future<void> initializeCallback({
    void Function(String token, String endpoint)? onNewEndpoint,
    void Function(String token, String? message)? onRegistrationFailed,
    void Function(String token, String? message)? onRegistrationRefused,
    void Function(String token)? onUnregistered,
    void Function(String token, String message)? onMessage,
  }) {
    throw UnimplementedError('initializeCallback has not been implemented.');
  }

  /// Register static callbacks that can be called in background
  /// when the app is killed. This is not needed if you are using
  /// a receiver instead.
  Future<void> initializeBackgroundCallback({
    void Function(dynamic args)? staticOnNewEndpoint, //need to be static
    void Function(dynamic args)? staticOnUnregistered, //need to be static
    void Function(dynamic args)? staticOnMessage, //need to be static
  }) {
    throw UnimplementedError('initializeBackgroundCallback has not been implemented.');
  }

  /// Do not implement, it is there only to provide a migration path
  /// from old Android native code, and will be removed at some point.
  @deprecated
  Future<Map<String, dynamic>?> getAllNativeSharedPrefs() async {
    return null;
  }
}

class DefaultUnifiedPush extends UnifiedPushPlatform {}
