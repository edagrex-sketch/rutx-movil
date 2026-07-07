import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/entities/cliente_entity.dart';
import '../../../../core/database/entities/producto_entity.dart';
import '../../../../core/database/entities/venta_pendiente_entity.dart';
import '../../../../core/network/connectivity_service.dart';
import '../../data/sales_repository.dart';
import 'venta_exitosa_page.dart';

class NuevaVentaPage extends StatefulWidget {
  final Cliente cliente;
  const NuevaVentaPage({Key? key, required this.cliente}) : super(key: key);

  @override
  State<NuevaVentaPage> createState() => _NuevaVentaPageState();
}

class _NuevaVentaPageState extends State<NuevaVentaPage>
    with SingleTickerProviderStateMixin {
  final ConnectivityService _connectivityService = ConnectivityService();
  final SalesRepository _salesRepository = SalesRepository();
  late TabController _tabController;

  bool _isConnected = true;
  String _searchQuery = '';
  List<Producto> _productos = [];
  final Map<int, int> _cart = {}; // Maps articuloId -> Quantity
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {}); // Repaint bottom sticky button and tabs count
    });
    _loadProducts();
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

  Future<void> _loadProducts() async {
    final db = AppDatabase();
    await db.initialize();
    final list = await db.productDao.getAll();
    if (mounted) {
      setState(() {
        _productos = list;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Producto> _getFilteredProducts() {
    return _productos.where((p) {
      return p.nombre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.clave.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  double _getCartTotal() {
    double total = 0.0;
    _cart.forEach((id, qty) {
      final prod = _productos.firstWhere((p) => p.articuloId == id);
      total += prod.precio * qty;
    });
    return total;
  }

  int _getCartDistinctCount() {
    return _cart.length;
  }

  void _addToCart(int id) {
    setState(() {
      _cart[id] = (_cart[id] ?? 0) + 1;
    });
  }

  void _removeFromCart(int id) {
    if (!_cart.containsKey(id)) return;
    setState(() {
      if (_cart[id] == 1) {
        _cart.remove(id);
      } else {
        _cart[id] = _cart[id]! - 1;
      }
    });
  }

  void _deleteFromCart(int id) {
    setState(() {
      _cart.remove(id);
    });
  }

  void _confirmSale() async {
    if (_cart.isEmpty) return;

    setState(() => _isLoading = true);

    final vendedorId = await LocalStorage().getVendedorId();

    if (vendedorId == null) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Sesión no válida. Vuelve a iniciar sesión antes de vender.',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      return;
    }

    final List<Map<String, dynamic>> detalles = [];
    _cart.forEach((id, qty) {
      final prod = _productos.firstWhere((p) => p.articuloId == id);
      detalles.add({
        'articulo_id': id,
        'nombre': prod.nombre,
        'unidades': qty,
        'precio_unitario': prod.precio,
      });
    });

    final totalAmount = _getCartTotal();
    final ventaId = 'VTA-${const Uuid().v4().substring(0, 8).toUpperCase()}';
    final venta = VentaPendiente(
      ventaMovilId: ventaId,
      vendedorId: vendedorId,
      clienteId: widget.cliente.clienteId,
      clienteNombre: widget.cliente.nombreCliente,
      fechaHora: DateTime.now().toIso8601String(),
      estado: 'pendiente',
      total: totalAmount,
      detalles: detalles,
    );

    final success = await _salesRepository.saveSaleLocally(venta);
    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        _salesRepository.syncPendingSales();

        final result = await Navigator.push<String>(
          context,
          MaterialPageRoute(
            builder:
                (context) => VentaExitosaPage(
                  clienteNombre: widget.cliente.nombreCliente,
                  total: totalAmount,
                  ventaId: ventaId,
                  isOnline: _isConnected,
                ),
          ),
        );

        if (mounted) {
          if (result == 'new_sale') {
            setState(() {
              _cart.clear();
              _tabController.animateTo(0);
            });
          } else {
            // Pasamos el resultado real (view_clients / view_pending) hacia HomePage
            Navigator.pop(context, result);
          }
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al registrar la venta.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredProducts = _getFilteredProducts();
    final cartItemCount = _getCartDistinctCount();
    final total = _getCartTotal();

    // Get initials of client
    final names = widget.cliente.nombreCliente.split(' ');
    final initials =
        names.length > 1
            ? '${names[0][0]}${names[1][0]}'.toUpperCase()
            : widget.cliente.nombreCliente.substring(0, 2).toUpperCase();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Nueva venta',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color:
                  _isConnected
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  _isConnected ? Icons.wifi : Icons.wifi_off,
                  color: _isConnected ? Colors.green : Colors.red,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  _isConnected ? 'Con señal' : 'Sin señal',
                  style: TextStyle(
                    color: _isConnected ? Colors.green : Colors.red,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Client Selected Banner
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.cliente.nombreCliente,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const Text(
                        'Cliente seleccionado',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cambiar',
                    style: TextStyle(
                      color: AppTheme.accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tab bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.accentColor,
              labelColor: AppTheme.accentColor,
              unselectedLabelColor: AppTheme.textSecondary,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
              tabs: [
                const Tab(text: 'Productos'),
                Tab(text: 'Resumen ($cartItemCount)'),
              ],
            ),
          ),

          // Tab view content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // 1. PRODUCT LIST TAB
                Column(
                  children: [
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        onChanged: (val) => setState(() => _searchQuery = val),
                        decoration: InputDecoration(
                          hintText: 'Buscar producto...',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppTheme.textSecondary,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 0,
                          ),
                        ),
                      ),
                    ),

                    // Products list
                    Expanded(
                      child:
                          _isLoading
                              ? const Center(
                                child: CircularProgressIndicator(
                                  color: AppTheme.accentColor,
                                ),
                              )
                              : filteredProducts.isEmpty
                              ? const Center(
                                child: Text(
                                  'No hay productos disponibles.',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              )
                              : ListView.builder(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                                itemCount: filteredProducts.length,
                                itemBuilder: (context, index) {
                                  final p = filteredProducts[index];
                                  final count = _cart[p.articuloId] ?? 0;
                                  final hasQty = count > 0;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color:
                                          hasQty
                                              ? const Color(0xFFFFF9F2)
                                              : Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color:
                                            hasQty
                                                ? const Color(0xFFFFE0B2)
                                                : AppTheme.lightGrey,
                                        width: hasQty ? 1.5 : 1.0,
                                      ),
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                p.nombre,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: AppTheme.textPrimary,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${p.clave} · \$${p.precio.toStringAsFixed(0)}',
                                                style: const TextStyle(
                                                  color: AppTheme.textSecondary,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),

                                        // Product controls
                                        if (!hasQty)
                                          GestureDetector(
                                            onTap:
                                                () => _addToCart(p.articuloId),
                                            child: Container(
                                              width: 36,
                                              height: 36,
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFFF3E0),
                                                shape: BoxShape.circle,
                                                border: Border.all(
                                                  color: const Color(
                                                    0xFFFFB74D,
                                                  ),
                                                  width: 1.0,
                                                ),
                                              ),
                                              child: const Icon(
                                                Icons.add,
                                                color: AppTheme.accentColor,
                                                size: 20,
                                              ),
                                            ),
                                          )
                                        else
                                          Row(
                                            children: [
                                              GestureDetector(
                                                onTap:
                                                    () => _removeFromCart(
                                                      p.articuloId,
                                                    ),
                                                child: Container(
                                                  width: 36,
                                                  height: 36,
                                                  decoration:
                                                      const BoxDecoration(
                                                        color:
                                                            AppTheme
                                                                .accentColor,
                                                        shape: BoxShape.circle,
                                                      ),
                                                  child: const Icon(
                                                    Icons.remove,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                    ),
                                                child: Text(
                                                  '$count',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: AppTheme.textPrimary,
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap:
                                                    () => _addToCart(
                                                      p.articuloId,
                                                    ),
                                                child: Container(
                                                  width: 36,
                                                  height: 36,
                                                  decoration:
                                                      const BoxDecoration(
                                                        color:
                                                            AppTheme
                                                                .accentColor,
                                                        shape: BoxShape.circle,
                                                      ),
                                                  child: const Icon(
                                                    Icons.add,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                    ),
                  ],
                ),

                // 2. RESUMEN / SHOPPING CART TAB
                _cart.isEmpty
                    ? const Center(
                      child: Text(
                        'El carrito está vacío.',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    )
                    : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _cart.length,
                            itemBuilder: (context, index) {
                              final keyList = _cart.keys.toList();
                              final id = keyList[index];
                              final qty = _cart[id]!;
                              final prod = _productos.firstWhere(
                                (p) => p.articuloId == id,
                              );

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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            prod.nombre.length > 15
                                                ? '${prod.nombre.substring(0, 12)}...'
                                                : prod.nombre,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '\$${prod.precio.toStringAsFixed(0)} x $qty',
                                            style: const TextStyle(
                                              color: AppTheme.textSecondary,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Quantity controls
                                    Row(
                                      children: [
                                        GestureDetector(
                                          onTap: () => _removeFromCart(id),
                                          child: Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.remove,
                                              color: Colors.grey,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                          ),
                                          child: Text(
                                            '$qty',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              color: AppTheme.textPrimary,
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => _addToCart(id),
                                          child: Container(
                                            width: 32,
                                            height: 32,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                              ),
                                            ),
                                            child: const Icon(
                                              Icons.add,
                                              color: Colors.grey,
                                              size: 16,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),

                                        // Delete icon button
                                        GestureDetector(
                                          onTap: () => _deleteFromCart(id),
                                          child: Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFEBEE),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: const Icon(
                                              Icons.delete,
                                              color: Colors.redAccent,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '\$${(prod.precio * qty).toStringAsFixed(0)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),

                        // Total Estimado Container Box
                        Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total estimado',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '\$${total.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Color(0xFFFFB74D),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
              ],
            ),
          ),

          // Sticky Bottom Action Button
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.white,
            width: double.infinity,
            child:
                _tabController.index == 0
                    ? ElevatedButton(
                      onPressed:
                          _cart.isEmpty
                              ? null
                              : () => _tabController.animateTo(1),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Revisar pedido ($cartItemCount)',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                    : ElevatedButton.icon(
                      onPressed:
                          (_cart.isEmpty || _isLoading) ? null : _confirmSale,
                      icon:
                          _isLoading
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(Icons.check, color: Colors.white),
                      label: Text(
                        _isLoading ? 'Guardando...' : 'Confirmar venta',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
