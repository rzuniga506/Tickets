import 'package:flutter/material.dart';
import '../../config/theme.dart';

/// Widget para mostrar el estado activo/inactivo de un usuario
class UsuarioStatusChip extends StatelessWidget {
  final bool activo;
  final bool showIcon;
  final double fontSize;

  const UsuarioStatusChip({
    super.key,
    required this.activo,
    this.showIcon = true,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final color = activo ? AppTheme.successColor : AppTheme.greyDark;
    final label = activo ? 'Activo' : 'Inactivo';
    final icon = activo ? Icons.check_circle : Icons.cancel;

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
          if (showIcon) ...[
            Icon(icon, size: fontSize + 2, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
