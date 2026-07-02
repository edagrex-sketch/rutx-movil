import 'package:dio/dio.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/constants/api_constants.dart';

class AuthRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 3),
    receiveTimeout: const Duration(seconds: 3),
  ));
  final LocalStorage _localStorage = LocalStorage();

  Future<bool> login(String username, String password, bool rememberMe) async {
    try {
      final response = await _dio.post('/api/auth/login', data: {
        'usuario': username,
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
      print('Error en login: $e');
      return false;
    }
  }

  Future<bool> hasValidToken() async {
    final token = await _localStorage.getToken();
    return token != null && token.isNotEmpty;
  }
}
