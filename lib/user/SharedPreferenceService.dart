import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceService {
  // Ma'lumotni saqlash (string)
  Future<void> saveData(String key, Map<String, dynamic> value) async {
    final prefs = await SharedPreferences.getInstance();
    var json = jsonEncode(value);
    prefs.setString(key, json);
  }

  // Ma'lumotni o'qish (string)
  Future<Map> getData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return jsonDecode(prefs.getString(key).toString());
  }

  // Ma'lumotni tozalash
  Future<void> clearData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(key);
  }
}
