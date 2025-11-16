import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/roles/rol_cubit.dart';
import '../../../logic/roles/rol_state.dart';
import '../../../data/models/rol/rol_model.dart';
import '../../../config/theme.dart';
import '../../../core/di/injection.dart';
import '../../../core/utils/responsive.dart';
import '../../widgets/loading_card.dart';
import '../../widgets/empty_state.dart';
import 'rol_form_screen.dart';

class RolesListScreen extends StatefulWidget {
  const RolesListScreen({super.key});

  @override
  State<RolesListScreen> createState() => _RolesListScreenState();
}

class _RolesListScreenState extends State<RolesListScreen> {
  final _searchController = TextEditingController();
  List<RolModel> _roles = [];
  List<RolModel> _filteredRoles = [];

  @override
  void initState() {
    super.initState();
    _loadRoles();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadRoles() {
    context.read<RolCubit>().getRoles();
  }

  void _filterRoles(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRoles = _roles;
      } else {
        _filteredRoles = _roles.where((rol) {
          final nombreLower = rol.nombre.toLowerCase();
          final searchLower = query.toLowerCase();
          return nombreLower.contains(searchLower);
        }).toList();
      }
    });
  }

  Future<void> _onRefresh() async {
    _loadRoles();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _deleteRol(RolModel rol) {
    if (rol.esSistema) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se puede eliminar un rol del sistema'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Rol'),
        content: Text(
            '¿Está seguro que desea eliminar "${rol.nombre}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<RolCubit>().deleteRol(rol.id);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roles'),
      ),
      body: BlocConsumer<RolCubit, RolState>(
        listener: (context, state) {
          if (state is RolCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Rol creado exitosamente'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            _loadRoles();
          } else if (state is RolUpdated || state is PermisosAsignados) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Rol actualizado exitosamente'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            _loadRoles();
          } else if (state is RolDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Rol eliminado exitosamente'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            _loadRoles();
          } else if (state is RolError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is RolLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is RolesLoaded) {
            _roles = state.roles;
            if (_filteredRoles.isEmpty && _searchController.text.isEmpty) {
              _filteredRoles = _roles;
            }
          }

          final displayList = _filteredRoles;

          return Column(
            children: [
              // Barra de búsqueda
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterRoles('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: _filterRoles,
                ),
              ),

              // Lista de roles
              Expanded(
                child: displayList.isEmpty
                    ? const EmptyState(title: "No hay elementos",
                        icon: Icons.admin_panel_settings,
                        message: 'No se encontraron roles',
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
                                  childAspectRatio: constraints.maxWidth >= Breakpoints.desktop ? 1.5 : 1.2,
                                ),
                                itemCount: displayList.length,
                                itemBuilder: (context, index) {
                                  final rol = displayList[index];
                                  return _buildRolCard(rol);
                                },
                              );
                            } else {
                              return ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                itemCount: displayList.length,
                                itemBuilder: (context, index) {
                                  final rol = displayList[index];
                                  return _buildRolCard(rol);
                                },
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: context.read<RolCubit>(),
                child: const RolFormScreen(),
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
    );
  }

  Widget _buildRolCard(RolModel rol) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: rol.esSistema ? AppTheme.warningColor : AppTheme.primaryColor,
          child: Icon(
            rol.esSistema ? Icons.lock : Icons.admin_panel_settings,
            color: Colors.white,
          ),
        ),
        title: Row(
          children: [
            Text(
              rol.nombre,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (rol.esSistema) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.warningColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'SISTEMA',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.warningColor,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (rol.descripcion != null && rol.descripcion!.isNotEmpty)
              Text(rol.descripcion!),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.people, size: 16, color: AppTheme.greyDark),
                const SizedBox(width: 4),
                Text('${rol.cantidadUsuarios} usuarios'),
                const SizedBox(width: 16),
                Icon(Icons.security, size: 16, color: AppTheme.greyDark),
                const SizedBox(width: 4),
                Text('${rol.permisosIds.length} permisos'),
              ],
            ),
          ],
        ),
        trailing: rol.esSistema
            ? const Icon(Icons.lock, color: AppTheme.greyDark)
            : PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider.value(
                            value: context.read<RolCubit>(),
                            child: RolFormScreen(rol: rol),
                          ),
                        ),
                      );
                      break;
                    case 'delete':
                      _deleteRol(rol);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      leading: Icon(Icons.edit),
                      title: Text('Editar'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: ListTile(
                      leading: Icon(Icons.delete, color: AppTheme.errorColor),
                      title: Text('Eliminar',
                          style: TextStyle(color: AppTheme.errorColor)),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
