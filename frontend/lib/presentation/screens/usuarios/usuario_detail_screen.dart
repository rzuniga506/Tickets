import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/usuarios/usuario_cubit.dart';
import '../../../logic/usuarios/usuario_state.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../data/models/user/user_model.dart';
import '../../../config/theme.dart';
import '../../../core/di/injection.dart';
import '../../widgets/rol_badge.dart';
import '../../widgets/usuario_status_chip.dart';
import 'usuario_form_screen.dart';

class UsuarioDetailScreen extends StatefulWidget {
  final int usuarioId;

  const UsuarioDetailScreen({
    super.key,
    required this.usuarioId,
  });

  @override
  State<UsuarioDetailScreen> createState() => _UsuarioDetailScreenState();
}

class _UsuarioDetailScreenState extends State<UsuarioDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadUsuario();
  }

  void _loadUsuario() {
    context.read<UsuarioCubit>().getUsuarioById(widget.usuarioId);
  }

  void _handleEdit(UserModel usuario) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => getIt<UsuarioCubit>(),
          child: UsuarioFormScreen(usuario: usuario),
        ),
      ),
    );
    _loadUsuario();
  }

  void _handleDelete(UserModel usuario) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Usuario'),
        content: Text(
          '¿Estás seguro de que deseas eliminar a ${usuario.nombreCompleto}? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<UsuarioCubit>().deleteUsuario(usuario.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _handleToggleActivo(UserModel usuario) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(usuario.activo ? 'Desactivar Usuario' : 'Activar Usuario'),
        content: Text(
          usuario.activo
              ? '¿Deseas desactivar a ${usuario.nombreCompleto}?'
              : '¿Deseas activar a ${usuario.nombreCompleto}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<UsuarioCubit>().toggleActivo(usuario.id, usuario.activo);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: usuario.activo
                  ? AppTheme.warningColor
                  : AppTheme.successColor,
            ),
            child: Text(usuario.activo ? 'Desactivar' : 'Activar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de Usuario'),
      ),
      body: BlocConsumer<UsuarioCubit, UsuarioState>(
        listener: (context, state) {
          if (state is UsuarioActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.successColor,
              ),
            );
            // Si fue eliminado, regresar
            if (state.message.contains('eliminado')) {
              Navigator.of(context).pop();
            } else {
              _loadUsuario();
            }
          } else if (state is UsuarioError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is UsuarioLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is UsuarioDetailLoaded) {
            return _buildUsuarioDetail(state.usuario);
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.errorColor,
                ),
                const SizedBox(height: 16),
                const Text('Error al cargar usuario'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadUsuario,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUsuarioDetail(UserModel usuario) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con avatar y nombre
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  child: Text(
                    _getInitials(usuario.nombreCompleto),
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  usuario.nombreCompleto,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RolBadge(rol: usuario.rol, showIcon: true),
                    const SizedBox(width: 8),
                    UsuarioStatusChip(activo: usuario.activo),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Información de contacto
          _buildSection(
            title: 'Información de Contacto',
            children: [
              _buildInfoRow(
                icon: Icons.email_outlined,
                label: 'Email',
                value: usuario.email,
              ),
              if (usuario.telefono != null)
                _buildInfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Teléfono',
                  value: usuario.telefono!,
                ),
            ],
          ),

          const SizedBox(height: 24),

          // Información profesional
          _buildSection(
            title: 'Información Profesional',
            children: [
              _buildInfoRow(
                icon: Icons.badge_outlined,
                label: 'Rol',
                value: _getRolLabel(usuario.rol),
              ),
              if (usuario.cargo != null)
                _buildInfoRow(
                  icon: Icons.work_outline,
                  label: 'Cargo',
                  value: usuario.cargo!,
                ),
              if (usuario.departamento != null)
                _buildInfoRow(
                  icon: Icons.business_outlined,
                  label: 'Departamento',
                  value: usuario.departamento!.nombre,
                ),
            ],
          ),

          const SizedBox(height: 24),

          // Información del sistema
          _buildSection(
            title: 'Información del Sistema',
            children: [
              _buildInfoRow(
                icon: Icons.info_outlined,
                label: 'ID',
                value: usuario.id.toString(),
              ),
              _buildInfoRow(
                icon: Icons.check_circle_outline,
                label: 'Estado',
                value: usuario.activo ? 'Activo' : 'Inactivo',
              ),
              if (usuario.fechaCreacion != null)
                _buildInfoRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Fecha de Creación',
                  value: _formatDate(usuario.fechaCreacion!),
                ),
            ],
          ),

          const SizedBox(height: 32),

          // Botones de acción (solo para admin)
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              if (authState is Authenticated &&
                  authState.user.rol == RolUsuario.administrador) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _handleEdit(usuario),
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar Usuario'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _handleToggleActivo(usuario),
                      icon: Icon(usuario.activo
                          ? Icons.toggle_off
                          : Icons.toggle_on),
                      label: Text(usuario.activo
                          ? 'Desactivar Usuario'
                          : 'Activar Usuario'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: usuario.activo
                            ? AppTheme.warningColor
                            : AppTheme.successColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => _handleDelete(usuario),
                      icon: const Icon(Icons.delete),
                      label: const Text('Eliminar Usuario'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        foregroundColor: AppTheme.errorColor,
                      ),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppTheme.greyDark),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.greyDark,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  String _getRolLabel(RolUsuario rol) {
    switch (rol) {
      case RolUsuario.administrador:
        return 'Administrador';
      case RolUsuario.tecnico:
        return 'Técnico';
      case RolUsuario.usuario:
        return 'Usuario';
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
