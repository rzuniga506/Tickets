import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../logic/tickets/ticket_cubit.dart';
import '../../../logic/tickets/ticket_state.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../logic/usuarios/usuario_cubit.dart';
import '../../../logic/usuarios/usuario_state.dart';
import '../../../data/models/ticket/ticket_model.dart';
import '../../../data/models/user/user_model.dart';
import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../core/di/injection.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/priority_badge.dart';
import '../../widgets/loading_card.dart';

class TicketDetailScreen extends StatefulWidget {
  final int ticketId;

  const TicketDetailScreen({
    super.key,
    required this.ticketId,
  });

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadTicket();
  }

  void _loadTicket() {
    context.read<TicketCubit>().getTicketById(widget.ticketId);
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Ticket'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTicket,
          ),
        ],
      ),
      body: BlocConsumer<TicketCubit, TicketState>(
        listener: (context, state) {
          if (state is TicketActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.successColor,
              ),
            );
            // Recargar el ticket después de una acción exitosa
            _loadTicket();
          } else if (state is TicketError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TicketLoading || state is TicketActionLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is TicketDetailLoaded) {
            return _buildTicketDetail(state.ticket);
          }

          // Mantener el ticket visible durante acciones
          if (state is TicketActionSuccess && state.ticket != null) {
            return _buildTicketDetail(state.ticket);
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
                const Text('Error al cargar el ticket'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadTicket,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTicketDetail(TicketModel ticket) {
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ticket #${ticket.id}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      PriorityBadge(prioridad: ticket.prioridad),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ticket.asunto,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 16),
                  StatusChip(estado: ticket.estado),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Descripción
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.description, size: 20, color: AppTheme.primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        'Descripción',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ticket.descripcion,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Información del Ticket
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    icon: Icons.category,
                    label: 'Categoría',
                    value: ticket.categoria?.displayName ?? 'Sin categoría',
                  ),
                  _buildInfoRow(
                    icon: Icons.person,
                    label: 'Creado por',
                    value: ticket.solicitanteNombre,
                  ),
                  if (ticket.tecnicoAsignadoNombre != null)
                    _buildInfoRow(
                      icon: Icons.engineering,
                      label: 'Técnico asignado',
                      value: ticket.tecnicoAsignadoNombre!.nombreCompleto,
                      valueColor: AppTheme.primaryColor,
                    ),
                  _buildInfoRow(
                    icon: Icons.access_time,
                    label: 'Fecha de creación',
                    value: _formatDate(ticket.fechaCreacion),
                  ),
                  if (ticket.fechaAsignacion != null)
                    _buildInfoRow(
                      icon: Icons.assignment_turned_in,
                      label: 'Fecha de asignación',
                      value: _formatDate(ticket.fechaAsignacion!),
                    ),
                  if (ticket.fechaInicioProceso != null)
                    _buildInfoRow(
                      icon: Icons.play_arrow,
                      label: 'Inicio de proceso',
                      value: _formatDate(ticket.fechaInicioProceso!),
                    ),
                  if (ticket.fechaResolucion != null)
                    _buildInfoRow(
                      icon: Icons.check_circle,
                      label: 'Fecha de resolución',
                      value: _formatDate(ticket.fechaResolucion!),
                    ),
                  if (ticket.fechaCierre != null)
                    _buildInfoRow(
                      icon: Icons.done_all,
                      label: 'Fecha de cierre',
                      value: _formatDate(ticket.fechaCierre!),
                    ),
                  if (ticket.fechaLimiteSLA != null)
                    _buildInfoRow(
                      icon: Icons.event,
                      label: 'Fecha límite (SLA)',
                      value: _formatDate(ticket.fechaLimiteSLA!),
                      valueColor: ticket.slaVencido ? AppTheme.errorColor : null,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Solución (si existe)
          if (ticket.solucion != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb, size: 20, color: AppTheme.successColor),
                        const SizedBox(width: 8),
                        Text(
                          'Solución',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      ticket.solucion!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Evaluación (si existe)
          if (ticket.calificacionServicio != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, size: 20, color: AppTheme.warningColor),
                        const SizedBox(width: 8),
                        Text(
                          'Evaluación',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < ticket.calificacionServicio!
                              ? Icons.star
                              : Icons.star_border,
                          color: AppTheme.warningColor,
                          size: 28,
                        );
                      }),
                    ),
                    if (ticket.comentarioEvaluacion != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        ticket.comentarioEvaluacion!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
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
                return _buildActionButtons(ticket, authState.user);
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(TicketModel ticket, dynamic user) {
    final isAdmin = user.rol == RolUsuario.administrador;
    final isTecnico = user.rol == RolUsuario.tecnico;
    final isCreador = ticket.solicitanteId == user.id;
    final isAsignado = ticket.tecnicoAsignadoNombre?.id == user.id;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Asignar técnico (solo admin)
        if (isAdmin && ticket.estado == EstadoTicket.nuevo)
          ElevatedButton.icon(
            onPressed: () => _showAsignarTecnicoDialog(ticket),
            icon: const Icon(Icons.assignment_ind),
            label: const Text('Asignar Técnico'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
          ),

        // Iniciar proceso (técnico asignado)
        if (isAsignado && ticket.estado == EstadoTicket.asignado)
          ElevatedButton.icon(
            onPressed: () => _confirmarAccion(
              titulo: 'Iniciar Proceso',
              mensaje: '¿Desea iniciar el proceso de resolución de este ticket?',
              onConfirm: () {
                context.read<TicketCubit>().iniciarProceso(ticket.id);
              },
            ),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Iniciar Proceso'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.infoColor,
            ),
          ),

        // Resolver ticket (técnico asignado)
        if (isAsignado && ticket.estado == EstadoTicket.enProceso)
          ElevatedButton.icon(
            onPressed: () => _showResolverDialog(ticket),
            icon: const Icon(Icons.check_circle),
            label: const Text('Resolver Ticket'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
            ),
          ),

        // Cerrar ticket (creador o admin)
        if ((isCreador || isAdmin) && ticket.estado == EstadoTicket.resuelto)
          ElevatedButton.icon(
            onPressed: () => _confirmarAccion(
              titulo: 'Cerrar Ticket',
              mensaje: '¿Desea cerrar este ticket? Esta acción indica que está satisfecho con la solución.',
              onConfirm: () {
                context.read<TicketCubit>().cerrarTicket(ticket.id);
              },
            ),
            icon: const Icon(Icons.done_all),
            label: const Text('Cerrar Ticket'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.greyDark,
            ),
          ),

        // Evaluar ticket (creador)
        if (isCreador && ticket.estado == EstadoTicket.cerrado && ticket.calificacionServicio == null)
          ElevatedButton.icon(
            onPressed: () => _showEvaluarDialog(ticket),
            icon: const Icon(Icons.star),
            label: const Text('Evaluar Ticket'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warningColor,
            ),
          ),

        // Reabrir ticket (creador o admin)
        if ((isCreador || isAdmin) && ticket.estado == EstadoTicket.cerrado)
          OutlinedButton.icon(
            onPressed: () => _showReabrirDialog(ticket),
            icon: const Icon(Icons.refresh),
            label: const Text('Reabrir Ticket'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
              side: const BorderSide(color: AppTheme.errorColor),
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

  void _confirmarAccion({
    required String titulo,
    required String mensaje,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAsignarTecnicoDialog(TicketModel ticket) async {
    // Cargar lista de técnicos disponibles
    final usuarioCubit = getIt<UsuarioCubit>();
    await usuarioCubit.getTecnicos();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) => BlocProvider.value(
        value: usuarioCubit,
        child: AlertDialog(
          title: const Text('Asignar Técnico'),
          content: SizedBox(
            width: double.maxFinite,
            child: BlocBuilder<UsuarioCubit, UsuarioState>(
              builder: (context, state) {
                if (state is UsuarioLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (state is TecnicosLoaded) {
                  final tecnicos = state.tecnicos;

                  if (tecnicos.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'No hay técnicos disponibles',
                        textAlign: TextAlign.center,
                      ),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: tecnicos.length,
                    itemBuilder: (context, index) {
                      final tecnico = tecnicos[index];
                      final isAssigned = ticket.tecnicoAsignadoNombreAsignadoId == tecnico.id;

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.primaryColor,
                          child: Text(
                            tecnico.nombreCompleto.substring(0, 1).toUpperCase(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(tecnico.nombreCompleto),
                        subtitle: Text(tecnico.departamentoNombre ?? 'Sin departamento'),
                        trailing: isAssigned
                            ? const Icon(Icons.check_circle, color: AppTheme.successColor)
                            : null,
                        selected: isAssigned,
                        onTap: () {
                          Navigator.pop(dialogContext);
                          context.read<TicketCubit>().asignarTecnico(ticket.id, tecnico.id);
                        },
                      );
                    },
                  );
                }

                if (state is UsuarioError) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
                        const SizedBox(height: 8),
                        Text(
                          'Error al cargar técnicos',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          state.message,
                          style: Theme.of(context).textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showResolverDialog(TicketModel ticket) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolver Ticket'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Solución',
            hintText: 'Describe la solución aplicada...',
            border: OutlineInputBorder(),
          ),
          maxLines: 5,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context);
                context.read<TicketCubit>().resolverTicket(
                      ticketId: ticket.id,
                      solucion: controller.text,
                      tipoSolucion: TipoSolucion.resuelto,
                    );
              }
            },
            child: const Text('Resolver'),
          ),
        ],
      ),
    );
  }

  void _showReabrirDialog(TicketModel ticket) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reabrir Ticket'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Motivo',
            hintText: 'Indica el motivo de la reapertura...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context);
                context.read<TicketCubit>().reabrirTicket(
                      ticket.id,
                      controller.text,
                    );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Reabrir'),
          ),
        ],
      ),
    );
  }

  void _showEvaluarDialog(TicketModel ticket) {
    int calificacion = 5;
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Evaluar Ticket'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Calificación:'),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < calificacion ? Icons.star : Icons.star_border,
                      color: AppTheme.warningColor,
                      size: 32,
                    ),
                    onPressed: () {
                      setState(() {
                        calificacion = index + 1;
                      });
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Comentario (opcional)',
                  hintText: 'Comparte tu experiencia...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                context.read<TicketCubit>().evaluarTicket(
                      ticket.id,
                      calificacion,
                      controller.text.isNotEmpty ? controller.text : null,
                    );
              },
              child: const Text('Evaluar'),
            ),
          ],
        ),
      ),
    );
  }
}
