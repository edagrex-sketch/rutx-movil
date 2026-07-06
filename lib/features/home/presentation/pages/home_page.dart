import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../../features/catalog/presentation/pages/clientes_page.dart';
import '../../../../features/catalog/presentation/pages/catalogo_page.dart';
import '../../../../features/sales/presentation/pages/ventas_list_page.dart';
import '../../../../features/summary/presentation/pages/resumen_dia_page.dart';
import '../../../../features/sales/presentation/pages/nueva_venta_page.dart';
import '../../../../core/database/entities/cliente_entity.dart';
import '../../../../features/notifications/presentation/pages/notifications_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isConnected = true;

  // Dashboard Stats
  int _visitedCount = 0;
  int _totalClientes = 6; // Default fallback
  double _ventasTotalAmount = 0.0;
  int _pendingSalesCount = 0;
  bool _isLoadingStats = true;
  Cliente? _nextCliente;

  @override
  void initState() {
    super.initState();
    _setupConnectivity();
    _loadDashboardStats();
  }

  void _setupConnectivity() {
    _connectivityService.connectionStream.listen((connected) {
      if (mounted) {
        setState(() => _isConnected = connected);
      }
    });
    _connectivityService.isConnected().then((connected) {
      if (mounted) {
        setState(() => _isConnected = connected);
      }
    });
  }

  Future<void> _loadDashboardStats() async {
    if (!mounted) return;
    setState(() => _isLoadingStats = true);
    
    final db = AppDatabase();
    await db.initialize();
    
    final allClients = await db.clienteDao.getAll();
    final totalClients = allClients.length;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final resumen = await db.ventaDao.getResumenDelDia(today);
    
    Cliente? next;
    for (final c in allClients) {
      if (c.nombreCliente.contains('Don Pepe')) {
        next = c;
        break;
      }
    }
    next ??= allClients.isNotEmpty ? allClients.first : null;
    
    if (mounted) {
      setState(() {
        _totalClientes = totalClients > 0 ? totalClients : 6;
        _visitedCount = resumen['total_ventas'] as int? ?? 0;
        _ventasTotalAmount = (resumen['monto_total'] as num? ?? 0.0).toDouble();
        _pendingSalesCount = resumen['pendientes'] as int? ?? 0;
        _nextCliente = next;
        _isLoadingStats = false;
      });
    }
  }

  Widget _buildQuickAction({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor),
            ),
            const Spacer(),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeDashboard() {
    final progress = _totalClientes > 0 ? _visitedCount / _totalClientes : 0.0;
    
    return RefreshIndicator(
      onRefresh: _loadDashboardStats,
      color: AppTheme.accentColor,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppTheme.primaryColor,
            pinned: true,
            expandedHeight: 120,
            toolbarHeight: 80,
            automaticallyImplyLeading: false,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Buenos días,', style: TextStyle(color: AppTheme.secondaryColor, fontSize: 14)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Carlos Ríos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _isConnected ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Icon(_isConnected ? Icons.wifi : Icons.wifi_off, color: _isConnected ? Colors.green : Colors.red, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                _isConnected ? 'Con señal' : 'Sin señal',
                                style: TextStyle(color: _isConnected ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        Stack(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.notifications_none, color: Colors.white, size: 28),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const NotificationsPage()),
                                );
                              },
                            ),
                            Positioned(
                              right: 6,
                              top: 6,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: const Center(
                                  child: Text(
                                    '2',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(40),
              child: Padding(
                padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined, color: AppTheme.secondaryColor, size: 16),
                    const SizedBox(width: 4),
                    const Text('Ruta Zona Norte', style: TextStyle(color: AppTheme.secondaryColor, fontSize: 14)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('•', style: TextStyle(color: AppTheme.secondaryColor)),
                    ),
                    const Icon(Icons.calendar_today_outlined, color: AppTheme.secondaryColor, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      DateTime.now().toIso8601String().substring(0, 10),
                      style: const TextStyle(color: AppTheme.secondaryColor, fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Clientes visitados', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                              const SizedBox(height: 8),
                              RichText(
                                text: TextSpan(
                                  text: '$_visitedCount',
                                  style: const TextStyle(color: AppTheme.textPrimary, fontSize: 28, fontWeight: FontWeight.bold),
                                  children: [
                                    TextSpan(text: '/$_totalClientes', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16, fontWeight: FontWeight.normal)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: progress.isNaN ? 0.0 : progress,
                                  backgroundColor: AppTheme.lightGrey,
                                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
                                  minHeight: 6,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Ventas del día', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                              const SizedBox(height: 8),
                              Text('\$${_ventasTotalAmount.toStringAsFixed(0)}', style: const TextStyle(color: AppTheme.textPrimary, fontSize: 28, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 12),
                              Text('$_visitedCount visitas registradas', style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  if (_pendingSalesCount > 0) ...[
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () => setState(() => _selectedIndex = 4), // Go to summary
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1), // Light yellow
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFECB3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: Color(0xFFF57C00)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Tienes $_pendingSalesCount ${_pendingSalesCount == 1 ? "venta pendiente" : "ventas pendientes"}', style: const TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.bold)),
                                  const Text('Se enviarán cuando haya señal', style: TextStyle(color: Color(0xFFE65100), fontSize: 13)),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: Color(0xFFF57C00)),
                          ],
                        ),
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  const Text('ACCIONES RÁPIDAS', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _buildQuickAction(
                        title: 'Clientes',
                        subtitle: '$_totalClientes en ruta',
                        icon: Icons.people_outline,
                        iconColor: const Color(0xFF1565C0),
                        bgColor: const Color(0xFFE3F2FD),
                        onTap: () => setState(() => _selectedIndex = 1),
                      ),
                      _buildQuickAction(
                        title: 'Nueva venta',
                        subtitle: 'Registrar pedido',
                        icon: Icons.shopping_cart_outlined,
                        iconColor: const Color(0xFFE65100),
                        bgColor: const Color(0xFFFBE9E7),
                        onTap: () async {
                          final activeCliente = _nextCliente ?? Cliente(
                            clienteId: 3,
                            nombreCliente: 'Tienda Don Pepe',
                            calle: 'Av. Siempre Viva 123',
                            colonia: 'Centro',
                            codigoPostal: '37000',
                            limiteCredito: 5000.0,
                          );
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NuevaVentaPage(cliente: activeCliente),
                            ),
                          );
                          if (result == true) {
                            _loadDashboardStats();
                          }
                        },
                      ),
                      _buildQuickAction(
                        title: 'Catálogo',
                        subtitle: 'Productos',
                        icon: Icons.inventory_2_outlined,
                        iconColor: const Color(0xFF0277BD),
                        bgColor: const Color(0xFFE1F5FE),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CatalogoPage(),
                            ),
                          );
                        },
                      ),
                      _buildQuickAction(
                        title: 'Resumen',
                        subtitle: 'Cierre de jornada',
                        icon: Icons.assignment_outlined,
                        iconColor: const Color(0xFFC62828),
                        bgColor: const Color(0xFFFFEBEE),
                        onTap: () => setState(() => _selectedIndex = 4),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  const Text('PRÓXIMO CLIENTE', style: TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: AppTheme.accentColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Text('DP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Tienda Don Pepe', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary)),
                              SizedBox(height: 4),
                              Text('Av. Siempre Viva 123', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                            ],
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, color: AppTheme.textSecondary),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () => setState(() => _selectedIndex = 4), // Go to summary
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEBF5FE),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFD2E8FC)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.trending_up, color: Color(0xFF005691)),
                          SizedBox(width: 8),
                          Text(
                            'Ver resumen y cerrar jornada',
                            style: TextStyle(
                              color: Color(0xFF005691),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
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

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomeDashboard(),
      const ClientesPage(),
      const ClientesPage(), // Selecting vender sends to Clientes page
      const VentasListPage(),
      const ResumenDiaPage(),
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) async {
          if (index == 2) {
            final activeCliente = _nextCliente ?? Cliente(
              clienteId: 3,
              nombreCliente: 'Tienda Don Pepe',
              calle: 'Av. Siempre Viva 123',
              colonia: 'Centro',
              codigoPostal: '37000',
              limiteCredito: 5000.0,
            );
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NuevaVentaPage(cliente: activeCliente),
              ),
            );
            if (result == true) {
              _loadDashboardStats();
            }
          } else {
            setState(() {
              _selectedIndex = index;
            });
            _loadDashboardStats();
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.primaryColor,
        selectedItemColor: AppTheme.accentColor,
        unselectedItemColor: AppTheme.secondaryColor,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Inicio'),
          const BottomNavigationBarItem(icon: Icon(Icons.people_outline), label: 'Clientes'),
          BottomNavigationBarItem(
            icon: Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppTheme.accentColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
            ),
            label: 'Vender',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), label: 'Ventas'),
          const BottomNavigationBarItem(icon: Icon(Icons.more_horiz), label: 'Más'),
        ],
      ),
    );
  }
}
