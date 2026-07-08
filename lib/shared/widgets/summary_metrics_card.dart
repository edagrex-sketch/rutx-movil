import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class SummaryMetricsCard extends StatelessWidget {
  final double totalVentas;
  final int clientesVisitados;
  final int piezasVendidas;

  const SummaryMetricsCard({
    Key? key,
    required this.totalVentas,
    required this.clientesVisitados,
    required this.piezasVendidas,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: topPadding + 16,
        bottom: 24,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.primaryColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Resumen del día',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildMetricColumn(
                context,
                title: 'Total ventas',
                value: '\$${totalVentas.toStringAsFixed(0)}',
                icon: Icons.attach_money,
              ),
              _buildDivider(Colors.white),
              _buildMetricColumn(
                context,
                title: 'Clientes',
                value: clientesVisitados.toString(),
                icon: Icons.people_outline,
              ),
              _buildDivider(Colors.white),
              _buildMetricColumn(
                context,
                title: 'Piezas',
                value: piezasVendidas.toString(),
                icon: Icons.inventory_2_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricColumn(BuildContext context, {required String title, required String value, required IconData icon}) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(Color onPrimaryColor) {
    return Container(
      height: 40,
      width: 1,
      color: onPrimaryColor.withOpacity(0.3),
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
