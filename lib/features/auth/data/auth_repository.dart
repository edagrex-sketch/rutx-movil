import 'package:dio/dio.dart';
import '../../../core/storage/local_storage.dart';

class AuthRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://10.0.2.2/api',
    connectTimeout: const Duration(seconds: 3),
    receiveTimeout: const Duration(seconds: 3),
  )); // Update this later
  final LocalStorage _localStorage = LocalStorage();

  Future<bool> login(String username, String password, bool rememberMe) async {
    try {
      // Reemplaza '/login' por el endpoint real
      final response = await _dio.post('/login', data: {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200 && response.data != null) {
        final token = response.data['token'];
        if (rememberMe) {
          await _localStorage.saveToken(token);
        }
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> hasValidToken() async {
    final token = await _localStorage.getToken();
    return token != null && token.isNotEmpty;
  }
}
