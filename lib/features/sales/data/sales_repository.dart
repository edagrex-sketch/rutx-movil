import 'dart:async';
import '../../../core/database/app_database.dart';
import '../../../core/database/entities/venta_pendiente_entity.dart';
import '../../../core/network/connectivity_service.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/sync_result.dart';

class SalesRepository {
  static final SalesRepository _instance = SalesRepository._();
  factory SalesRepository() => _instance;
  SalesRepository._();

  final ConnectivityService _connectivityService = ConnectivityService();
  final DioClient _dioClient = DioClient();

  Future<bool> saveSaleLocally(VentaPendiente venta) async {
    try {
      final db = AppDatabase();
      await db.initialize();
      await db.ventaDao.insert(venta);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<SyncResult> syncPendingSales() async {
    final connected = await _connectivityService.isConnected();
    if (!connected) return SyncFailure(mensaje: 'Sin conexión');

    try {
      final db = AppDatabase();
      await db.initialize();
      final pendientes = await db.ventaDao.getPendientes();
      final errores = await db.ventaDao.getByEstado('error');
      final todas = [...pendientes, ...errores];

      if (todas.isEmpty) return SyncSuccess(clientes: 0, productos: 0);

      int enviadas = 0;
      for (final v in todas) {
        final result = await _uploadSaleWithRetry(v);
        if (result) {
          await db.ventaDao.updateEstado(v.ventaMovilId, 'enviada');
          enviadas++;
        } else {
          await db.ventaDao.updateEstado(v.ventaMovilId, 'error');
        }
      }

      return SyncSuccess(clientes: 0, productos: enviadas);
    } catch (e) {
      return SyncFailure(mensaje: e.toString());
    }
  }

  Future<bool> _uploadSaleWithRetry(VentaPendiente v) async {
    const maxRetries = 3;
    const delays = [Duration(seconds: 2), Duration(seconds: 4), Duration(seconds: 8)];

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      final success = await _uploadSale(v);
      if (success) return true;
      if (attempt < maxRetries - 1) {
        await Future.delayed(delays[attempt]);
      }
    }
    return false;
  }

  Future<bool> _uploadSale(VentaPendiente v) async {
    try {
      final List<Map<String, dynamic>> details = v.detalles.map((d) => {
        'articulo_id': d['articulo_id'] as int,
        'nombre': d['nombre'] as String? ?? '',
        'unidades': (d['unidades'] as num).toDouble(),
        'precio_unitario': (d['precio_unitario'] as num).toDouble(),
      }).toList();

      final response = await _dioClient.dio.post('/api/v1/ventas', data: {
        'venta_movil_id': v.ventaMovilId,
        'vendedor_id': v.vendedorId,
        'cliente_id': v.clienteId,
        'cliente_nombre': v.clienteNombre,
        'fecha_hora': v.fechaHora,
        'notas': 'Pedido Móvil',
        'detalles': details,
      });

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }
}
