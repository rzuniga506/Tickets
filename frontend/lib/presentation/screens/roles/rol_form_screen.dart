import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/roles/rol_cubit.dart';
import '../../../logic/roles/rol_state.dart';
import '../../../logic/permisos/permiso_cubit.dart';
import '../../../logic/permisos/permiso_state.dart';
import '../../../data/models/rol/rol_model.dart';
import '../../../data/models/permiso/permiso_model.dart';
import '../../../config/theme.dart';
import '../../../core/di/injection.dart';

class RolFormScreen extends StatefulWidget {
  final RolModel? rol;

  const RolFormScreen({
    super.key,
    this.rol,
  });

  @override
  State<RolFormScreen> createState() => _RolFormScreenState();
}

class _RolFormScreenState extends State<RolFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _descripcionController;
  late final PermisoCubit _permisoCubit;

  List<PermisoModel> _permisos = [];
  Set<int> _selectedPermisosIds = {};
  bool _isLoading = false;

  bool get _isEditing => widget.rol != null;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.rol?.nombre ?? '',
    );
    _descripcionController = TextEditingController(
      text: widget.rol?.descripcion ?? '',
    );

    if (widget.rol != null) {
      _selectedPermisosIds = Set.from(widget.rol!.permisosIds);
    }

    _permisoCubit = getIt<PermisoCubit>();
    _permisoCubit.getPermisos();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _permisoCubit.close();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPermisosIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar al menos un permiso'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    if (_isEditing) {
      final dto = UpdateRolDto(
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim().isEmpty
            ? null
            : _descripcionController.text.trim(),
        permisosIds: _selectedPermisosIds.toList(),
      );
      context.read<RolCubit>().updateRol(widget.rol!.id, dto);
    } else {
      final dto = CreateRolDto(
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim().isEmpty
            ? null
            : _descripcionController.text.trim(),
        permisosIds: _selectedPermisosIds.toList(),
      );
      context.read<RolCubit>().createRol(dto);
    }
  }

  Map<String, List<PermisoModel>> _groupPermisosByModulo() {
    final Map<String, List<PermisoModel>> grouped = {};
    for (var permiso in _permisos) {
      if (!grouped.containsKey(permiso.modulo)) {
        grouped[permiso.modulo] = [];
      }
      grouped[permiso.modulo]!.add(permiso);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Rol' : 'Nuevo Rol'),
      ),
      body: BlocConsumer<RolCubit, RolState>(
        listener: (context, state) {
          if (state is RolLoading) {
            setState(() {
              _isLoading = true;
            });
          } else {
            setState(() {
              _isLoading = false;
            });
          }

          if (state is RolCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Rol creado exitosamente'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            Navigator.of(context).pop(true);
          } else if (state is RolUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Rol actualizado exitosamente'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            Navigator.of(context).pop(true);
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Nombre
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre *',
                      hintText: 'Ej: Supervisor',
                      prefixIcon: Icon(Icons.admin_panel_settings),
                      border: OutlineInputBorder(),
                    ),
                    enabled: !_isLoading,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es requerido';
                      }
                      if (value.trim().length > 50) {
                        return 'El nombre no puede exceder 50 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Descripción
                  TextFormField(
                    controller: _descripcionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      hintText: 'Descripción del rol',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    enabled: !_isLoading,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        if (value.trim().length > 200) {
                          return 'La descripción no puede exceder 200 caracteres';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Permisos section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Permisos *',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        '${_selectedPermisosIds.length} seleccionados',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Permisos list
                  BlocBuilder<PermisoCubit, PermisoState>(
                    bloc: _permisoCubit,
                    builder: (context, permisoState) {
                      if (permisoState is PermisoLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      if (permisoState is PermisosLoaded) {
                        _permisos = permisoState.permisos;
                        final groupedPermisos = _groupPermisosByModulo();

                        return Column(
                          children: groupedPermisos.entries.map((entry) {
                            final modulo = entry.key;
                            final permisos = entry.value;
                            final moduloPermisosIds = permisos.map((p) => p.id).toSet();
                            final allSelected = moduloPermisosIds.every(
                              (id) => _selectedPermisosIds.contains(id),
                            );

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ExpansionTile(
                                title: Text(
                                  modulo,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${permisos.where((p) => _selectedPermisosIds.contains(p.id)).length}/${permisos.length} seleccionados',
                                ),
                                leading: Checkbox(
                                  value: allSelected,
                                  onChanged: _isLoading
                                      ? null
                                      : (value) {
                                          setState(() {
                                            if (value == true) {
                                              _selectedPermisosIds.addAll(moduloPermisosIds);
                                            } else {
                                              _selectedPermisosIds.removeAll(moduloPermisosIds);
                                            }
                                          });
                                        },
                                ),
                                children: permisos.map((permiso) {
                                  final isSelected = _selectedPermisosIds.contains(permiso.id);

                                  return CheckboxListTile(
                                    title: Text(permiso.nombre),
                                    subtitle: permiso.descripcion != null
                                        ? Text(
                                            permiso.descripcion!,
                                            style: Theme.of(context).textTheme.bodySmall,
                                          )
                                        : null,
                                    value: isSelected,
                                    enabled: !_isLoading,
                                    onChanged: (value) {
                                      setState(() {
                                        if (value == true) {
                                          _selectedPermisosIds.add(permiso.id);
                                        } else {
                                          _selectedPermisosIds.remove(permiso.id);
                                        }
                                      });
                                    },
                                  );
                                }).toList(),
                              ),
                            );
                          }).toList(),
                        );
                      }

                      if (permisoState is PermisoError) {
                        return Center(
                          child: Column(
                            children: [
                              const Icon(Icons.error_outline, size: 48, color: AppTheme.errorColor),
                              const SizedBox(height: 16),
                              Text(permisoState.message),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => _permisoCubit.getPermisos(),
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),

                  const SizedBox(height: 32),

                  // Botones
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleSubmit,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Text(_isEditing ? 'Actualizar' : 'Crear'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
