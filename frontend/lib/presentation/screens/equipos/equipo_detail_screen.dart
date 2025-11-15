import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../logic/equipos/equipo_cubit.dart';
import '../../../logic/equipos/equipo_state.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../data/models/equipo/equipo_model.dart';
import '../../../data/models/user/user_model.dart';
import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../core/utils/responsive.dart';
import '../../widgets/equipment_status_chip.dart';
import '../../widgets/condition_badge.dart';
import '../../widgets/qr_display_widget.dart';

class EquipoDetailScreen extends StatefulWidget {
  final int equipoId;

  const EquipoDetailScreen({
    super.key,
    required this.equipoId,
  });

  @override
  State<EquipoDetailScreen> createState() => _EquipoDetailScreenState();
}

class _EquipoDetailScreenState extends State<EquipoDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadEquipo();
  }

  void _loadEquipo() {
    context.read<EquipoCubit>().getEquipoById(widget.equipoId);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return formatter.format(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Equipo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEquipo,
          ),
        ],
      ),
      body: BlocConsumer<EquipoCubit, EquipoState>(
        listener: (context, state) {
          if (state is EquipoActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.successColor,
              ),
            );
            _loadEquipo();
          } else if (state is QRGenerated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Código QR generado correctamente'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            // Mostrar el QR generado
            _showQRDialog(state.qrCode, state.equipo);
          } else if (state is EquipoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is EquipoLoading || state is EquipoActionLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is EquipoDetailLoaded) {
            return _buildEquipoDetail(state.equipo);
          }

          if (state is EquipoActionSuccess && state.equipo != null) {
            return _buildEquipoDetail(state.equipo);
          }

          if (state is QRGenerated) {
            return _buildEquipoDetail(state.equipo);
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 64,
                  color: AppTheme.greyDark,
                ),
                const SizedBox(height: 16),
                const Text('Error al cargar el equipo'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadEquipo,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEquipoDetail(EquipoModel equipo) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(Breakpoints.getHorizontalPadding(context)),
      child: CenteredContent(
        maxWidth: 800,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Header Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Icono grande
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.devices,
                      size: 64,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Nombre
                  Text(
                    equipo.nombre,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  if (equipo.modelo != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      equipo.modelo!,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Estado y Condición
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      EquipmentStatusChip(estado: equipo.estado),
                      ConditionBadge(condicion: equipo.condicion),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Información Básica
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información Básica',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    icon: Icons.inventory_2,
                    label: 'Código Interno',
                    value: equipo.codigoInterno,
                    monospace: true,
                    copyable: true,
                  ),
                  if (equipo.numeroSerie != null)
                    _buildInfoRow(
                      icon: Icons.tag,
                      label: 'Número de Serie',
                      value: equipo.numeroSerie!,
                      monospace: true,
                      copyable: true,
                    ),
                  if (equipo.descripcion != null)
                    _buildInfoRow(
                      icon: Icons.description,
                      label: 'Descripción',
                      value: equipo.descripcion!,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Información Financiera
          if (equipo.costoAdquisicion != null || equipo.fechaAdquisicion != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información Financiera',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 16),
                    if (equipo.fechaAdquisicion != null)
                      _buildInfoRow(
                        icon: Icons.event,
                        label: 'Fecha de Adquisición',
                        value: _formatDate(equipo.fechaAdquisicion),
                      ),
                    if (equipo.costoAdquisicion != null)
                      _buildInfoRow(
                        icon: Icons.attach_money,
                        label: 'Costo de Adquisición',
                        value: _formatCurrency(equipo.costoAdquisicion!),
                      ),
                    _buildInfoRow(
                      icon: Icons.timelapse,
                      label: 'Vida Útil',
                      value: '${equipo.vidaUtilMeses} meses',
                    ),
                    if (equipo.valorResidual != null)
                      _buildInfoRow(
                        icon: Icons.savings,
                        label: 'Valor Residual',
                        value: _formatCurrency(equipo.valorResidual!),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Garantía
          if (equipo.fechaInicioGarantia != null || equipo.fechaFinGarantia != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Garantía',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 16),
                    if (equipo.fechaInicioGarantia != null)
                      _buildInfoRow(
                        icon: Icons.event_available,
                        label: 'Inicio de Garantía',
                        value: _formatDate(equipo.fechaInicioGarantia),
                      ),
                    if (equipo.fechaFinGarantia != null)
                      _buildInfoRow(
                        icon: Icons.event_busy,
                        label: 'Fin de Garantía',
                        value: _formatDate(equipo.fechaFinGarantia),
                      ),
                    _buildInfoRow(
                      icon: equipo.enGarantia ? Icons.verified_user : Icons.warning,
                      label: 'Estado de Garantía',
                      value: equipo.enGarantia ? 'En garantía' : 'Fuera de garantía',
                      valueColor: equipo.enGarantia ? AppTheme.successColor : AppTheme.warningColor,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Asignación
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Asignación',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 16),
                  if (equipo.usuarioAsignadoNombre != null) ...[
                    _buildInfoRow(
                      icon: Icons.person,
                      label: 'Asignado a',
                      value: equipo.usuarioAsignadoNombre!,
                      valueColor: AppTheme.primaryColor,
                    ),
                    if (equipo.fechaAsignacion != null)
                      _buildInfoRow(
                        icon: Icons.event_available,
                        label: 'Fecha de Asignación',
                        value: _formatDate(equipo.fechaAsignacion),
                      ),
                    if (equipo.departamentoAsignadoNombre != null)
                      _buildInfoRow(
                        icon: Icons.business,
                        label: 'Departamento',
                        value: equipo.departamentoAsignadoNombre!,
                      ),
                  ] else ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: AppTheme.successColor,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Equipo disponible para asignación',
                              style: TextStyle(
                                color: AppTheme.successColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Código QR
          if (equipo.codigoQR != null && equipo.codigoQR!.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Código QR',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        TextButton.icon(
                          onPressed: () =>
                              _showQRDialog(equipo.codigoQR!, equipo),
                          icon: const Icon(Icons.fullscreen),
                          label: const Text('Ver completo'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: QRDisplayWidget(
                        qrData: equipo.codigoQR!,
                        equipoInfo: '${equipo.nombre}${equipo.modelo != null ? " - ${equipo.modelo}" : ""}',
                        size: 150,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Observaciones
          if (equipo.observaciones != null && equipo.observaciones!.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.notes, size: 20, color: AppTheme.primaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'Observaciones',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      equipo.observaciones!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Botones de acción
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, authState) {
              if (authState is Authenticated) {
                return _buildActionButtons(equipo, authState.user);
              }
              return const SizedBox.shrink();
            },
          ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool monospace = false,
    bool copyable = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.greyDark),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.greyDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: valueColor,
                    fontFamily: monospace ? 'monospace' : null,
                  ),
                ),
              ],
            ),
          ),
          if (copyable)
            IconButton(
              icon: const Icon(Icons.copy, size: 18),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: value));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Copiado al portapapeles'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(EquipoModel equipo, dynamic user) {
    final isAdmin = user.rol == RolUsuario.administrador;
    final isTecnico = user.rol == RolUsuario.tecnico;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Generar QR (admin o técnico)
        if ((isAdmin || isTecnico) &&
            (equipo.codigoQR == null || equipo.codigoQR!.isEmpty))
          ElevatedButton.icon(
            onPressed: () {
              context.read<EquipoCubit>().generarQR(equipo.id);
            },
            icon: const Icon(Icons.qr_code_2),
            label: const Text('Generar Código QR'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
          ),

        // Asignar equipo (admin o técnico, solo si está disponible)
        if ((isAdmin || isTecnico) && equipo.usuarioAsignadoId == null)
          ElevatedButton.icon(
            onPressed: () => _showAsignarDialog(equipo),
            icon: const Icon(Icons.assignment_ind),
            label: const Text('Asignar Equipo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
            ),
          ),

        // Desasignar equipo (admin o técnico, solo si está asignado)
        if ((isAdmin || isTecnico) && equipo.usuarioAsignadoId != null)
          OutlinedButton.icon(
            onPressed: () => _confirmarDesasignar(equipo),
            icon: const Icon(Icons.person_remove),
            label: const Text('Desasignar Equipo'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.warningColor,
              side: const BorderSide(color: AppTheme.warningColor),
            ),
          ),
      ]
          .map((button) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: button,
              ))
          .toList(),
    );
  }

  void _showQRDialog(String qrCode, EquipoModel equipo) {
    showDialog(
      context: context,
      builder: (context) => QRDisplayDialog(
        qrData: qrCode,
        equipoInfo: '${equipo.nombre}${equipo.modelo != null ? " - ${equipo.modelo}" : ""}',
      ),
    );
  }

  void _showAsignarDialog(EquipoModel equipo) {
    // TODO: Implementar selector de usuario
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Asignar Equipo'),
        content: const Text(
          'Funcionalidad de asignación en desarrollo.\n\nRequiere integración con la lista de usuarios.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _confirmarDesasignar(EquipoModel equipo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Desasignar Equipo'),
        content: Text(
          '¿Desea desasignar este equipo de ${equipo.usuarioAsignadoNombre}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<EquipoCubit>().desasignarEquipo(equipo.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warningColor,
            ),
            child: const Text('Desasignar'),
          ),
        ],
      ),
    );
  }
}
