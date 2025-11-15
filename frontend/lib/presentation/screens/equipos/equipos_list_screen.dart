import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/equipos/equipo_cubit.dart';
import '../../../logic/equipos/equipo_state.dart';
import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../core/di/injection.dart';
import '../../../core/utils/responsive.dart';
import '../../widgets/equipo_card.dart';
import '../../widgets/loading_card.dart';
import '../../widgets/empty_state.dart';
import 'equipo_detail_screen.dart';
import 'equipo_form_screen.dart';
import 'qr_scanner_screen.dart';

class EquiposListScreen extends StatefulWidget {
  final EquipoListMode mode;

  const EquiposListScreen({
    super.key,
    this.mode = EquipoListMode.all,
  });

  @override
  State<EquiposListScreen> createState() => _EquiposListScreenState();
}

class _EquiposListScreenState extends State<EquiposListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  EstadoEquipo? _estadoFilter;
  CondicionEquipo? _condicionFilter;
  int _currentPage = 1;
  final int _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadEquipos();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadEquipos({bool refresh = false}) {
    if (refresh) {
      _currentPage = 1;
    }

    switch (widget.mode) {
      case EquipoListMode.all:
        context.read<EquipoCubit>().getEquipos(
              pageNumber: _currentPage,
              pageSize: _pageSize,
              estado: _estadoFilter,
              condicion: _condicionFilter,
              searchTerm: _searchController.text.isNotEmpty
                  ? _searchController.text
                  : null,
            );
        break;
      case EquipoListMode.myEquipos:
        context.read<EquipoCubit>().getMisEquipos();
        break;
      case EquipoListMode.disponibles:
        context.read<EquipoCubit>().getEquiposDisponibles();
        break;
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<EquipoCubit>().state;
      if (state is EquiposLoaded && !state.isLoadingMore) {
        if (state.equipos.hasMore) {
          _currentPage++;
          context.read<EquipoCubit>().getEquipos(
                pageNumber: _currentPage,
                pageSize: _pageSize,
                estado: _estadoFilter,
                condicion: _condicionFilter,
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
    _loadEquipos(refresh: true);
    await Future.delayed(const Duration(seconds: 1));
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FilterSheet(
        estadoFilter: _estadoFilter,
        condicionFilter: _condicionFilter,
        onApply: (estado, condicion) {
          setState(() {
            _estadoFilter = estado;
            _condicionFilter = condicion;
          });
          _loadEquipos(refresh: true);
        },
        onClear: () {
          setState(() {
            _estadoFilter = null;
            _condicionFilter = null;
          });
          _loadEquipos(refresh: true);
        },
      ),
    );
  }

  String _getTitle() {
    switch (widget.mode) {
      case EquipoListMode.all:
        return 'Todos los Equipos';
      case EquipoListMode.myEquipos:
        return 'Mis Equipos';
      case EquipoListMode.disponibles:
        return 'Equipos Disponibles';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (context) => getIt<EquipoCubit>(),
                    child: const QRScannerScreen(),
                  ),
                ),
              );

              if (result == true) {
                _loadEquipos(refresh: true);
              }
            },
          ),
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.filter_list),
                if (_estadoFilter != null || _condicionFilter != null)
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
      body: BlocConsumer<EquipoCubit, EquipoState>(
        listener: (context, state) {
          if (state is EquipoError) {
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
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por marca, modelo, serie...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _loadEquipos(refresh: true);
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onSubmitted: (_) => _loadEquipos(refresh: true),
                ),
              ),

              // Lista de equipos
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
                create: (context) => getIt<EquipoCubit>(),
                child: const EquipoFormScreen(),
              ),
            ),
          );

          if (result == true) {
            _loadEquipos(refresh: true);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildContent(EquipoState state) {
    if (state is EquipoLoading) {
      return const LoadingList();
    }

    if (state is EquiposLoaded) {
      if (state.equipos.items.isEmpty) {
        return EmptyState(
          icon: Icons.devices_outlined,
          title: 'No hay equipos',
          message: _getEmptyMessage(),
          actionLabel: 'Agregar Equipo',
          onAction: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider(
                  create: (context) => getIt<EquipoCubit>(),
                  child: const EquipoFormScreen(),
                ),
              ),
            );

            if (result == true) {
              _loadEquipos(refresh: true);
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
                itemCount: state.equipos.items.length +
                    (state.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.equipos.items.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final equipo = state.equipos.items[index];
                  return EquipoCard(
                    equipo: equipo,
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) => getIt<EquipoCubit>(),
                            child: EquipoDetailScreen(equipoId: equipo.id),
                          ),
                        ),
                      );

                      if (result == true) {
                        _loadEquipos(refresh: true);
                      }
                    },
                  );
                },
              );
            } else {
              return ListView.builder(
                controller: _scrollController,
                itemCount: state.equipos.items.length +
                    (state.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.equipos.items.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final equipo = state.equipos.items[index];
                  return EquipoCard(
                    equipo: equipo,
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) => getIt<EquipoCubit>(),
                            child: EquipoDetailScreen(equipoId: equipo.id),
                          ),
                        ),
                      );

                      if (result == true) {
                        _loadEquipos(refresh: true);
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
      title: 'Error al cargar equipos',
      message: 'Por favor, intenta nuevamente',
      actionLabel: 'Reintentar',
      onAction: () => _loadEquipos(refresh: true),
    );
  }

  String _getEmptyMessage() {
    switch (widget.mode) {
      case EquipoListMode.all:
        return 'No se encontraron equipos con los filtros seleccionados';
      case EquipoListMode.myEquipos:
        return 'No tienes equipos asignados actualmente';
      case EquipoListMode.disponibles:
        return 'No hay equipos disponibles para asignación';
    }
  }
}

/// Hoja de filtros
class _FilterSheet extends StatefulWidget {
  final EstadoEquipo? estadoFilter;
  final CondicionEquipo? condicionFilter;
  final Function(EstadoEquipo?, CondicionEquipo?) onApply;
  final VoidCallback onClear;

  const _FilterSheet({
    required this.estadoFilter,
    required this.condicionFilter,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  EstadoEquipo? _selectedEstado;
  CondicionEquipo? _selectedCondicion;

  @override
  void initState() {
    super.initState();
    _selectedEstado = widget.estadoFilter;
    _selectedCondicion = widget.condicionFilter;
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
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
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    // Filtro de estado
                    Text(
                      'Estado',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: EstadoEquipo.values.map((estado) {
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

                    // Filtro de condición
                    Text(
                      'Condición',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: CondicionEquipo.values.map((condicion) {
                        final isSelected = _selectedCondicion == condicion;
                        return FilterChip(
                          label: Text(condicion.displayName),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _selectedCondicion = selected ? condicion : null;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Botón aplicar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(
                      _selectedEstado,
                      _selectedCondicion,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Aplicar Filtros'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Modo de visualización de la lista de equipos
enum EquipoListMode {
  all,
  myEquipos,
  disponibles,
}
