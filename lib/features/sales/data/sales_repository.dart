import 'dart:async';
import 'package:dio/dio.dart';
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
      String? ultimoError;
      for (final v in todas) {
        final result = await _uploadSaleWithRetry(v);
        if (result == 'OK') {
          await db.ventaDao.updateEstado(v.ventaMovilId, 'enviada');
          enviadas++;
        } else {
          ultimoError = result;
          await db.ventaDao.updateEstado(v.ventaMovilId, 'error');
        }
      }

      if (ultimoError != null && enviadas == 0) {
        return SyncFailure(mensaje: ultimoError);
      }
      return SyncSuccess(clientes: 0, productos: enviadas);
    } catch (e) {
      return SyncFailure(mensaje: e.toString());
    }
  }

  Future<String> _uploadSaleWithRetry(VentaPendiente v) async {
    const maxRetries = 1; // Reducido a 1 para no esperar tanto al debugear
    const delays = [Duration(seconds: 2)];

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        final success = await _uploadSale(v);
        if (success) return 'OK';
      } catch (e) {
        if (attempt == maxRetries - 1) return e.toString();
      }
      if (attempt < maxRetries - 1) {
        await Future.delayed(delays[attempt]);
      }
    }
    return 'Error desconocido';
  }

  Future<bool> _uploadSale(VentaPendiente v) async {
    try {
      final List<Map<String, dynamic>> details = v.detalles.map((d) => {
        'articulo_id': d['articulo_id'] as int,
        'unidades': (d['unidades'] as num).toDouble(),
        'precio_unitario': (d['precio_unitario'] as num).toDouble(),
      }).toList();

      final response = await _dioClient.dio.post('/api/v1/ventas', data: {
        'venta_movil_id': v.ventaMovilId,
        'vendedor_id': v.vendedorId,
        'cliente_id': v.clienteId,
        'fecha_hora': v.fechaHora,
        'notas': 'Pedido Móvil',
        'detalles': details,
      });

      return response.statusCode == 200 || response.statusCode == 201;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception('API ERROR: ${e.response?.statusCode} - ${e.response?.data}');
      }
      throw Exception('NETWORK ERROR: ${e.message}');
    } catch (e) {
      throw Exception('APP ERROR: $e');
    }
  }
}
