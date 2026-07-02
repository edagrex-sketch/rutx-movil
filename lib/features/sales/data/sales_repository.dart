import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/entities/venta_pendiente_entity.dart';
import '../../../../core/network/connectivity_service.dart';

class SalesRepository {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
  ));
  
  final ConnectivityService _connectivityService = ConnectivityService();

  Future<bool> saveSaleLocally(VentaPendiente venta) async {
    try {
      final db = AppDatabase();
      await db.initialize();
      await db.ventaDao.insert(venta);
      
      // Intentar sincronizar de inmediato de forma asíncrona
      syncPendingSales();
      
      return true;
    } catch (e) {
      print('Error al guardar venta localmente: $e');
      return false;
    }
  }

  Future<void> syncPendingSales() async {
    final connected = await _connectivityService.isConnected();
    if (!connected) return;

    try {
      final db = AppDatabase();
      await db.initialize();
      final pendientes = await db.ventaDao.getPendientes();
      
      for (final v in pendientes) {
        final success = await _uploadSale(v);
        if (success) {
          await db.ventaDao.updateEstado(v.ventaMovilId, 'enviada');
        } else {
          // Si falla con error de validación o del servidor, se marca como error
          await db.ventaDao.updateEstado(v.ventaMovilId, 'error');
        }
      }
    } catch (e) {
      print('Error en cola de sincronización de ventas: $e');
    }
  }

  Future<bool> _uploadSale(VentaPendiente v) async {
    try {
      final List<Map<String, dynamic>> details = v.detalles.map((d) => {
        'articulo_id': d['articulo_id'] as int,
        'unidades': (d['unidades'] as num).toDouble(),
        'precio_unitario': (d['precio_unitario'] as num).toDouble(),
      }).toList();

      final response = await _dio.post('/api/v1/ventas', data: {
        'venta_movil_id': v.ventaMovilId,
        'vendedor_id': v.vendedorId,
        'cliente_id': v.clienteId,
        'fecha_hora': v.fechaHora,
        'notas': 'Pedido Móvil',
        'detalles': details,
      });

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error al subir venta ${v.ventaMovilId}: $e');
      return false;
    }
  }
}
