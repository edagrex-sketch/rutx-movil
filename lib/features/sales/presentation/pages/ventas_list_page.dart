import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/network/sync_result.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/database/entities/venta_pendiente_entity.dart';
import '../../../../shared/widgets/sale_card.dart';
import '../../data/sales_repository.dart';
import 'venta_detalle_page.dart';

class VentasListPage extends StatefulWidget {
  const VentasListPage({Key? key}) : super(key: key);

  @override
  State<VentasListPage> createState() => _VentasListPageState();
}

class _VentasListPageState extends State<VentasListPage> {
  List<VentaPendiente> _ventas = [];
  bool _isLoading = true;
  int _totalVentas = 0;
  double _montoTotal = 0.0;

  @override
  void initState() {
    super.initState();
    _loadVentas();
  }

  Future<void> _loadVentas() async {
    final dbService = DatabaseService();
    await dbService.initialize();
    
    // Intentar sincronizar primero para ver los errores
    final result = await SalesRepository().syncPendingSales();
    if (result is SyncFailure && mounted) {
      final friendlyMessage = _getFriendlyErrorMessage(result.mensaje);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(friendlyMessage, maxLines: 3),
          backgroundColor: Colors.redAccent,
          duration: const Duration(seconds: 5),
          behavior: SnackBarBehavior.floating, // Se ve más moderno
        ),
      );
    }

    // Obtenemos la fecha de hoy en formato YYYY-MM-DD
    final String hoy = DateTime.now().toIso8601String().substring(0, 10);
    
    final list = await dbService.obtenerVentasDelDia(hoy);
    final resumen = await dbService.obtenerResumenDelDia(hoy);
    
    if (mounted) {
      setState(() {
        _ventas = list;
        _totalVentas = resumen['total_ventas'] ?? 0;
        _montoTotal = (resumen['monto_total'] ?? 0.0).toDouble();
        _isLoading = false;
      });
    }
  }

  // Lógica de color de estado eliminada: ahora vive en SaleCard._resolveStatusStyle()

  // ---------------------------------------------------------------------------
  // Traducción de Errores para el Usuario Final
  // ---------------------------------------------------------------------------
  String _getFriendlyErrorMessage(String technicalError) {
    if (technicalError.contains('NETWORK ERROR') || technicalError.contains('Sin conexión')) {
      return 'Venta guardada localmente. Se enviará automáticamente cuando recuperes la conexión.';
    } else if (technicalError.contains('API ERROR')) {
      return 'Ocurrió un problema al registrar la venta en las oficinas. Por favor, repórtalo a sistemas.';
    } else if (technicalError.contains('APP ERROR')) {
      return 'Algo salió mal en la aplicación. Intenta cerrarla y volverla a abrir.';
    }
    return 'No se pudo sincronizar la venta. Se seguirá intentando en segundo plano.';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
            color: AppTheme.primaryColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Historial de Ventas',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Ventas', style: TextStyle(color: AppTheme.lightGrey, fontSize: 14)),
                        Text('$_totalVentas', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Monto Total', style: TextStyle(color: AppTheme.lightGrey, fontSize: 14)),
                        Text('\$${_montoTotal.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
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
                            return SaleCard(
                              venta: _ventas[index],
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VentaDetallePage(venta: _ventas[index]),
                                  ),
                                );
                              },
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
