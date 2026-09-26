import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  AppStorage._();

  static const _tokenKey = 'auth_token';
  static const _userJsonKey = 'user_json';
  static const _onboardedKey = 'onboarded';

  static Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  static Future<String?> getToken() async => (await _prefs).getString(_tokenKey);

  static Future<void> setToken(String token) async =>
      (await _prefs).setString(_tokenKey, token);

  static Future<void> clearToken() async => (await _prefs).remove(_tokenKey);

  static Future<String?> getUserJson() async =>
      (await _prefs).getString(_userJsonKey);

  static Future<void> setUserJson(String json) async =>
      (await _prefs).setString(_userJsonKey, json);

  static Future<void> clearUser() async => (await _prefs).remove(_userJsonKey);

  static Future<bool> isOnboarded() async =>
      (await _prefs).getBool(_onboardedKey) ?? false;

  static Future<void> setOnboarded(bool value) async =>
      (await _prefs).setBool(_onboardedKey, value);

  static Future<void> clearAll() async {
    final prefs = await _prefs;
    await prefs.remove(_tokenKey);
    await prefs.remove(_userJsonKey);
  }
}
