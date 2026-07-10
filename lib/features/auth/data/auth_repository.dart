import 'package:dio/dio.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/app_error.dart';

class AuthRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
  final LocalStorage _localStorage = LocalStorage();

  Future<AppError?> login(String username, String password, bool rememberMe) async {
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
      return AppError(mensajeUsuario: 'Credenciales incorrectas.', esRecuperable: false);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return AppError(mensajeUsuario: 'El servidor no responde. Verifica tu conexión.', esRecuperable: true);
      }
      if (e.type == DioExceptionType.connectionError) {
        return AppError(mensajeUsuario: 'Sin conexión al servidor. Asegúrate de que el Sincronizador esté encendido.', esRecuperable: true);
      }
      if (e.response?.statusCode == 401) {
        return AppError(mensajeUsuario: 'Usuario o contraseña incorrectos.', esRecuperable: false);
      }
      // Consider bad response (503, 500) as recoverable network errors
      if (e.response?.statusCode == 503 || e.response?.statusCode == 500) {
        return AppError(mensajeUsuario: 'El servidor está temporalmente fuera de servicio.', esRecuperable: true);
      }
      return AppError(mensajeUsuario: 'Error al iniciar sesión. Intenta de nuevo.', esRecuperable: true);
    } catch (_) {
      return AppError(mensajeUsuario: 'Error inesperado. Intenta de nuevo.', esRecuperable: true);
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
