import 'package:flutter/material.dart';
import '../../core/database/entities/venta_pendiente_entity.dart';

/// Atributos visuales calculados para el Badge de estado de una venta.
class _StatusBadgeStyle {
  final Color backgroundColor;
  final Color textColor;
  final String label;

  const _StatusBadgeStyle({
    required this.backgroundColor,
    required this.textColor,
    required this.label,
  });
}

/// Widget reutilizable que representa visualmente una [VentaPendiente].
///
/// - Consume el tema global de la aplicación para fondos y tipografía.
/// - Renderiza un badge de estado estandarizado con colores semánticos propios.
/// - No contiene lógica de negocio; solo presentación.
class SaleCard extends StatelessWidget {
  final VentaPendiente venta;

  /// Callback opcional al presionar la tarjeta (para navegación al detalle).
  final VoidCallback? onTap;

  const SaleCard({
    super.key,
    required this.venta,
    this.onTap,
  });

  // ---------------------------------------------------------------------------
  // Helpers de estado (reemplaza _getStatusTextColor en ventas_list_page.dart)
  // ---------------------------------------------------------------------------

  /// Evalúa el [estado] de la venta y retorna los atributos visuales del badge.
  _StatusBadgeStyle _resolveStatusStyle(String estado) {
    switch (estado.toLowerCase()) {
      case 'enviada':
        return _StatusBadgeStyle(
          backgroundColor: const Color(0xFF2E7D32).withOpacity(0.12),
          textColor: const Color(0xFF2E7D32),
          label: 'Enviada',
        );
      case 'pendiente':
        return _StatusBadgeStyle(
          backgroundColor: const Color(0xFFE65100).withOpacity(0.12),
          textColor: const Color(0xFFE65100),
          label: 'Pendiente',
        );
      case 'error':
        return _StatusBadgeStyle(
          backgroundColor: const Color(0xFFC62828).withOpacity(0.12),
          textColor: const Color(0xFFC62828),
          label: 'Error',
        );
      default:
        return _StatusBadgeStyle(
          backgroundColor: Colors.grey.withOpacity(0.12),
          textColor: Colors.grey.shade700,
          label: estado,
        );
    }
  }

  /// Formatea la hora de [fechaHora] (ISO 8601) como `HH:mm`.
  String _formatTime(String fechaHora) {
    try {
      return fechaHora.substring(11, 16);
    } catch (_) {
      return '--:--';
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final statusStyle = _resolveStatusStyle(venta.estado);
    final articulosCount = venta.detalles.length;
    final articulosLabel = articulosCount == 1
        ? '1 artículo'
        : '$articulosCount artículos';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: RepaintBoundary(
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFE0E0E0), // lightGrey
                width: 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
              // -- Columna de info principal --
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nombre del cliente
                    Text(
                      venta.clienteNombre,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 5),

                    // Hora · cantidad de artículos
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 13,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(venta.fechaHora),
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (articulosCount > 0) ...[
                          const SizedBox(width: 10),
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            articulosLabel,
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Badge de estado
                    _StatusBadge(style: statusStyle),
                  ],
                ),
              ),

              const SizedBox(width: 12),

              // -- Columna de total + chevron --
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '\$${venta.total.toStringAsFixed(2)}',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (onTap != null) ...[
                    const SizedBox(height: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
       ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Sub-widget interno: Badge de estado
// -----------------------------------------------------------------------------

class _StatusBadge extends StatelessWidget {
  final _StatusBadgeStyle style;

  const _StatusBadge({required this.style});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: style.backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        style.label.toUpperCase(),
        style: TextStyle(
          color: style.textColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
