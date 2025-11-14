import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../config/theme.dart';

/// Widget para mostrar el estado de un ticket con un chip colorido
class StatusChip extends StatelessWidget {
  final EstadoTicket estado;
  final bool compact;

  const StatusChip({
    super.key,
    required this.estado,
    this.compact = false,
  });

  Color _getColorForEstado(EstadoTicket estado) {
    switch (estado) {
      case EstadoTicket.nuevo:
        return AppTheme.infoColor;
      case EstadoTicket.asignado:
        return AppTheme.primaryColor;
      case EstadoTicket.enProceso:
        return AppTheme.warningColor;
      case EstadoTicket.resuelto:
        return AppTheme.successColor;
      case EstadoTicket.cerrado:
        return AppTheme.greyDark;
      case EstadoTicket.reabierto:
        return AppTheme.errorColor;
    }
  }

  IconData _getIconForEstado(EstadoTicket estado) {
    switch (estado) {
      case EstadoTicket.nuevo:
        return Icons.fiber_new;
      case EstadoTicket.asignado:
        return Icons.assignment_ind;
      case EstadoTicket.enProceso:
        return Icons.pending_actions;
      case EstadoTicket.resuelto:
        return Icons.check_circle;
      case EstadoTicket.cerrado:
        return Icons.done_all;
      case EstadoTicket.reabierto:
        return Icons.refresh;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForEstado(estado);
    final icon = _getIconForEstado(estado);

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
              estado.displayName,
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

    return Chip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(
        estado.displayName,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color, width: 1),
    );
  }
}
