import 'package:shared_preferences/shared_preferences.dart';
import 'package:unifiedpush_storage_interface/storage_interface.dart';

class UnifiedPushStorage extends UnifiedPushStorageInterface {
  late SharedPreferences sharedPreferences;

  UnifiedPushStorage(this.sharedPreferences);

  static Future<UnifiedPushStorageInterface> getInstance() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    return UnifiedPushStorage(sharedPreferences);
  }

  @override
  void setString(String key, String value) {
    sharedPreferences.setString(key, value);
  }

  @override
  String? getString(String key) {
    return sharedPreferences.getString(key);
  }

  @override
  void setBool(String key, bool value) {
    sharedPreferences.setBool(key, value);
  }

  @override
  bool? getBool(String key) {
    return sharedPreferences.getBool(key);
  }

  @override
  void remove(String key) {
    sharedPreferences.remove(key);
  }
}
