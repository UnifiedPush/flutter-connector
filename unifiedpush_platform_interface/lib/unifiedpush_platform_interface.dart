import 'dart:async';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:unifiedpush_platform_interface/data/failed_reason.dart';
import 'package:unifiedpush_platform_interface/data/push_endpoint.dart';
import 'package:unifiedpush_platform_interface/data/push_message.dart';

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
  Future<List<String>> getDistributors(List<String> features) {
    throw UnimplementedError('getDistributors has not been implemented.');
  }

  /// Returns the qualified identifier of the distributor used.
  Future<String?> getDistributor() {
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
  Future<void> register(String instance, List<String> features,
      String? messageForDistributor, String? vapid) {
    throw UnimplementedError('registerApp has not been implemented.');
  }

  /// Try to use the saved distributor else, use the default distributor
  /// of the system
  Future<bool> tryUseCurrentOrDefaultDistributor() {
    throw UnimplementedError('tryUseCurrentOrDefaultDistributor has not been '
        'implemented.');
  }

  /// Send an unregistration request for the instance to the saved distributor
  /// and remove the registration. Remove the distributor if this is the last
  /// instance registered.
  Future<void> unregister(String instance) {
    throw UnimplementedError('unregister has not been implemented.');
  }

  /// Register callbacks to receive the push messages and other infos.
  /// Please see the spec for more infos on those callbacks and their
  /// parameters.
  /// This needs to be called BEFORE registerApp so onNewEndpoint get called
  /// and you get the info in your app, or this will be lost.
  Future<void> initializeCallback({
    void Function(PushEndpoint endpoint, String instance)? onNewEndpoint,
    void Function(FailedReason reason, String instance)? onRegistrationFailed,
    void Function(String instance)? onUnregistered,
    void Function(PushMessage message, String instance)? onMessage,
  }) {
    throw UnimplementedError('initializeCallback has not been implemented.');
  }

  /// Set the name the application will register with on the DBus session bus.
  /// Required for Linux applications.
  void setDBusName(String? name) {
    throw UnimplementedError('setDBusName has not been implemented.');
  }
}

class DefaultUnifiedPush extends UnifiedPushPlatform {}
