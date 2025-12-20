import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesUtils {
  static late SharedPreferences sharedPreferences;

  static Future<SharedPreferences> getInstance() async {
    return sharedPreferences = await SharedPreferences.getInstance();
  }

  static saveData({required String key, required dynamic value}) {
    if (value is String) {
      sharedPreferences.setString(key, value);
    } else if (value is int) {
      sharedPreferences.setInt(key, value);
    } else if (value is bool) {
      sharedPreferences.setBool(key, value);
    } else if (value is double) {
      sharedPreferences.setDouble(key, value);
    } else if (value is List<String>) {
      sharedPreferences.setStringList(key, value);
    }
  }

  static readData({required String key}) {
    return sharedPreferences.get(key);
  }
  static removeData({required String key}) {
    sharedPreferences.remove(key);
  }
}
