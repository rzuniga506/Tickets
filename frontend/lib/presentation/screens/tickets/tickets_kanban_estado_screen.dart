import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/tickets/ticket_cubit.dart';
import '../../../logic/tickets/ticket_state.dart';
import '../../../data/models/ticket/ticket_model.dart';
import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../core/di/injection.dart';
import '../../widgets/loading_card.dart';
import '../../widgets/empty_state.dart';
import 'ticket_detail_screen.dart';

class TicketsKanbanEstadoScreen extends StatefulWidget {
  const TicketsKanbanEstadoScreen({super.key});

  @override
  State<TicketsKanbanEstadoScreen> createState() => _TicketsKanbanEstadoScreenState();
}

class _TicketsKanbanEstadoScreenState extends State<TicketsKanbanEstadoScreen> {
  @override
  void initState() {
    super.initState();
    context.read<TicketCubit>().getTickets(pageSize: 100);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tickets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TicketCubit>().getTickets(pageSize: 100);
            },
          ),
        ],
      ),
      body: BlocBuilder<TicketCubit, TicketState>(
        builder: (context, state) {
          if (state is TicketLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TicketError) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'Error al cargar tickets',
              message: state.message,
              actionLabel: 'Reintentar',
              onAction: () {
                context.read<TicketCubit>().getTickets(pageSize: 100);
              },
            );
          }

          if (state is TicketsLoaded) {
            final tickets = state.tickets.items;

            if (tickets.isEmpty) {
              return const EmptyState(
                icon: Icons.confirmation_number_outlined,
                title: 'No hay tickets',
                message: 'Aún no se han creado tickets en el sistema',
              );
            }

            // Agrupar tickets por estado
            final ticketsPorEstado = <EstadoTicket, List<TicketModel>>{};
            for (final ticket in tickets) {
              if (!ticketsPorEstado.containsKey(ticket.estado)) {
                ticketsPorEstado[ticket.estado] = [];
              }
              ticketsPorEstado[ticket.estado]!.add(ticket);
            }

            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: EstadoTicket.values.map((estado) {
                  final ticketsEstado = ticketsPorEstado[estado] ?? [];
                  return _buildKanbanColumn(
                    estado: estado,
                    tickets: ticketsEstado,
                    context: context,
                  );
                }).toList(),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildKanbanColumn({
    required EstadoTicket estado,
    required List<TicketModel> tickets,
    required BuildContext context,
  }) {
    final color = _getEstadoColor(estado);

    return Container(
      width: 320,
      margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de la columna
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  _getEstadoIcon(estado),
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    estado.displayName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${tickets.length}',
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Lista de tickets
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: tickets.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          'No hay tickets en ${estado.displayName}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: tickets.length,
                      itemBuilder: (context, index) {
                        return _buildTicketCard(tickets[index], context);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTicketCard(TicketModel ticket, BuildContext context) {
    final prioridadColor = _getPrioridadColor(ticket.prioridad);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => getIt<TicketCubit>(),
                child: TicketDetailScreen(ticketId: ticket.id),
              ),
            ),
          );
          // Refresh después de ver detalle
          if (mounted) {
            context.read<TicketCubit>().getTickets(pageSize: 100);
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Número y prioridad
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: prioridadColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: prioridadColor.withOpacity(0.3)),
                    ),
                    child: Text(
                      ticket.numeroTicket,
                      style: TextStyle(
                        color: prioridadColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _getPrioridadIcon(ticket.prioridad),
                    color: prioridadColor,
                    size: 16,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Asunto
              Text(
                ticket.asunto,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              // Categoría (Tipo de Soporte)
              if (ticket.categoriaTicketNombre != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.category,
                      size: 14,
                      color: AppTheme.primaryColor.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        ticket.categoriaTicketNombre!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
              ],
              // Solicitante
              Row(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      ticket.solicitanteNombre,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              // Técnico asignado (si existe)
              if (ticket.tecnicoAsignadoNombre != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.support_agent,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        ticket.tecnicoAsignadoNombre!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              // SLA indicator
              if (ticket.minutosRestantesSLA != null &&
                  ticket.minutosRestantesSLA! > 0 &&
                  ticket.estado != EstadoTicket.cerrado &&
                  ticket.estado != EstadoTicket.resuelto) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: ticket.slaProximoVencer
                        ? AppTheme.errorColor.withOpacity(0.1)
                        : AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        size: 12,
                        color: ticket.slaProximoVencer
                            ? AppTheme.errorColor
                            : AppTheme.successColor,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${ticket.minutosRestantesSLA} min',
                        style: TextStyle(
                          fontSize: 10,
                          color: ticket.slaProximoVencer
                              ? AppTheme.errorColor
                              : AppTheme.successColor,
                          fontWeight: FontWeight.w600,
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
    );
  }

  Color _getEstadoColor(EstadoTicket estado) {
    switch (estado) {
      case EstadoTicket.nuevo:
        return const Color(0xFF3B82F6); // Blue
      case EstadoTicket.asignado:
        return const Color(0xFFF59E0B); // Amber
      case EstadoTicket.enProceso:
        return const Color(0xFF8B5CF6); // Purple
      case EstadoTicket.enEspera:
        return const Color(0xFFEC4899); // Pink
      case EstadoTicket.resuelto:
        return const Color(0xFF10B981); // Green
      case EstadoTicket.cerrado:
        return const Color(0xFF6B7280); // Gray
      case EstadoTicket.cancelado:
        return const Color(0xFFEF4444); // Red
      case EstadoTicket.reabierto:
        return const Color(0xFFF97316); // Orange
    }
  }

  IconData _getEstadoIcon(EstadoTicket estado) {
    switch (estado) {
      case EstadoTicket.nuevo:
        return Icons.fiber_new;
      case EstadoTicket.asignado:
        return Icons.assignment_ind;
      case EstadoTicket.enProceso:
        return Icons.pending_actions;
      case EstadoTicket.enEspera:
        return Icons.pause_circle_outline;
      case EstadoTicket.resuelto:
        return Icons.check_circle_outline;
      case EstadoTicket.cerrado:
        return Icons.lock_outline;
      case EstadoTicket.cancelado:
        return Icons.cancel_outlined;
      case EstadoTicket.reabierto:
        return Icons.replay;
    }
  }

  Color _getPrioridadColor(PrioridadTicket prioridad) {
    switch (prioridad) {
      case PrioridadTicket.baja:
        return const Color(0xFF10B981); // Green
      case PrioridadTicket.media:
        return const Color(0xFFF59E0B); // Amber
      case PrioridadTicket.alta:
        return const Color(0xFFF97316); // Orange
      case PrioridadTicket.critica:
        return const Color(0xFFEF4444); // Red
    }
  }

  IconData _getPrioridadIcon(PrioridadTicket prioridad) {
    switch (prioridad) {
      case PrioridadTicket.baja:
        return Icons.arrow_downward;
      case PrioridadTicket.media:
        return Icons.remove;
      case PrioridadTicket.alta:
        return Icons.arrow_upward;
      case PrioridadTicket.critica:
        return Icons.priority_high;
    }
  }
}
