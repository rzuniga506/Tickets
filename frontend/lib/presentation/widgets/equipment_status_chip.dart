import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../config/theme.dart';

/// Widget para mostrar el estado de un equipo con un chip colorido
class EquipmentStatusChip extends StatelessWidget {
  final EstadoEquipo estado;
  final bool compact;

  const EquipmentStatusChip({
    super.key,
    required this.estado,
    this.compact = false,
  });

  Color _getColorForEstado(EstadoEquipo estado) {
    switch (estado) {
      case EstadoEquipo.disponible:
        return AppTheme.successColor;
      case EstadoEquipo.asignado:
        return AppTheme.primaryColor;
      case EstadoEquipo.enMantenimiento:
        return AppTheme.warningColor;
      case EstadoEquipo.dadoDeBaja:
        return AppTheme.greyDark;
    }
  }

  IconData _getIconForEstado(EstadoEquipo estado) {
    switch (estado) {
      case EstadoEquipo.disponible:
        return Icons.check_circle;
      case EstadoEquipo.asignado:
        return Icons.assignment_ind;
      case EstadoEquipo.enMantenimiento:
        return Icons.build_circle;
      case EstadoEquipo.dadoDeBaja:
        return Icons.cancel;
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
