import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../constants/api_constants.dart';
import '../storage/local_storage.dart';
import '../../app/app.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../shared/widgets/feedback_utils.dart';
import '../errors/app_error.dart';

class DioClient {
  static final DioClient _instance = DioClient._();
  factory DioClient() => _instance;
  DioClient._();

  final LocalStorage _storage = LocalStorage();
  Dio? _dio;

  Dio get dio {
    if (_dio == null) {
      _dio = Dio(_createOptions());
      _dio!.interceptors.add(_authInterceptor());
    }
    return _dio!;
  }

  BaseOptions _createOptions() => BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      );

  InterceptorsWrapper _authInterceptor() => InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Token expirado o inválido
            await _storage.clearSession();
            
            final context = navigatorKey.currentContext;
            if (context != null && context.mounted) {
              showError(
                context, 
                AppError(
                  mensajeUsuario: 'Tu sesión ha caducado. Por favor, inicia sesión de nuevo.', 
                  esRecuperable: true
                )
              );
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            }
          }
          handler.next(error);
        },
      );
}
