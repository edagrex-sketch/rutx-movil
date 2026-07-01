import 'dart:convert';

class VentaPendiente {
  final String ventaMovilId;
  final int vendedorId;
  final int clienteId;
  final String clienteNombre;
  final String fechaHora;
  final String estado;
  final double total;
  final List<Map<String, dynamic>> detalles;

  VentaPendiente({
    required this.ventaMovilId,
    required this.vendedorId,
    required this.clienteId,
    required this.clienteNombre,
    required this.fechaHora,
    this.estado = 'pendiente',
    this.total = 0.0,
    this.detalles = const [],
  });

  Map<String, dynamic> toMap() => {
        'venta_movil_id': ventaMovilId,
        'vendedor_id': vendedorId,
        'cliente_id': clienteId,
        'cliente_nombre': clienteNombre,
        'fecha_hora': fechaHora,
        'estado': estado,
        'total': total,
        'detalles_json': jsonEncode(detalles),
      };

  factory VentaPendiente.fromMap(Map<String, dynamic> map) => VentaPendiente(
        ventaMovilId: map['venta_movil_id'] as String,
        vendedorId: map['vendedor_id'] as int,
        clienteId: map['cliente_id'] as int,
        clienteNombre: map['cliente_nombre'] as String,
        fechaHora: map['fecha_hora'] as String,
        estado: map['estado'] as String? ?? 'pendiente',
        total: (map['total'] as num?)?.toDouble() ?? 0.0,
        detalles: _parseDetalles(map['detalles_json'] as String?),
      );

  static List<Map<String, dynamic>> _parseDetalles(String? json) {
    if (json == null || json.isEmpty) return [];
    try {
      return (jsonDecode(json) as List).cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }
}
