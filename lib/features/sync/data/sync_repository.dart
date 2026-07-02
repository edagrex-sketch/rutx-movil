import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/entities/cliente_entity.dart';
import '../../../../core/database/entities/producto_entity.dart';

class SyncRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));

  Future<bool> downloadMorningData(int vendedorId) async {
    try {
      final response = await _dio.get('/api/v1/sync/morning/$vendedorId');
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        
        // Parsear clientes
        final List<dynamic> clientesJson = data['clientes'] ?? [];
        final List<Cliente> clientes = clientesJson.map((json) => Cliente(
          clienteId: json['cliente_id'] as int,
          nombreCliente: json['nombre_cliente'] as String,
          calle: json['calle'] as String?,
          colonia: json['colonia'] as String?,
          codigoPostal: json['codigo_postal'] as String?,
          limiteCredito: (json['limite_credito'] as num?)?.toDouble() ?? 0.0,
        )).toList();
        
        // Parsear productos
        final List<dynamic> productosJson = data['productos'] ?? [];
        final List<Producto> productos = productosJson.map((json) => Producto(
          articuloId: json['articulo_id'] as int,
          nombre: json['nombre'] as String,
          estatus: json['estatus'] as String? ?? 'A',
          clave: json['clave'] as String? ?? 'REF${(json['articulo_id'] as int).toString().padLeft(3, '0')}',
          precio: (json['precio'] as num?)?.toDouble() ?? (((json['articulo_id'] as int) % 5 + 2) * 5).toDouble(),
        )).toList();

        // Inicializar base de datos e insertar
        final db = AppDatabase();
        await db.initialize();
        
        // Limpiar datos previos e insertar nuevos
        await db.limpiarDatosDelDia();
        await db.clienteDao.insertAll(clientes);
        await db.productDao.insertAll(productos);
        
        return true;
      }
      return false;
    } catch (e) {
      print('Error en sincronización matutina: $e');
      return false;
    }
  }
}
