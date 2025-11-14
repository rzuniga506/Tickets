import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../data/models/user/user_model.dart';

/// Widget para mostrar el rol de un usuario con badge de color
class RolBadge extends StatelessWidget {
  final RolUsuario rol;
  final bool showIcon;
  final double fontSize;

  const RolBadge({
    super.key,
    required this.rol,
    this.showIcon = false,
    this.fontSize = 12,
  });

  Color _getColorForRol(RolUsuario rol) {
    switch (rol) {
      case RolUsuario.administrador:
        return AppTheme.errorColor;
      case RolUsuario.tecnico:
        return AppTheme.primaryColor;
      case RolUsuario.usuario:
        return AppTheme.greyDark;
    }
  }

  IconData _getIconForRol(RolUsuario rol) {
    switch (rol) {
      case RolUsuario.administrador:
        return Icons.admin_panel_settings;
      case RolUsuario.tecnico:
        return Icons.engineering;
      case RolUsuario.usuario:
        return Icons.person;
    }
  }

  String _getLabelForRol(RolUsuario rol) {
    switch (rol) {
      case RolUsuario.administrador:
        return 'Administrador';
      case RolUsuario.tecnico:
        return 'Técnico';
      case RolUsuario.usuario:
        return 'Usuario';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForRol(rol);

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
            Icon(_getIconForRol(rol), size: fontSize + 2, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            _getLabelForRol(rol),
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
