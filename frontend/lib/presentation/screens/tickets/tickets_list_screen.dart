import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/tickets/ticket_cubit.dart';
import '../../../logic/tickets/ticket_state.dart';
import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../core/di/injection.dart';
import '../../../core/utils/responsive.dart';
import '../../widgets/ticket_card.dart';
import '../../widgets/loading_card.dart';
import '../../widgets/empty_state.dart';
import 'ticket_detail_screen.dart';
import 'ticket_form_screen.dart';

class TicketsListScreen extends StatefulWidget {
  final TicketListMode mode;

  const TicketsListScreen({
    super.key,
    this.mode = TicketListMode.all,
  });

  @override
  State<TicketsListScreen> createState() => _TicketsListScreenState();
}

class _TicketsListScreenState extends State<TicketsListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  EstadoTicket? _estadoFilter;
  PrioridadTicket? _prioridadFilter;
  int _currentPage = 1;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadTickets();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadTickets({bool refresh = false}) {
    if (refresh) {
      _currentPage = 1;
    }

    switch (widget.mode) {
      case TicketListMode.all:
        context.read<TicketCubit>().getTickets(
              pageNumber: _currentPage,
              pageSize: _pageSize,
              estado: _estadoFilter,
              prioridad: _prioridadFilter,
              searchTerm: _searchController.text.isNotEmpty
                  ? _searchController.text
                  : null,
            );
        break;
      case TicketListMode.myTickets:
        context.read<TicketCubit>().getMisTickets(
              pageNumber: _currentPage,
              pageSize: _pageSize,
              estado: _estadoFilter,
            );
        break;
      case TicketListMode.assigned:
        context.read<TicketCubit>().getTicketsAsignados(
              pageNumber: _currentPage,
              pageSize: _pageSize,
              estado: _estadoFilter,
            );
        break;
      case TicketListMode.pending:
        context.read<TicketCubit>().getTicketsPendientes(
              pageNumber: _currentPage,
              pageSize: _pageSize,
            );
        break;
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<TicketCubit>().state;
      if (state is TicketsLoaded && !state.isLoadingMore) {
        if (state.tickets.hasNextPage) {
          _currentPage++;
          context.read<TicketCubit>().getTickets(
                pageNumber: _currentPage,
                pageSize: _pageSize,
                estado: _estadoFilter,
                prioridad: _prioridadFilter,
                searchTerm: _searchController.text.isNotEmpty
                    ? _searchController.text
                    : null,
                loadMore: true,
              );
        }
      }
    }
  }

  Future<void> _onRefresh() async {
    _loadTickets(refresh: true);
    // Esperar a que se complete la carga
    await Future.delayed(const Duration(seconds: 1));
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _FilterSheet(
        estadoFilter: _estadoFilter,
        prioridadFilter: _prioridadFilter,
        onApply: (estado, prioridad) {
          setState(() {
            _estadoFilter = estado;
            _prioridadFilter = prioridad;
          });
          _loadTickets(refresh: true);
        },
        onClear: () {
          setState(() {
            _estadoFilter = null;
            _prioridadFilter = null;
          });
          _loadTickets(refresh: true);
        },
      ),
    );
  }

  String _getTitle() {
    switch (widget.mode) {
      case TicketListMode.all:
        return 'Todos los Tickets';
      case TicketListMode.myTickets:
        return 'Mis Tickets';
      case TicketListMode.assigned:
        return 'Tickets Asignados';
      case TicketListMode.pending:
        return 'Tickets Pendientes';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (_estadoFilter != null || _prioridadFilter != null)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppTheme.errorColor,
                        shape: BoxShape.circle,
                      ),
                      child: const SizedBox(width: 8, height: 8),
                    ),
                  ),
              ],
            ),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: BlocConsumer<TicketCubit, TicketState>(
        listener: (context, state) {
          if (state is TicketError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Barra de búsqueda
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Breakpoints.getHorizontalPadding(context),
                  vertical: 16,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar tickets...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _loadTickets(refresh: true);
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSubmitted: (_) => _loadTickets(refresh: true),
                ),
              ),

              // Lista de tickets
              Expanded(
                child: _buildContent(state),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider(
                create: (context) => getIt<TicketCubit>(),
                child: const TicketFormScreen(),
              ),
            ),
          );

          if (result == true) {
            _loadTickets(refresh: true);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(TicketState state) {
    if (state is TicketLoading) {
      return const LoadingList();
    }

    if (state is TicketsLoaded) {
      if (state.tickets.items.isEmpty) {
        return EmptyState(
          icon: Icons.confirmation_number_outlined,
          title: 'No hay tickets',
          message: _getEmptyMessage(),
          actionLabel: 'Crear Ticket',
          onAction: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => getIt<TicketCubit>(),
                  child: const TicketFormScreen(),
                ),
              ),
            );

            if (result == true) {
              _loadTickets(refresh: true);
            }
          },
        );
      }

      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // En desktop/tablet: Grid, en móvil: Lista
            if (constraints.maxWidth >= Breakpoints.tablet) {
              final columns = Breakpoints.getGridColumns(context);
              return GridView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(Breakpoints.getHorizontalPadding(context)),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: constraints.maxWidth >= Breakpoints.desktop ? 1.5 : 1.2,
                ),
                itemCount: state.tickets.items.length +
                    (state.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.tickets.items.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final ticket = state.tickets.items[index];
                  return TicketCard(
                    ticket: ticket,
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) => getIt<TicketCubit>(),
                            child: TicketDetailScreen(ticketId: ticket.id),
                          ),
                        ),
                      );

                      if (result == true) {
                        _loadTickets(refresh: true);
                      }
                    },
                  );
                },
              );
            } else {
              return ListView.builder(
                controller: _scrollController,
                itemCount: state.tickets.items.length +
                    (state.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.tickets.items.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final ticket = state.tickets.items[index];
                  return TicketCard(
                    ticket: ticket,
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) => getIt<TicketCubit>(),
                            child: TicketDetailScreen(ticketId: ticket.id),
                          ),
                        ),
                      );

                      if (result == true) {
                        _loadTickets(refresh: true);
                      }
                    },
                  );
                },
              );
            }
          },
        ),
      );
    }

    return EmptyState(
      icon: Icons.error_outline,
      title: 'Error al cargar tickets',
      message: 'Por favor, intenta nuevamente',
      actionLabel: 'Reintentar',
      onAction: () => _loadTickets(refresh: true),
    );
  }

  String _getEmptyMessage() {
    switch (widget.mode) {
      case TicketListMode.all:
        return 'No se encontraron tickets con los filtros seleccionados';
      case TicketListMode.myTickets:
        return 'No has creado ningún ticket todavía';
      case TicketListMode.assigned:
        return 'No tienes tickets asignados en este momento';
      case TicketListMode.pending:
        return 'No hay tickets pendientes';
    }
  }
}

/// Hoja de filtros
class _FilterSheet extends StatefulWidget {
  final EstadoTicket? estadoFilter;
  final PrioridadTicket? prioridadFilter;
  final Function(EstadoTicket?, PrioridadTicket?) onApply;
  final VoidCallback onClear;

  const _FilterSheet({
    required this.estadoFilter,
    required this.prioridadFilter,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  EstadoTicket? _selectedEstado;
  PrioridadTicket? _selectedPrioridad;

  @override
  void initState() {
    super.initState();
    _selectedEstado = widget.estadoFilter;
    _selectedPrioridad = widget.prioridadFilter;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtros',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton(
                onPressed: () {
                  widget.onClear();
                  Navigator.pop(context);
                },
                child: const Text('Limpiar'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Filtro de estado
          Text(
            'Estado',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: EstadoTicket.values.map((estado) {
              final isSelected = _selectedEstado == estado;
              return FilterChip(
                label: Text(estado.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedEstado = selected ? estado : null;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Filtro de prioridad
          Text(
            'Prioridad',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PrioridadTicket.values.map((prioridad) {
              final isSelected = _selectedPrioridad == prioridad;
              return FilterChip(
                label: Text(prioridad.displayName),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedPrioridad = selected ? prioridad : null;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Botón aplicar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_selectedEstado, _selectedPrioridad);
                Navigator.pop(context);
              },
              child: const Text('Aplicar Filtros'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Modo de visualización de la lista de tickets
enum TicketListMode {
  all,
  myTickets,
  assigned,
  pending,
}
