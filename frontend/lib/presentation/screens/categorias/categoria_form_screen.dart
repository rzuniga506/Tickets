import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/categorias/categoria_cubit.dart';
import '../../../logic/categorias/categoria_state.dart';
import '../../../data/models/categoria/categoria_ticket_model.dart';
import '../../../config/theme.dart';

class CategoriaFormScreen extends StatefulWidget {
  final CategoriaTicketModel? categoria;

  const CategoriaFormScreen({
    super.key,
    this.categoria,
  });

  @override
  State<CategoriaFormScreen> createState() => _CategoriaFormScreenState();
}

class _CategoriaFormScreenState extends State<CategoriaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nombreController;
  late final TextEditingController _descripcionController;
  late String _selectedColor;
  String? _selectedIcon;
  bool _isLoading = false;

  bool get _isEditing => widget.categoria != null;

  final Map<String, Color> _colorOptions = {
    '#EF4444': const Color(0xFFEF4444), // Red
    '#F59E0B': const Color(0xFFF59E0B), // Amber
    '#10B981': const Color(0xFF10B981), // Green
    '#3B82F6': const Color(0xFF3B82F6), // Blue
    '#8B5CF6': const Color(0xFF8B5CF6), // Purple
    '#EC4899': const Color(0xFFEC4899), // Pink
    '#6B7280': const Color(0xFF6B7280), // Gray
    '#14B8A6': const Color(0xFF14B8A6), // Teal
  };

  final Map<String, IconData> _iconOptions = {
    'computer': Icons.computer,
    'bug_report': Icons.bug_report,
    'wifi': Icons.wifi,
    'security': Icons.security,
    'vpn_key': Icons.vpn_key,
    'settings': Icons.settings,
    'help_outline': Icons.help_outline,
    'category': Icons.category,
  };

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(
      text: widget.categoria?.nombre ?? '',
    );
    _descripcionController = TextEditingController(
      text: widget.categoria?.descripcion ?? '',
    );
    _selectedColor = widget.categoria?.color ?? '#6B7280';
    _selectedIcon = widget.categoria?.icono;
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_isEditing) {
      final dto = UpdateCategoriaTicketDto(
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim().isEmpty
            ? null
            : _descripcionController.text.trim(),
        color: _selectedColor,
        icono: _selectedIcon,
      );
      context.read<CategoriaCubit>().updateCategoria(
            widget.categoria!.id,
            dto,
          );
    } else {
      final dto = CreateCategoriaTicketDto(
        nombre: _nombreController.text.trim(),
        descripcion: _descripcionController.text.trim().isEmpty
            ? null
            : _descripcionController.text.trim(),
        color: _selectedColor,
        icono: _selectedIcon,
      );
      context.read<CategoriaCubit>().createCategoria(dto);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Categoría' : 'Nueva Categoría'),
      ),
      body: BlocConsumer<CategoriaCubit, CategoriaState>(
        listener: (context, state) {
          if (state is CategoriaLoading) {
            setState(() {
              _isLoading = true;
            });
          } else {
            setState(() {
              _isLoading = false;
            });
          }

          if (state is CategoriaCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Categoría creada exitosamente'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            Navigator.of(context).pop(true);
          } else if (state is CategoriaUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Categoría actualizada exitosamente'),
                backgroundColor: AppTheme.successColor,
              ),
            );
            Navigator.of(context).pop(true);
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
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Vista previa
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: _colorOptions[_selectedColor] ?? AppTheme.greyDark,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        _iconOptions[_selectedIcon] ?? Icons.category,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Nombre
                  TextFormField(
                    controller: _nombreController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre *',
                      hintText: 'Ej: Hardware',
                      prefixIcon: Icon(Icons.label),
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
                      hintText: 'Descripción de la categoría',
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

                  // Selector de color
                  Text(
                    'Color',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _colorOptions.entries.map((entry) {
                      final hexColor = entry.key;
                      final color = entry.value;
                      final isSelected = _selectedColor == hexColor;

                      return InkWell(
                        onTap: _isLoading
                            ? null
                            : () {
                                setState(() {
                                  _selectedColor = hexColor;
                                });
                              },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? Border.all(color: Colors.black, width: 3)
                                : null,
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: color.withOpacity(0.5),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    )
                                  ]
                                : null,
                          ),
                          child: isSelected
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Selector de icono
                  Text(
                    'Icono (opcional)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _iconOptions.entries.map((entry) {
                      final iconKey = entry.key;
                      final iconData = entry.value;
                      final isSelected = _selectedIcon == iconKey;

                      return InkWell(
                        onTap: _isLoading
                            ? null
                            : () {
                                setState(() {
                                  _selectedIcon = iconKey;
                                });
                              },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _colorOptions[_selectedColor]
                                : AppTheme.greyLight,
                            borderRadius: BorderRadius.circular(8),
                            border: isSelected
                                ? Border.all(
                                    color: _colorOptions[_selectedColor] ?? AppTheme.primaryColor,
                                    width: 2)
                                : null,
                          ),
                          child: Icon(
                            iconData,
                            color: isSelected ? Colors.white : AppTheme.greyDark,
                          ),
                        ),
                      );
                    }).toList(),
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
