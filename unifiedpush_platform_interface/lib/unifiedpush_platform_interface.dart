import 'package:flutter/foundation.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'dart:async';

import 'package:unifiedpush_platform_interface/MethodChannel.dart';

abstract class UnifiedPushPlatform extends PlatformInterface {
  /// Constructs a UrlLauncherPlatform.
  UnifiedPushPlatform() : super(token: _token);

  static final Object _token = Object();

  static UnifiedPushPlatform _instance = UnifiedPushMethodChannel();

  /// The default instance of [UnifiedPushPlatform] to use.
  ///
  /// Defaults to [MethodChannelUrlLauncher].
  static UnifiedPushPlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own platform-specific
  /// class that extends [UnifiedPushPlatform] when they register themselves.
  // https://github.com/flutter/flutter/issues/43368
  // ???
  static set instance(UnifiedPushPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  @protected
  void Function(String endpoint, String instance) onNewEndpoint =
      (String _, String _1) {};
  @protected
  void Function(String instance) onRegistrationRefused = (String _) {};
  @protected
  void Function(String instance) onRegistrationFailed = (String _) {};
  @protected
  void Function(String instance) onUnregistered = (String _) {};
  @protected
  void Function(String message, String instance) onMessage =
      (String _, String _1) {};

//needed for desktop platforms
  Future<void> bgCheck() async {
    //empty in default impl because not required by all platforms
  }

  void initializeWithCallback(
    void Function(String endpoint, String instance) onNewEndpoint,
    void Function(String instance) onRegistrationFailed,
    void Function(String instance) onRegistrationRefused,
    void Function(String instance) onUnregistered,
    void Function(String message, String instance) onMessage,
  ) {
    this.onNewEndpoint = onNewEndpoint;
    this.onRegistrationFailed = onRegistrationFailed;
    this.onRegistrationRefused = onRegistrationRefused;
    this.onUnregistered = onUnregistered;
    this.onMessage = onMessage;
  }

  Future<void> initCallback(Function()? callbackDispatcher) async {
    throw UnimplementedError('initCallback() has not been implemented.');
  }

  @protected
  Future<void> processReceive() {
    throw UnimplementedError('_processReceive() has not been implemented.');
  }

  Future<void> register(String instance) {
    throw UnimplementedError('register() has not been implemented.');
  }

  Future<void> tryUnregister(String instance) {
    throw UnimplementedError('tryUnregister has not been implemented.');
  }

  Future<String> get distributor {
    throw UnimplementedError('get distributor has not been implemented.');
  }

  Future<void> saveDistributor(String distributor) {
    throw UnimplementedError('setDistributor()) has not been implemented.');
  }

  Future<Map<String, String>> getDistributors() {
    throw UnimplementedError('getDistributors() has not been implemented.');
  }
}
