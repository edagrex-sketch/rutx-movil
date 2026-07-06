import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/entities/cliente_entity.dart';
import '../../../../core/database/entities/venta_pendiente_entity.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../../sales/presentation/pages/nueva_venta_page.dart';

class ClientesPage extends StatefulWidget {
  const ClientesPage({Key? key}) : super(key: key);

  @override
  State<ClientesPage> createState() => _ClientesPageState();
}

class _ClientesPageState extends State<ClientesPage> {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isConnected = true;
  String _searchQuery = '';
  String _selectedFilter = 'Todos'; // 'Todos', 'Pendientes', 'Visitados'
  
  List<Cliente> _clientes = [];
  Map<int, VentaPendiente> _visitasMap = {}; // Maps clienteId -> VentaPendiente
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _setupConnectivity();
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

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final db = AppDatabase();
      await db.initialize();
      
      final clientesList = await db.clienteDao.getAll();
      clientesList.sort((a, b) => a.clienteId.compareTo(b.clienteId));
      final ventasList = await db.ventaDao.getAll();

      final Map<int, VentaPendiente> visitas = {};
      for (final v in ventasList) {
        visitas[v.clienteId] = v;
      }

      if (mounted) {
        setState(() {
          _clientes = clientesList;
          _visitasMap = visitas;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error al cargar clientes: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Cliente> _getFilteredClientes() {
    return _clientes.where((c) {
      final matchesSearch = c.nombreCliente.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (c.calle != null && c.calle!.toLowerCase().contains(_searchQuery.toLowerCase()));
      
      if (!matchesSearch) return false;

      final isVisited = _visitasMap.containsKey(c.clienteId);
      if (_selectedFilter == 'Pendientes') {
        return !isVisited;
      } else if (_selectedFilter == 'Visitados') {
        return isVisited;
      }
      return true;
    }).toList();
  }

  Color _getAvatarColor(int index) {
    final colors = [
      const Color(0xFF1565C0), // Dark Blue
      const Color(0xFFFF6D00), // Orange
      const Color(0xFF00B0FF), // Light Blue
      const Color(0xFF7C4DFF), // Purple
      const Color(0xFF00C853), // Green
      const Color(0xFFFFAB00), // Amber
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _getFilteredClientes();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // Top bar / Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
            color: AppTheme.primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Clientes de hoy',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _isConnected ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isConnected ? Icons.wifi : Icons.wifi_off,
                        color: _isConnected ? Colors.green : Colors.red,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isConnected ? 'Con señal' : 'Sin señal',
                        style: TextStyle(
                          color: _isConnected ? Colors.green : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Search & Filter Row
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Search bar
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Buscar cliente...',
                    prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Filters & Filter icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: ['Todos', 'Pendientes', 'Visitados'].map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedFilter = filter),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primaryColor : const Color(0xFFE3F2FD),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              filter,
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppTheme.primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.filter_alt_outlined, color: AppTheme.textSecondary, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '${filteredList.length}',
                          style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Client List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.accentColor))
                : filteredList.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay clientes asignados hoy.',
                          style: TextStyle(color: AppTheme.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final c = filteredList[index];
                          final hasVisited = _visitasMap.containsKey(c.clienteId);
                          final visit = _visitasMap[c.clienteId];
                          
                          // Generar iniciales
                          final names = c.nombreCliente.split(' ');
                          final initials = names.length > 1
                              ? '${names[0][0]}${names[1][0]}'.toUpperCase()
                              : c.nombreCliente.substring(0, 2).toUpperCase();

                          return GestureDetector(
                            onTap: () async {
                              if (!hasVisited) {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => NuevaVentaPage(cliente: c),
                                  ),
                                );
                                if (result == true) {
                                  _loadData();
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Este cliente ya fue visitado hoy.'),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            child: Container(
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
                                  // Avatar
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: _getAvatarColor(index),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        initials,
                                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  
                                  // Details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                c.nombreCliente,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.textPrimary),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: hasVisited
                                                    ? const Color(0xFFE8F5E9)
                                                    : const Color(0xFFFFF8E1),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                hasVisited ? 'Visitado' : 'Pendiente',
                                                style: TextStyle(
                                                  color: hasVisited ? Colors.green : const Color(0xFFF57C00),
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${c.calle ?? ''} ${c.colonia ?? ''}',
                                          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        
                                        // Time & Amount details
                                        Row(
                                          children: [
                                            const Icon(Icons.access_time, color: AppTheme.textSecondary, size: 14),
                                            const SizedBox(width: 4),
                                            Text(
                                              hasVisited
                                                  ? visit!.fechaHora.substring(11, 16)
                                                  : '--:--',
                                              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                                            ),
                                            if (hasVisited) ...[
                                              const SizedBox(width: 12),
                                              const Text('•', style: TextStyle(color: AppTheme.textSecondary)),
                                              const SizedBox(width: 12),
                                              Text(
                                                '\$${visit!.total.toStringAsFixed(0)}',
                                                style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
                                              ),
                                            ]
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
