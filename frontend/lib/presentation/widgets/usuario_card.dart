import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../data/models/user/user_model.dart';
import 'rol_badge.dart';
import 'usuario_status_chip.dart';

/// Widget de tarjeta para mostrar información de un usuario
class UsuarioCard extends StatelessWidget {
  final UserModel usuario;
  final VoidCallback? onTap;
  final VoidCallback? onToggleActivo;

  const UsuarioCard({
    super.key,
    required this.usuario,
    this.onTap,
    this.onToggleActivo,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Avatar, Nombre y Status
              Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: Text(
                      _getInitials(usuario.nombreCompleto),
                      style: const TextStyle(
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Nombre y Email
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          usuario.nombreCompleto,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.email_outlined,
                              size: 14,
                              color: AppTheme.greyDark,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                usuario.email,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.greyDark,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Status
                  UsuarioStatusChip(activo: usuario.activo),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),

              // Info adicional
              Row(
                children: [
                  // Rol
                  RolBadge(rol: usuario.rol, showIcon: true),

                  const SizedBox(width: 12),

                  // Cargo
                  if (usuario.cargo != null) ...[
                    const Icon(Icons.work_outline, size: 14, color: AppTheme.greyDark),
                    const SizedBox(width: 4),
                    Text(
                      usuario.cargo!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],

                  const Spacer(),

                  // Botón de toggle activo (solo para admins)
                  if (onToggleActivo != null)
                    IconButton(
                      icon: Icon(
                        usuario.activo
                            ? Icons.toggle_on
                            : Icons.toggle_off,
                        color: usuario.activo
                            ? AppTheme.successColor
                            : AppTheme.greyDark,
                      ),
                      onPressed: onToggleActivo,
                      tooltip: usuario.activo ? 'Desactivar' : 'Activar',
                    ),
                ],
              ),

              // Información adicional
              if (usuario.telefono != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.phone_outlined, size: 14, color: AppTheme.greyDark),
                    const SizedBox(width: 4),
                    Text(
                      usuario.telefono!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }
}
