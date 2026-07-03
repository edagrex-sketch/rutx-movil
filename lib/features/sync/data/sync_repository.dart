import 'package:dio/dio.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/entities/cliente_entity.dart';
import '../../../../core/database/entities/producto_entity.dart';
import '../../../../core/network/sync_result.dart';

class SyncRepository {
  final Dio _dio;
  final AppDatabase _db;

  SyncRepository({Dio? dio, AppDatabase? db})
      : _dio = dio ?? _createDio(),
        _db = db ?? AppDatabase();

  static Dio _createDio() {
    final d = Dio(BaseOptions(
      baseUrl: 'http://10.0.2.2:5047',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
    ));
    return d;
  }

  Future<SyncResult> downloadMorningData(int vendedorId) async {
    final maxIntentos = 3;

    for (int intento = 1; intento <= maxIntentos; intento++) {
      try {
        final response = await _dio.get('/api/v1/sync/morning/$vendedorId');

        if (response.statusCode == 200 && response.data != null) {
          return await _procesarRespuesta(response.data);
        }

        if (intento < maxIntentos) {
          await _esperar(intento);
        }
      } on DioException catch (e) {
        if (_esErrorNoReintentable(e)) {
          return SyncFailure(
            mensaje: _mensajeError(e),
            intentos: intento,
          );
        }

        if (intento < maxIntentos) {
          await _esperar(intento);
        }
      } catch (e) {
        if (intento < maxIntentos) {
          await _esperar(intento);
        }
      }
    }

    return SyncFailure(
      mensaje: 'No se pudo completar la sincronización. Verifica tu conexión.',
      intentos: maxIntentos,
    );
  }

  Future<SyncResult> _procesarRespuesta(dynamic data) async {
    try {
      final List<dynamic> clientesJson = data['clientes'] ?? [];
      final List<dynamic> productosJson = data['productos'] ?? [];

      final clientes = clientesJson.map((json) => Cliente(
            clienteId: json['cliente_id'] as int,
            nombreCliente: json['nombre_cliente'] as String,
            calle: json['calle'] as String?,
            colonia: json['colonia'] as String?,
            codigoPostal: json['codigo_postal'] as String?,
            limiteCredito:
                (json['limite_credito'] as num?)?.toDouble() ?? 0.0,
          )).toList();

      final productos = productosJson.map((json) {
        final id = json['articulo_id'] as int;
        return Producto(
          articuloId: id,
          nombre: json['nombre'] as String,
          estatus: json['estatus'] as String? ?? 'A',
          clave: json['clave'] as String? ?? 'REF${id.toString().padLeft(3, '0')}',
          precio: (json['precio'] as num?)?.toDouble() ??
              ((id % 5 + 2) * 5).toDouble(),
        );
      }).toList();

      await _db.limpiarDatosDelDia();
      await _db.clienteDao.insertAll(clientes);
      await _db.productDao.insertAll(productos);

      return SyncSuccess(
        clientes: clientes.length,
        productos: productos.length,
      );
    } catch (e) {
      return SyncFailure(
        mensaje: 'Error al guardar los datos locales.',
        intentos: 3,
      );
    }
  }

  bool _esErrorNoReintentable(DioException e) {
    return e.response != null && e.response!.statusCode == 401;
  }

  String _mensajeError(DioException e) {
    if (e.response != null) {
      final codigo = e.response!.statusCode;
      if (codigo == 401) return 'Sesión expirada. Inicia sesión de nuevo.';
      if (codigo == 404) return 'Ruta no encontrada para este vendedor.';
      return 'Error del servidor ($codigo).';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'El servidor no respondió a tiempo.';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Sin conexión al servidor. Verifica tu conexión.';
    }
    return 'Error de conexión.';
  }

  Future<void> _esperar(int intento) async {
    final segundos = [2, 4, 8][intento - 1];
    await Future.delayed(Duration(seconds: segundos));
  }
}
