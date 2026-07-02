import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _tokenKey = 'auth_token';

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<void> setSyncData(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_sync_data', value);
  }

  Future<bool> hasSyncData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('has_sync_data') ?? false;
  }
}
