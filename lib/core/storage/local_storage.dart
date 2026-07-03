import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _tokenKey = 'auth_token';
  static const String _vendedorIdKey = 'vendedor_id';
  static const String _vendedorNombreKey = 'vendedor_nombre';

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

  Future<void> saveVendedorId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_vendedorIdKey, id);
  }

  Future<int?> getVendedorId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_vendedorIdKey);
  }

  Future<void> saveVendedorNombre(String nombre) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_vendedorNombreKey, nombre);
  }

  Future<String?> getVendedorNombre() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_vendedorNombreKey);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_vendedorIdKey);
    await prefs.remove(_vendedorNombreKey);
    await prefs.remove('has_sync_data');
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
