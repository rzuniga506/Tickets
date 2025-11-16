import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/permisos/permiso_cubit.dart';
import '../../../logic/permisos/permiso_state.dart';
import '../../../data/models/permiso/permiso_model.dart';
import '../../../config/theme.dart';
import '../../../core/utils/responsive.dart';
import '../../widgets/empty_state.dart';

class PermisosViewScreen extends StatefulWidget {
  const PermisosViewScreen({super.key});

  @override
  State<PermisosViewScreen> createState() => _PermisosViewScreenState();
}

class _PermisosViewScreenState extends State<PermisosViewScreen> {
  List<PermisoModel> _permisos = [];
  final _searchController = TextEditingController();
  List<PermisoModel> _filteredPermisos = [];

  @override
  void initState() {
    super.initState();
    _loadPermisos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadPermisos() {
    context.read<PermisoCubit>().getPermisos();
  }

  void _filterPermisos(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredPermisos = _permisos;
      } else {
        _filteredPermisos = _permisos.where((permiso) {
          final nombreLower = permiso.nombre.toLowerCase();
          final codigoLower = permiso.codigo.toLowerCase();
          final moduloLower = permiso.modulo.toLowerCase();
          final searchLower = query.toLowerCase();
          return nombreLower.contains(searchLower) ||
              codigoLower.contains(searchLower) ||
              moduloLower.contains(searchLower);
        }).toList();
      }
    });
  }

  Map<String, List<PermisoModel>> _groupPermisosByModulo() {
    final Map<String, List<PermisoModel>> grouped = {};
    for (var permiso in _filteredPermisos) {
      if (!grouped.containsKey(permiso.modulo)) {
        grouped[permiso.modulo] = [];
      }
      grouped[permiso.modulo]!.add(permiso);
    }
    return grouped;
  }

  Future<void> _onRefresh() async {
    _loadPermisos();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Permisos del Sistema'),
      ),
      body: BlocConsumer<PermisoCubit, PermisoState>(
        listener: (context, state) {
          if (state is PermisoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is PermisoLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is PermisosLoaded) {
            _permisos = state.permisos;
            if (_filteredPermisos.isEmpty && _searchController.text.isEmpty) {
              _filteredPermisos = _permisos;
            }
          }

          final groupedPermisos = _groupPermisosByModulo();

          return Column(
            children: [
              // Barra de búsqueda
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre, código o módulo...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterPermisos('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: _filterPermisos,
                ),
              ),

              // Info card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Card(
                  color: AppTheme.infoColor.withOpacity(0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppTheme.infoColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Los permisos son definidos por el sistema y se asignan a través de roles.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Lista de permisos agrupados
              Expanded(
                child: _filteredPermisos.isEmpty
                    ? const EmptyState(
                        icon: Icons.security,
                        title: 'Sin permisos',
                        message: 'No se encontraron permisos',
                      )
                    : RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            // En desktop/tablet: Grid, en móvil: Lista
                            if (constraints.maxWidth >= Breakpoints.tablet) {
                              final columns = Breakpoints.getGridColumns(context);
                              return GridView.builder(
                                padding: EdgeInsets.all(Breakpoints.getHorizontalPadding(context)),
                                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columns,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: (!constraints.maxWidth.isFinite || constraints.maxWidth <= 0)
                                      ? 1.0
                                      : (constraints.maxWidth >= Breakpoints.desktop ? 0.75 : 0.65),
                                ),
                                itemCount: groupedPermisos.entries.length,
                                itemBuilder: (context, index) {
                                  final entry = groupedPermisos.entries.elementAt(index);
                                  final modulo = entry.key;
                                  final permisos = entry.value;

                                  return Card(
                                    child: ExpansionTile(
                                      title: Text(
                                        modulo,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      subtitle: Text('${permisos.length} permisos'),
                                      leading: CircleAvatar(
                                        backgroundColor: AppTheme.primaryColor,
                                        child: Text(
                                          '${permisos.length}',
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      children: permisos.map((permiso) {
                                        return ListTile(
                                          leading: const Icon(
                                            Icons.vpn_key,
                                            color: AppTheme.accentColor,
                                          ),
                                          title: Text(permiso.nombre),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Código: ${permiso.codigo}',
                                                style: Theme.of(context).textTheme.bodySmall,
                                              ),
                                              if (permiso.descripcion != null &&
                                                  permiso.descripcion!.isNotEmpty)
                                                Text(
                                                  permiso.descripcion!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        fontStyle: FontStyle.italic,
                                                      ),
                                                ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  );
                                },
                              );
                            } else {
                              return ListView(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                children: groupedPermisos.entries.map((entry) {
                                  final modulo = entry.key;
                                  final permisos = entry.value;

                                  return Card(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    child: ExpansionTile(
                                      title: Text(
                                        modulo,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      subtitle: Text('${permisos.length} permisos'),
                                      leading: CircleAvatar(
                                        backgroundColor: AppTheme.primaryColor,
                                        child: Text(
                                          '${permisos.length}',
                                          style: const TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      children: permisos.map((permiso) {
                                        return ListTile(
                                          leading: const Icon(
                                            Icons.vpn_key,
                                            color: AppTheme.accentColor,
                                          ),
                                          title: Text(permiso.nombre),
                                          subtitle: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Código: ${permiso.codigo}',
                                                style: Theme.of(context).textTheme.bodySmall,
                                              ),
                                              if (permiso.descripcion != null &&
                                                  permiso.descripcion!.isNotEmpty)
                                                Text(
                                                  permiso.descripcion!,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall
                                                      ?.copyWith(
                                                        fontStyle: FontStyle.italic,
                                                      ),
                                                ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  );
                                }).toList(),
                              );
                            }
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
