import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../config/theme.dart';

/// Widget para mostrar la prioridad de un ticket con un badge colorido
class PriorityBadge extends StatelessWidget {
  final PrioridadTicket prioridad;
  final bool compact;

  const PriorityBadge({
    super.key,
    required this.prioridad,
    this.compact = false,
  });

  Color _getColorForPrioridad(PrioridadTicket prioridad) {
    switch (prioridad) {
      case PrioridadTicket.baja:
        return AppTheme.successColor;
      case PrioridadTicket.media:
        return AppTheme.infoColor;
      case PrioridadTicket.alta:
        return AppTheme.warningColor;
      case PrioridadTicket.critica:
        return AppTheme.errorColor;
    }
  }

  IconData _getIconForPrioridad(PrioridadTicket prioridad) {
    switch (prioridad) {
      case PrioridadTicket.baja:
        return Icons.arrow_downward;
      case PrioridadTicket.media:
        return Icons.remove;
      case PrioridadTicket.alta:
        return Icons.arrow_upward;
      case PrioridadTicket.critica:
        return Icons.priority_high;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForPrioridad(prioridad);
    final icon = _getIconForPrioridad(prioridad);

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              prioridad.displayName,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            prioridad.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
