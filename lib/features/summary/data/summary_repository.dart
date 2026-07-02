import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/database/entities/venta_pendiente_entity.dart';

class SummaryRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));

  Future<bool> sendClosingData(int vendedorId, List<VentaPendiente> ventas) async {
    try {
      final response = await _dio.post('/api/v1/sync/closing', data: {
        'vendedor_id': vendedorId,
        'ruta_activa': 'Ruta Centro',
        'fecha_hora': DateTime.now().toIso8601String(),
        'inventario_final': [
          {
            'articulo_id': 88,
            'unidades_restantes': 12.0,
          }
        ],
        'mermas': [],
        'devoluciones': [],
      });

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error en cierre de jornada en servidor: $e');
      return false; // Retornar false pero permitir cerrar jornada localmente
    }
  }
}
