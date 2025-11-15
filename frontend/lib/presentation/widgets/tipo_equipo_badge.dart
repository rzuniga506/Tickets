import 'package:flutter/material.dart';
import '../../config/constants.dart';
import '../../config/theme.dart';

/// Widget para mostrar el tipo de equipo con un badge
class TipoEquipoBadge extends StatelessWidget {
  final TipoEquipo tipo;
  final bool compact;

  const TipoEquipoBadge({
    super.key,
    required this.tipo,
    this.compact = false,
  });

  IconData _getIconForTipo(TipoEquipo tipo) {
    switch (tipo) {
      case TipoEquipo.computadora:
        return Icons.computer;
      case TipoEquipo.laptop:
        return Icons.laptop;
      case TipoEquipo.servidor:
        return Icons.dns;
      case TipoEquipo.impresora:
        return Icons.print;
      case TipoEquipo.scanner:
        return Icons.scanner;
      case TipoEquipo.router:
        return Icons.router;
      case TipoEquipo.switch_:
        return Icons.device_hub;
      case TipoEquipo.firewall:
        return Icons.security;
      case TipoEquipo.monitor:
        return Icons.monitor;
      case TipoEquipo.teclado:
        return Icons.keyboard;
      case TipoEquipo.mouse:
        return Icons.mouse;
      case TipoEquipo.telefono:
        return Icons.phone;
      case TipoEquipo.tablet:
        return Icons.tablet;
      case TipoEquipo.otro:
        return Icons.devices_other;
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _getIconForTipo(tipo);

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.greyLight,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppTheme.primaryColor),
            const SizedBox(width: 4),
            Text(
              tipo.displayName,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.greyDark,
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
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppTheme.primaryColor),
          const SizedBox(width: 6),
          Text(
            tipo.displayName,
            style: const TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
