import 'package:dio/dio.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/constants/api_constants.dart';

class AuthRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
  final LocalStorage _localStorage = LocalStorage();

  Future<String?> login(String username, String password, bool rememberMe) async {
    try {
      final response = await _dio.post('/api/auth/login', data: {
        'usuario': username,
        'password': password,
      });

      if (response.statusCode == 200 && response.data != null) {
        final token = response.data['token'] as String;
        await _localStorage.saveToken(token);
        await _localStorage.saveVendedorId(7853);
        await _localStorage.saveVendedorNombre('Vendedor Ruta Centro');
        return null;
      }
      return 'Credenciales incorrectas.';
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'El servidor no responde. Verifica tu conexión.';
      }
      if (e.type == DioExceptionType.connectionError) {
        return 'Sin conexión al servidor. Asegúrate de que el Sincronizador esté encendido.';
      }
      if (e.response?.statusCode == 401) {
        return 'Usuario o contraseña incorrectos.';
      }
      return 'Error al iniciar sesión. Intenta de nuevo.';
    } catch (_) {
      return 'Error inesperado. Intenta de nuevo.';
    }
  }

  Future<bool> hasValidToken() async {
    final token = await _localStorage.getToken();
    return token != null && token.isNotEmpty;
  }

  Future<int?> getVendedorId() async {
    return await _localStorage.getVendedorId();
  }
}
