import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/tickets/ticket_cubit.dart';
import '../../../logic/tickets/ticket_state.dart';
import '../../../data/models/ticket/ticket_model.dart';
import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../widgets/ticket_kanban_card.dart';
import 'ticket_detail_screen.dart';
import 'ticket_form_screen.dart';
import 'tickets_list_screen.dart';
import '../../../core/di/injection.dart';

/// Pantalla de vista Kanban de tickets organizada por Tipo de Soporte
class TicketsKanbanScreen extends StatefulWidget {
  const TicketsKanbanScreen({super.key});

  @override
  State<TicketsKanbanScreen> createState() => _TicketsKanbanScreenState();
}

class _TicketsKanbanScreenState extends State<TicketsKanbanScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadTickets() {
    // Cargar todos los tickets sin filtros de paginación para el Kanban
    context.read<TicketCubit>().getTickets(
          pageNumber: 1,
          pageSize: 100, // Cargar más tickets para vista Kanban
        );
  }

  Map<TipoSoporte, List<TicketModel>> _groupTicketsByTipo(List<TicketModel> tickets) {
    final Map<TipoSoporte, List<TicketModel>> grouped = {
      TipoSoporte.soporteTecnico: [],
      TipoSoporte.softland: [],
      TipoSoporte.dodi: [],
      TipoSoporte.otro: [],
    };

    for (var ticket in tickets) {
      grouped[ticket.tipoSoporte]?.add(ticket);
    }

    return grouped;
  }

  Color _getColumnColor(TipoSoporte tipo) {
    switch (tipo) {
      case TipoSoporte.soporteTecnico:
        return AppTheme.primaryColor;
      case TipoSoporte.softland:
        return const Color(0xFF9C27B0); // Purple
      case TipoSoporte.dodi:
        return const Color(0xFFFF9800); // Orange
      case TipoSoporte.otro:
        return AppTheme.greyDark;
    }
  }

  IconData _getColumnIcon(TipoSoporte tipo) {
    switch (tipo) {
      case TipoSoporte.soporteTecnico:
        return Icons.support_agent;
      case TipoSoporte.softland:
        return Icons.business;
      case TipoSoporte.dodi:
        return Icons.inventory_2;
      case TipoSoporte.otro:
        return Icons.more_horiz;
    }
  }

  void _navigateToTicketDetail(TicketModel ticket) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BlocProvider(
          create: (context) => getIt<TicketCubit>(),
          child: TicketDetailScreen(ticketId: ticket.id),
        ),
      ),
    ).then((_) => _loadTickets());
  }

  void _navigateToCreateTicket() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TicketFormScreen(),
      ),
    ).then((_) => _loadTickets());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tickets - Vista Kanban'),
        actions: [
          IconButton(
            icon: const Icon(Icons.view_list),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) => getIt<TicketCubit>(),
                    child: const TicketsListScreen(mode: TicketListMode.myTickets),
                  ),
                ),
              );
            },
            tooltip: 'Vista Lista',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTickets,
            tooltip: 'Recargar',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _navigateToCreateTicket,
            tooltip: 'Nuevo Ticket',
          ),
        ],
      ),
      body: BlocBuilder<TicketCubit, TicketState>(
        builder: (context, state) {
          if (state is TicketLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TicketError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppTheme.errorColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar tickets',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.greyDark,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _loadTickets,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is TicketsLoaded) {
            final tickets = state.tickets.items;
            if (tickets.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 80,
                      color: AppTheme.greyLight,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No hay tickets',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.greyDark,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Crea un nuevo ticket para comenzar',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.greyDark,
                          ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _navigateToCreateTicket,
                      icon: const Icon(Icons.add),
                      label: const Text('Crear Ticket'),
                    ),
                  ],
                ),
              );
            }

            final groupedTickets = _groupTicketsByTipo(tickets);

            return Column(
              children: [
                // Header con estadísticas
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppTheme.backgroundLight,
                  child: Row(
                    children: [
                      _buildStatCard(
                        context,
                        'Total',
                        tickets.length.toString(),
                        Icons.confirmation_number,
                        AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        context,
                        'Soporte',
                        groupedTickets[TipoSoporte.soporteTecnico]!.length.toString(),
                        Icons.support_agent,
                        _getColumnColor(TipoSoporte.soporteTecnico),
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        context,
                        'Softland',
                        groupedTickets[TipoSoporte.softland]!.length.toString(),
                        Icons.business,
                        _getColumnColor(TipoSoporte.softland),
                      ),
                      const SizedBox(width: 12),
                      _buildStatCard(
                        context,
                        'Dodi',
                        groupedTickets[TipoSoporte.dodi]!.length.toString(),
                        Icons.inventory_2,
                        _getColumnColor(TipoSoporte.dodi),
                      ),
                    ],
                  ),
                ),

                // Kanban board
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: TipoSoporte.values.map((tipo) {
                        final ticketsInColumn = groupedTickets[tipo] ?? [];
                        return _buildKanbanColumn(
                          context,
                          tipo,
                          ticketsInColumn,
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToCreateTicket,
        child: const Icon(Icons.add),
        tooltip: 'Crear Ticket',
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.greyDark,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKanbanColumn(
    BuildContext context,
    TipoSoporte tipo,
    List<TicketModel> tickets,
  ) {
    final columnColor = _getColumnColor(tipo);

    return Container(
      width: 320,
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Column header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: columnColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(
                  _getColumnIcon(tipo),
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tipo.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tickets.length.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Column content
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: columnColor.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                border: Border.all(color: columnColor.withOpacity(0.2)),
              ),
              child: tickets.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.inbox_outlined,
                              size: 48,
                              color: columnColor.withOpacity(0.3),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Sin tickets',
                              style: TextStyle(
                                color: columnColor.withOpacity(0.6),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: tickets.length,
                      itemBuilder: (context, index) {
                        return TicketKanbanCard(
                          ticket: tickets[index],
                          onTap: () => _navigateToTicketDetail(tickets[index]),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
