import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setLoggedInUserId(int userId) async {
    await _prefs.setInt('loggedInUserId', userId);
  }

  static int? getLoggedInUserId() {
    return _prefs.getInt('loggedInUserId');
  }

  static Future<void> setDarkMode(bool value) async {
    await _prefs.setBool('darkMode', value);
  }

  static bool getDarkMode() {
    return _prefs.getBool('darkMode') ?? false;
  }

  static Future<void> clear() async {
    await _prefs.clear();
  }
}