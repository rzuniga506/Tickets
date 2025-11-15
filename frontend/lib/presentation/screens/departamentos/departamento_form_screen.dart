import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/departamentos/departamento_cubit.dart';
import '../../../logic/departamentos/departamento_state.dart';
import '../../../data/models/departamento/departamento_model.dart';
import '../../../config/theme.dart';

class DepartamentoFormScreen extends StatefulWidget {
  final DepartamentoModel? departamento;

  const DepartamentoFormScreen({
    super.key,
    this.departamento,
  });

  @override
  State<DepartamentoFormScreen> createState() => _DepartamentoFormScreenState();
}

class _DepartamentoFormScreenState extends State<DepartamentoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _codigoController;
  late final TextEditingController _descripcionController;
  bool _isLoading = false;

  bool get _isEditing => widget.departamento != null;

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.departamento?.nombre ?? '',
    );
    _codigoController = TextEditingController(
      text: widget.departamento?.codigo ?? '',
    );
    _descripcionController = TextEditingController(
      text: widget.departamento?.descripcion ?? '',
    );
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _codigoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isEditing) {
      final dto = UpdateDepartamentoDto(
        nombre: _nombreController.text.trim(),
        codigo: _codigoController.text.trim().isEmpty
            ? null
            : _codigoController.text.trim(),
        descripcion: _descripcionController.text.trim().isEmpty
            ? null
            : _descripcionController.text.trim(),
      );
      context.read<DepartamentoCubit>().updateDepartamento(
            widget.departamento!.id,
            dto,
          );
    } else {
      final dto = CreateDepartamentoDto(
        nombre: _nombreController.text.trim(),
        codigo: _codigoController.text.trim().isEmpty
            ? null
            : _codigoController.text.trim(),
        descripcion: _descripcionController.text.trim().isEmpty
            ? null
            : _descripcionController.text.trim(),
      );
      context.read<DepartamentoCubit>().createDepartamento(dto);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Departamento' : 'Nuevo Departamento'),
      ),
      body: BlocConsumer<DepartamentoCubit, DepartamentoState>(
        listener: (context, state) {
          if (state is DepartamentoLoading) {
            setState(() {
              _isLoading = true;
            });
          } else {
            setState(() {
              _isLoading = false;
            });
          }

          if (state is DepartamentoCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Departamento creado exitosamente'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            Navigator.of(context).pop(true);
          } else if (state is DepartamentoUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Departamento actualizado exitosamente'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            Navigator.of(context).pop(true);
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
                      hintText: 'Ej: Soporte Técnico',
                      prefixIcon: Icon(Icons.business),
                      border: OutlineInputBorder(),
                    ),
                    enabled: !_isLoading,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El nombre es requerido';
                      }
                      if (value.trim().length > 100) {
                        return 'El nombre no puede exceder 100 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Código
                  TextFormField(
                    controller: _codigoController,
                    decoration: const InputDecoration(
                      labelText: 'Código',
                      hintText: 'Ej: ST',
                      prefixIcon: Icon(Icons.tag),
                      border: OutlineInputBorder(),
                    ),
                    enabled: !_isLoading,
                    validator: (value) {
                      if (value != null && value.trim().isNotEmpty) {
                        if (value.trim().length > 20) {
                          return 'El código no puede exceder 20 caracteres';
                        }
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
                      hintText: 'Descripción del departamento',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    enabled: !_isLoading,
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
