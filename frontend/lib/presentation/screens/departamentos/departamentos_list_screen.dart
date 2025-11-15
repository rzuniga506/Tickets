import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/departamentos/departamento_cubit.dart';
import '../../../logic/departamentos/departamento_state.dart';
import '../../../data/models/departamento/departamento_model.dart';
import '../../../config/theme.dart';
import '../../../core/di/injection.dart';
import '../../widgets/loading_card.dart';
import '../../widgets/empty_state.dart';
import 'departamento_form_screen.dart';

class DepartamentosListScreen extends StatefulWidget {
  const DepartamentosListScreen({super.key});

  @override
  State<DepartamentosListScreen> createState() => _DepartamentosListScreenState();
}

class _DepartamentosListScreenState extends State<DepartamentosListScreen> {
  final _searchController = TextEditingController();
  List<DepartamentoModel> _departamentos = [];
  List<DepartamentoModel> _filteredDepartamentos = [];
  bool _showOnlyActive = false;

  @override
  void initState() {
    super.initState();
    _loadDepartamentos();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadDepartamentos() {
    if (_showOnlyActive) {
      context.read<DepartamentoCubit>().getDepartamentosActivos();
    } else {
      context.read<DepartamentoCubit>().getDepartamentos();
    }
  }

  void _filterDepartamentos(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredDepartamentos = _departamentos;
      } else {
        _filteredDepartamentos = _departamentos.where((depto) {
          final nombreLower = depto.nombre.toLowerCase();
          final codigoLower = depto.codigo?.toLowerCase() ?? '';
          final searchLower = query.toLowerCase();
          return nombreLower.contains(searchLower) || codigoLower.contains(searchLower);
        }).toList();
      }
    });
  }

  Future<void> _onRefresh() async {
    _loadDepartamentos();
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Filtrar Departamentos'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: const Text('Solo activos'),
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
              _loadDepartamentos();
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  void _toggleActivo(DepartamentoModel departamento) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(departamento.activo ? 'Desactivar Departamento' : 'Activar Departamento'),
        content: Text(departamento.activo
            ? '¿Está seguro que desea desactivar "${departamento.nombre}"?'
            : '¿Está seguro que desea activar "${departamento.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<DepartamentoCubit>().toggleActivo(departamento.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: departamento.activo ? AppTheme.warningColor : AppTheme.successColor,
            ),
            child: Text(departamento.activo ? 'Desactivar' : 'Activar'),
          ),
        ],
      ),
    );
  }

  void _deleteDepartamento(DepartamentoModel departamento) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Departamento'),
        content: Text(
            '¿Está seguro que desea eliminar "${departamento.nombre}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<DepartamentoCubit>().deleteDepartamento(departamento.id);
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
        title: const Text('Departamentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: BlocConsumer<DepartamentoCubit, DepartamentoState>(
        listener: (context, state) {
          if (state is DepartamentoCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Departamento creado exitosamente'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            _loadDepartamentos();
          } else if (state is DepartamentoUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Departamento actualizado exitosamente'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            _loadDepartamentos();
          } else if (state is DepartamentoDeleted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Departamento eliminado exitosamente'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            _loadDepartamentos();
          } else if (state is DepartamentoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is DepartamentoLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DepartamentosLoaded) {
            _departamentos = state.departamentos;
            if (_filteredDepartamentos.isEmpty && _searchController.text.isEmpty) {
              _filteredDepartamentos = _departamentos;
            }
          }

          final displayList = _filteredDepartamentos;

          return Column(
            children: [
              // Barra de búsqueda
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o código...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _filterDepartamentos('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: _filterDepartamentos,
                ),
              ),

              // Lista de departamentos
              Expanded(
                child: displayList.isEmpty
                    ? const EmptyState(
                        icon: Icons.business,
                        message: 'No se encontraron departamentos',
                      )
                    : RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: displayList.length,
                          itemBuilder: (context, index) {
                            final departamento = displayList[index];
                            return _buildDepartamentoCard(departamento);
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
                value: context.read<DepartamentoCubit>(),
                child: const DepartamentoFormScreen(),
              ),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
    );
  }

  Widget _buildDepartamentoCard(DepartamentoModel departamento) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: departamento.activo ? AppTheme.primaryColor : AppTheme.greyDark,
          child: Icon(
            Icons.business,
            color: Colors.white,
          ),
        ),
        title: Text(
          departamento.nombre,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (departamento.codigo != null)
              Text('Código: ${departamento.codigo}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.people, size: 16, color: AppTheme.greyDark),
                const SizedBox(width: 4),
                Text('${departamento.cantidadUsuarios} usuarios'),
                const SizedBox(width: 16),
                Icon(Icons.devices, size: 16, color: AppTheme.greyDark),
                const SizedBox(width: 4),
                Text('${departamento.cantidadEquipos} equipos'),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider.value(
                      value: context.read<DepartamentoCubit>(),
                      child: DepartamentoFormScreen(departamento: departamento),
                    ),
                  ),
                );
                break;
              case 'toggle':
                _toggleActivo(departamento);
                break;
              case 'delete':
                _deleteDepartamento(departamento);
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
                leading: Icon(departamento.activo ? Icons.block : Icons.check_circle),
                title: Text(departamento.activo ? 'Desactivar' : 'Activar'),
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
      ),
    );
  }
}
