import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/entities/venta_pendiente_entity.dart';
import '../../../../core/storage/local_storage.dart';
import '../../data/summary_repository.dart';
import '../../../../features/auth/presentation/pages/login_page.dart';
import '../../../../features/sales/data/sales_repository.dart';
import '../../../../shared/widgets/summary_metrics_card.dart';
import '../../../../shared/widgets/sale_card.dart';

class ResumenDiaPage extends StatefulWidget {
  const ResumenDiaPage({Key? key}) : super(key: key);

  @override
  State<ResumenDiaPage> createState() => _ResumenDiaPageState();
}

class _ResumenDiaPageState extends State<ResumenDiaPage> {
  final SalesRepository _salesRepository = SalesRepository();
  final SummaryRepository _summaryRepository = SummaryRepository();

  List<VentaPendiente> _ventas = [];
  bool _isLoading = true;
  bool _isSyncing = false;

  int _pendientesCount = 0;
  
  // Variables de métricas
  double _montoTotal = 0.0;
  int _totalVentas = 0;
  int _piezasVendidas = 0;

  @override
  void initState() {
    super.initState();
    _loadVentas();
  }

  Future<void> _loadVentas() async {
    setState(() => _isLoading = true);
    try {
      final db = AppDatabase();
      await db.initialize();

      final today = DateTime.now().toIso8601String().substring(0, 10);
      final list = await db.ventaDao.getDelDia(today);
      final resumen = await db.ventaDao.getResumenDelDia(today);

      int pendientes = 0;
      for (final v in list) {
        if (v.estado == 'pendiente' || v.estado == 'error') {
          pendientes++;
        }
      }

      if (mounted) {
        setState(() {
          _ventas = list;
          _pendientesCount = pendientes;
          _montoTotal = (resumen['monto_total'] as num?)?.toDouble() ?? 0.0;
          _totalVentas = (resumen['total_ventas'] as num?)?.toInt() ?? 0;
          _piezasVendidas = (resumen['piezas_vendidas'] as num?)?.toInt() ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleSync() async {
    setState(() => _isSyncing = true);
    await _salesRepository.syncPendingSales();
    await _loadVentas();
    if (mounted) {
      setState(() => _isSyncing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_pendientesCount > 0 
            ? 'Aún hay ventas sin sincronizar. Verifica que los clientes existan en el servidor.'
            : 'Sincronización completada'),
          backgroundColor: _pendientesCount > 0 ? Colors.orange : Colors.green,
        ),
      );
    }
  }

  void _clearOldSales() async {
    final db = AppDatabase();
    await db.initialize();
    await db.ventaDao.deleteAll();
    await _loadVentas();
  }

  void _handleCerrarJornada() async {
    try {
      if (_pendientesCount > 0) {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Ventas pendientes'),
            content: Text(
              'Tienes $_pendientesCount ventas pendientes de sincronizar. '
              'Si cierras la jornada ahora, se perderán permanentemente. ¿Deseas continuar?'
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                child: const Text('Sí, perder datos y cerrar'),
              ),
            ],
          ),
        );
        if (confirm != true) return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Procesando cierre de jornada...'),
          duration: Duration(seconds: 1),
        ),
      );

      final db = AppDatabase();
      await db.initialize();
      
      try {
        await _summaryRepository.sendClosingData(7, _ventas);
      } catch (e) {
        print('Error al enviar datos de cierre al servidor: $e');
      }

      await db.limpiarDatosDelDia();
      await LocalStorage().clearToken();
      await LocalStorage().setSyncData(false);

      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      print('Error al cerrar jornada: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cerrar jornada: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
          children: [
            // Cabecera: Contenedor de Métricas Reutilizable
            SummaryMetricsCard(
              totalVentas: _montoTotal,
              clientesVisitados: _totalVentas,
              piezasVendidas: _piezasVendidas,
            ),
            
            // Cuerpo: Lista de Ventas
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppTheme.accentColor))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'VENTAS DEL DÍA',
                            style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                          ),
                          const SizedBox(height: 12),
                          
                          _ventas.isEmpty
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(vertical: 24.0),
                                    child: Text('No has registrado ventas hoy.', style: TextStyle(color: AppTheme.textSecondary)),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: _ventas.length,
                                  itemBuilder: (context, index) {
                                    return SaleCard(venta: _ventas[index]);
                                  },
                                ),
                          
                          const SizedBox(height: 16),
                          
                          // Alerta de Ventas Pendientes
                          if (_pendientesCount > 0) ...[
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppTheme.accentColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.accentColor.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.warning_amber_rounded, color: AppTheme.accentColor, size: 28),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Tienes $_pendientesCount ${_pendientesCount == 1 ? "venta pendiente" : "ventas pendientes"}',
                                          style: const TextStyle(color: AppTheme.accentColor, fontWeight: FontWeight.bold, fontSize: 15),
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'Haz la sincronización final antes de cerrar para no perder datos.',
                                          style: TextStyle(color: AppTheme.accentColor, fontSize: 13),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
            ),
          ],
      ),
      
      // Bottom Sticky Area: Sincronización y Cierre
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20).copyWith(
          bottom: MediaQuery.of(context).padding.bottom > 0 ? MediaQuery.of(context).padding.bottom : 20
        ),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          boxShadow: [
            BoxShadow(
              color: AppTheme.textPrimary.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            )
          ]
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Botón de Sincronización
            if (_isSyncing)
              const Center(child: CircularProgressIndicator(color: AppTheme.accentColor))
            else
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _pendientesCount > 0 ? _handleSync : null,
                  icon: Icon(
                    _pendientesCount > 0 ? Icons.sync : Icons.check_circle_outline, 
                    color: _pendientesCount > 0 ? AppTheme.accentColor : AppTheme.textSecondary,
                  ),
                  label: Text(
                    _pendientesCount > 0 ? 'Sincronización final' : 'Todo sincronizado',
                    style: TextStyle(
                      color: _pendientesCount > 0 ? AppTheme.accentColor : AppTheme.textSecondary, 
                      fontSize: 16, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: _pendientesCount > 0 ? AppTheme.accentColor.withOpacity(0.5) : AppTheme.lightGrey, 
                      width: 1.5,
                    ),
                    backgroundColor: _pendientesCount > 0 ? AppTheme.accentColor.withOpacity(0.1) : AppTheme.backgroundColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            
            // Botón de Cerrar Jornada
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _handleCerrarJornada,
                icon: const Icon(Icons.exit_to_app, color: AppTheme.surfaceColor),
                label: const Text(
                  'Cerrar jornada',
                  style: TextStyle(color: AppTheme.surfaceColor, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            
            // Opción de limpieza (Oculta/Pequeña para uso esporádico o Dev)
            TextButton(
              onPressed: _clearOldSales,
              child: Text('Borrar ventas viejas', style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}
