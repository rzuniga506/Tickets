import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../config/theme.dart';

/// Widget para mostrar la condición de un equipo con un badge colorido
class ConditionBadge extends StatelessWidget {
  final CondicionEquipo condicion;
  final bool compact;

  const ConditionBadge({
    super.key,
    required this.condicion,
    this.compact = false,
  });

  Color _getColorForCondicion(CondicionEquipo condicion) {
    switch (condicion) {
      case CondicionEquipo.nuevo:
        return AppTheme.primaryColor;
      case CondicionEquipo.excelente:
        return AppTheme.successColor;
      case CondicionEquipo.bueno:
        return AppTheme.infoColor;
      case CondicionEquipo.regular:
        return AppTheme.warningColor;
      case CondicionEquipo.malo:
        return AppTheme.errorColor;
      case CondicionEquipo.noFuncional:
        return AppTheme.greyDark;
    }
  }

  IconData _getIconForCondicion(CondicionEquipo condicion) {
    switch (condicion) {
      case CondicionEquipo.nuevo:
        return Icons.fiber_new;
      case CondicionEquipo.excelente:
        return Icons.star;
      case CondicionEquipo.bueno:
        return Icons.check_circle;
      case CondicionEquipo.regular:
        return Icons.info;
      case CondicionEquipo.malo:
        return Icons.warning;
      case CondicionEquipo.noFuncional:
        return Icons.delete_forever;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForCondicion(condicion);
    final icon = _getIconForCondicion(condicion);

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
              condicion.displayName,
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
        condicion.displayName,
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
