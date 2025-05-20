import 'dart:core';

abstract class UnifiedPushStorageInterface {
  static Future<UnifiedPushStorageInterface> getInstance() {
    throw UnimplementedError("getInstance has not been implemented");
  }

  void setString(String key, String value) {
    throw UnimplementedError("saveString has not been implemented.");
  }

  String? getString(String key) {
    throw UnimplementedError("getString has not been implemented.");
  }

  void setBool(String key, bool value) {
    throw UnimplementedError("saveBool has not been implemented.");
  }

  bool? getBool(String key) {
    throw UnimplementedError("getBool has not been implemented.");
  }

  void remove(String key) {
    throw UnimplementedError("remove has not been implemented.");
  }
}
