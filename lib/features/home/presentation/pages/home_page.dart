import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  Widget _buildQuickAction(String title, String subtitle, IconData icon, Color iconColor, Color bgColor) {
    return Container(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: AppTheme.primaryColor,
            pinned: true,
            expandedHeight: 120,
            toolbarHeight: 80,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Buenos días,', style: TextStyle(color: AppTheme.secondaryColor, fontSize: 14)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Carlos Ríos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9), // Light green
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.wifi, color: Colors.green, size: 16),
                          SizedBox(width: 4),
                          Text('Con señal', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
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
                    const Text('Jue 12 Jun', style: TextStyle(color: AppTheme.secondaryColor, fontSize: 14)),
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
                                text: const TextSpan(
                                  text: '2',
                                  style: TextStyle(color: AppTheme.textPrimary, fontSize: 28, fontWeight: FontWeight.bold),
                                  children: [
                                    TextSpan(text: '/6', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16, fontWeight: FontWeight.normal)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: const LinearProgressIndicator(
                                  value: 2 / 6,
                                  backgroundColor: AppTheme.lightGrey,
                                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentColor),
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
                            children: const [
                              Text('Ventas del día', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                              SizedBox(height: 8),
                              Text('\$2130', style: TextStyle(color: AppTheme.textPrimary, fontSize: 28, fontWeight: FontWeight.bold)),
                              SizedBox(height: 12),
                              Text('2 ventas enviadas', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1), // Light yellow
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFECB3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Color(0xFFF57C00)), // Orange-ish yellow
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('Tienes 2 ventas pendientes', style: TextStyle(color: Color(0xFFE65100), fontWeight: FontWeight.bold)),
                              Text('Se enviarán cuando haya señal', style: TextStyle(color: Color(0xFFE65100), fontSize: 13)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right, color: Color(0xFFF57C00)),
                      ],
                    ),
                  ),
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
                      _buildQuickAction('Clientes', '6 en ruta', Icons.people_outline, const Color(0xFF1565C0), const Color(0xFFE3F2FD)),
                      _buildQuickAction('Nueva venta', 'Registrar pedido', Icons.shopping_cart_outlined, const Color(0xFFE65100), const Color(0xFFFBE9E7)),
                      _buildQuickAction('Catálogo', '485 productos', Icons.inventory_2_outlined, const Color(0xFF0277BD), const Color(0xFFE1F5FE)),
                      _buildQuickAction('Notificaciones', '2 sin leer', Icons.notifications_none_outlined, const Color(0xFFC62828), const Color(0xFFFFEBEE)),
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
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
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
