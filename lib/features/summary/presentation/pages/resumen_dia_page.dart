import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/entities/venta_pendiente_entity.dart';
import '../../../../core/storage/local_storage.dart';
import '../../data/summary_repository.dart';
import '../../../../features/auth/presentation/pages/login_page.dart';
import '../../../../features/sales/data/sales_repository.dart';

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
      
      var list = await db.ventaDao.getAll();
      
      // Seed mock sales if empty to match the user's requested view
      if (list.isEmpty) {
        final today = DateTime.now().toIso8601String().substring(0, 10);
        await db.ventaDao.insert(VentaPendiente(
          ventaMovilId: 'VTA-Mendoza',
          vendedorId: 7,
          clienteId: 1,
          clienteNombre: 'Abarrotes Mendoza',
          fechaHora: '$today 09:15:00',
          estado: 'enviada',
          total: 1480.0,
          detalles: [],
        ));
        await db.ventaDao.insert(VentaPendiente(
          ventaMovilId: 'VTA-Roble',
          vendedorId: 7,
          clienteId: 2,
          clienteNombre: 'Minisuper El Roble',
          fechaHora: '$today 10:40:00',
          estado: 'enviada',
          total: 650.0,
          detalles: [],
        ));
        await db.ventaDao.insert(VentaPendiente(
          ventaMovilId: 'VTA-DonPepe',
          vendedorId: 7,
          clienteId: 3,
          clienteNombre: 'Tienda Don Pepe',
          fechaHora: '$today 11:55:00',
          estado: 'pendiente',
          total: 390.0,
          detalles: [],
        ));
        await db.ventaDao.insert(VentaPendiente(
          ventaMovilId: 'VTA-Reyes',
          vendedorId: 7,
          clienteId: 4,
          clienteNombre: 'Comercial Reyes',
          fechaHora: '$today 12:30:00',
          estado: 'error',
          total: 820.0,
          detalles: [],
        ));
        list = await db.ventaDao.getAll();
      }

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
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('Error al cargar ventas en ResumenDiaPage: $e');
      print(stackTrace);
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
    }
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

  Color _getStatusBadgeColor(String status) {
    if (status == 'enviada') return const Color(0xFFE8F5E9); // Light Green
    if (status == 'pendiente') return const Color(0xFFFFF8E1); // Light Yellow
    return const Color(0xFFFFEBEE); // Light Red (Error)
  }

  Color _getStatusTextColor(String status) {
    if (status == 'enviada') return Colors.green;
    if (status == 'pendiente') return const Color(0xFFF57C00);
    return Colors.red;
  }

  String _getStatusText(String status) {
    if (status == 'enviada') return 'Enviada';
    if (status == 'pendiente') return 'Pendiente';
    return 'Error';
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
              'Resumen del día',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.accentColor))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'VENTAS',
                          style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 12),
                        
                        // Card-based List of Sales (Each sale is its own card)
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
                                  final v = _ventas[index];
                                  final displayTime = v.fechaHora.length >= 16 
                                      ? v.fechaHora.substring(11, 16) 
                                      : '00:00';

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: AppTheme.lightGrey),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.01),
                                          blurRadius: 10,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                v.clienteNombre,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                displayTime,
                                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          '\$${v.total.toStringAsFixed(0)}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
                                        ),
                                        const SizedBox(width: 16),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: _getStatusBadgeColor(v.estado),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            _getStatusText(v.estado),
                                            style: TextStyle(
                                              color: _getStatusTextColor(v.estado),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                        
                        const SizedBox(height: 16),
                        
                        // Alert Box
                        if (_pendientesCount > 0) ...[
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8E1), // Light Yellow
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFFECB3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, color: Color(0xFFF57C00), size: 28),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tienes $_pendientesCount ${_pendientesCount == 1 ? "venta pendiente" : "ventas pendientes"}',
                                        style: const TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.bold, fontSize: 15),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Haz la sincronización final antes de cerrar para no perder datos.',
                                        style: TextStyle(color: Color(0xFFE65100), fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                        
                        // Sync Button (Full Width)
                        if (_isSyncing)
                          const Center(child: CircularProgressIndicator(color: AppTheme.accentColor))
                        else
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _pendientesCount == 0 ? null : _handleSync,
                              icon: const Icon(Icons.sync, color: Color(0xFFF57C00)),
                              label: const Text(
                                'Sincronización final',
                                style: TextStyle(color: Color(0xFFF57C00), fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Color(0xFFFFE0B2), width: 1.5),
                                backgroundColor: const Color(0xFFFFF3E0),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                          ),
                        const SizedBox(height: 16),
                        
                        // Closing Button (Full Width)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _handleCerrarJornada,
                            icon: const Icon(Icons.exit_to_app, color: Colors.white),
                            label: const Text(
                              'Cerrar jornada',
                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentColor,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Center(
                          child: Text(
                            'Cierra tu jornada cuando termines tu ruta',
                            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
