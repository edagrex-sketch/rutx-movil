import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/entities/venta_pendiente_entity.dart';

class VentasListPage extends StatefulWidget {
  const VentasListPage({Key? key}) : super(key: key);

  @override
  State<VentasListPage> createState() => _VentasListPageState();
}

class _VentasListPageState extends State<VentasListPage> {
  List<VentaPendiente> _ventas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVentas();
  }

  Future<void> _loadVentas() async {
    final db = AppDatabase();
    await db.initialize();
    final list = await db.ventaDao.getAll();
    if (mounted) {
      setState(() {
        _ventas = list;
        _isLoading = false;
      });
    }
  }

  Color _getStatusTextColor(String status) {
    if (status == 'enviada') return Colors.green;
    if (status == 'pendiente') return const Color(0xFFF57C00);
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
            color: AppTheme.primaryColor,
            child: const Text(
              'Historial de Ventas',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.accentColor))
                : _ventas.isEmpty
                    ? const Center(
                        child: Text('No hay ventas registradas hoy.', style: TextStyle(color: AppTheme.textSecondary)),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadVentas,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _ventas.length,
                          itemBuilder: (context, index) {
                            final v = _ventas[index];
                            final articulos = v.detalles.length;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.lightGrey),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        v.clienteNombre,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Hora: ${v.fechaHora.substring(11, 16)} · Estado: ${v.estado.toUpperCase()}',
                                        style: TextStyle(color: _getStatusTextColor(v.estado), fontSize: 13, fontWeight: FontWeight.bold),
                                      ),
                                      if (articulos > 0)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 2),
                                          child: Text(
                                            '$articulos artículo${articulos == 1 ? '' : 's'}',
                                            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                                          ),
                                        ),
                                    ],
                                  ),
                                  Text(
                                    '\$${v.total.toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
