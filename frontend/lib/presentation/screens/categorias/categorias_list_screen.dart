import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/categorias/categoria_cubit.dart';
import '../../../logic/categorias/categoria_state.dart';
import '../../../data/models/categoria/categoria_ticket_model.dart';
import '../../../config/theme.dart';
import '../../../core/utils/responsive.dart';
import '../../widgets/empty_state.dart';
import 'categoria_form_screen.dart';

class CategoriasListScreen extends StatefulWidget {
  const CategoriasListScreen({super.key});

  @override
  State<CategoriasListScreen> createState() => _CategoriasListScreenState();
}

class _CategoriasListScreenState extends State<CategoriasListScreen> {
  List<CategoriaTicketModel> _categorias = [];
  bool _showOnlyActive = false;

  @override
  void initState() {
    super.initState();
    _loadCategorias();
  }

  void _loadCategorias() {
    if (_showOnlyActive) {
      context.read<CategoriaCubit>().getCategoriasActivas();
    } else {
      context.read<CategoriaCubit>().getCategorias();
    }
  }

  Future<void> _onRefresh() async {
    _loadCategorias();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Filtrar Categorías'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('Solo activas'),
                  value: _showOnlyActive,
                  onChanged: (value) {
                    setState(() {
                      _showOnlyActive = value;
                    });
                  },
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              this.setState(() {});
              _loadCategorias();
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  void _toggleActivo(CategoriaTicketModel categoria) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(categoria.activo ? 'Desactivar Categoría' : 'Activar Categoría'),
        content: Text(categoria.activo
            ? '¿Está seguro que desea desactivar "${categoria.nombre}"?'
            : '¿Está seguro que desea activar "${categoria.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CategoriaCubit>().toggleActivo(categoria.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: categoria.activo ? AppTheme.warningColor : AppTheme.successColor,
            ),
            child: Text(categoria.activo ? 'Desactivar' : 'Activar'),
          ),
        ],
      ),
    );
  }

  void _deleteCategoria(CategoriaTicketModel categoria) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Categoría'),
        content: Text(
            '¿Está seguro que desea eliminar "${categoria.nombre}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<CategoriaCubit>().deleteCategoria(categoria.id);
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

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppTheme.greyDark;
    }
  }

  IconData _parseIcon(String? iconName) {
    if (iconName == null) return Icons.category;

    final iconMap = {
      'computer': Icons.computer,
      'bug_report': Icons.bug_report,
      'wifi': Icons.wifi,
      'security': Icons.security,
      'vpn_key': Icons.vpn_key,
      'settings': Icons.settings,
      'help_outline': Icons.help_outline,
    };

    return iconMap[iconName] ?? Icons.category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: BlocConsumer<CategoriaCubit, CategoriaState>(
        listener: (context, state) {
          if (state is CategoriaCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Categoría creada exitosamente'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            _loadCategorias();
          } else if (state is CategoriaUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Categoría actualizada exitosamente'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            _loadCategorias();
          } else if (state is CategoriaDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Categoría eliminada exitosamente'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            _loadCategorias();
          } else if (state is CategoriasReordered) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Orden actualizado exitosamente'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            _loadCategorias();
          } else if (state is CategoriaError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CategoriaLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CategoriasLoaded) {
            _categorias = state.categorias;
          }

          return _categorias.isEmpty
              ? const EmptyState(
                  icon: Icons.category,
                  title: 'Sin categorías',
                  message: 'No se encontraron categorías',
                )
              : RefreshIndicator(
                  onRefresh: _onRefresh,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // En tablet/desktop: Grid, en móvil: ReorderableListView
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
                          itemCount: _categorias.length,
                          itemBuilder: (context, index) {
                            final categoria = _categorias[index];
                            return _buildCategoriaCard(categoria, index);
                          },
                        );
                      } else {
                        return ReorderableListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _categorias.length,
                          onReorder: (oldIndex, newIndex) {
                            setState(() {
                              if (newIndex > oldIndex) {
                                newIndex -= 1;
                              }
                              final item = _categorias.removeAt(oldIndex);
                              _categorias.insert(newIndex, item);
                            });

                            // Actualizar orden en el backend
                            final ordenMap = <int, int>{};
                            for (var i = 0; i < _categorias.length; i++) {
                              ordenMap[_categorias[i].id] = i;
                            }
                            context.read<CategoriaCubit>().reorderCategorias(ordenMap);
                          },
                          itemBuilder: (context, index) {
                            final categoria = _categorias[index];
                            return _buildCategoriaCard(categoria, index);
                          },
                        );
                      }
                    },
                  ),
                );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlocProvider.value(
                value: context.read<CategoriaCubit>(),
                child: const CategoriaFormScreen(),
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nueva'),
      ),
    );
  }

  Widget _buildCategoriaCard(CategoriaTicketModel categoria, int index) {
    final color = _parseColor(categoria.color);
    final icon = _parseIcon(categoria.icono);

    return Card(
      key: ValueKey(categoria.id),
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          categoria.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (categoria.descripcion != null && categoria.descripcion!.isNotEmpty)
              Text(categoria.descripcion!),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    categoria.color,
                    style: TextStyle(fontSize: 11, color: color),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Orden: ${categoria.orden}',
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 8),
                if (!categoria.activo)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.greyDark.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Inactiva',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.drag_handle, color: AppTheme.greyDark),
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BlocProvider.value(
                          value: context.read<CategoriaCubit>(),
                          child: CategoriaFormScreen(categoria: categoria),
                        ),
                      ),
                    );
                    break;
                  case 'toggle':
                    _toggleActivo(categoria);
                    break;
                  case 'delete':
                    _deleteCategoria(categoria);
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
                PopupMenuItem(
                  value: 'toggle',
                  child: ListTile(
                    leading: Icon(categoria.activo ? Icons.block : Icons.check_circle),
                    title: Text(categoria.activo ? 'Desactivar' : 'Activar'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: AppTheme.errorColor),
                    title: Text('Eliminar', style: TextStyle(color: AppTheme.errorColor)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
