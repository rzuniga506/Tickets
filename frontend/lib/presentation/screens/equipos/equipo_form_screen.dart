import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../logic/equipos/equipo_cubit.dart';
import '../../../logic/equipos/equipo_state.dart';
import '../../../data/models/equipo_model.dart';
import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../widgets/tipo_equipo_badge.dart';
import '../../widgets/condition_badge.dart';

class EquipoFormScreen extends StatefulWidget {
  final EquipoModel? equipo; // Para edición (opcional)

  const EquipoFormScreen({
    super.key,
    this.equipo,
  });

  @override
  State<EquipoFormScreen> createState() => _EquipoFormScreenState();
}

class _EquipoFormScreenState extends State<EquipoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _numeroSerieController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _procesadorController = TextEditingController();
  final _ramController = TextEditingController();
  final _almacenamientoController = TextEditingController();
  final _sistemaOperativoController = TextEditingController();
  final _valorAdquisicionController = TextEditingController();
  final _proveedorController = TextEditingController();
  final _garantiaMesesController = TextEditingController();
  final _notasController = TextEditingController();

  TipoEquipo _tipo = TipoEquipo.computadora;
  EstadoEquipo _estado = EstadoEquipo.disponible;
  CondicionEquipo _condicion = CondicionEquipo.bueno;
  DateTime _fechaAdquisicion = DateTime.now();

  bool get _isEditing => widget.equipo != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _initializeFromEquipo(widget.equipo!);
    }
  }

  void _initializeFromEquipo(EquipoModel equipo) {
    _marcaController.text = equipo.marca;
    _modeloController.text = equipo.modelo;
    _numeroSerieController.text = equipo.numeroSerie ?? '';
    _ubicacionController.text = equipo.ubicacion;
    _procesadorController.text = equipo.procesador ?? '';
    _ramController.text = equipo.ram ?? '';
    _almacenamientoController.text = equipo.almacenamiento ?? '';
    _sistemaOperativoController.text = equipo.sistemaOperativo ?? '';
    _valorAdquisicionController.text =
        equipo.valorAdquisicion?.toString() ?? '';
    _proveedorController.text = equipo.proveedor ?? '';
    _garantiaMesesController.text = equipo.garantiaMeses?.toString() ?? '';
    _notasController.text = equipo.notas ?? '';

    _tipo = equipo.tipo;
    _estado = equipo.estado;
    _condicion = equipo.condicion;
    _fechaAdquisicion = equipo.fechaAdquisicion;
  }

  @override
  void dispose() {
    _marcaController.dispose();
    _modeloController.dispose();
    _numeroSerieController.dispose();
    _ubicacionController.dispose();
    _procesadorController.dispose();
    _ramController.dispose();
    _almacenamientoController.dispose();
    _sistemaOperativoController.dispose();
    _valorAdquisicionController.dispose();
    _proveedorController.dispose();
    _garantiaMesesController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_isEditing) {
        // Actualizar equipo existente
        context.read<EquipoCubit>().updateEquipo(
              widget.equipo!.id,
              UpdateEquipoRequest(
                marca: _marcaController.text.trim(),
                modelo: _modeloController.text.trim(),
                numeroSerie: _numeroSerieController.text.trim().isNotEmpty
                    ? _numeroSerieController.text.trim()
                    : null,
                tipo: _tipo,
                estado: _estado,
                condicion: _condicion,
                ubicacion: _ubicacionController.text.trim(),
                fechaAdquisicion: _fechaAdquisicion,
                valorAdquisicion:
                    _valorAdquisicionController.text.trim().isNotEmpty
                        ? double.tryParse(_valorAdquisicionController.text)
                        : null,
                proveedor: _proveedorController.text.trim().isNotEmpty
                    ? _proveedorController.text.trim()
                    : null,
                garantiaMeses: _garantiaMesesController.text.trim().isNotEmpty
                    ? int.tryParse(_garantiaMesesController.text)
                    : null,
                procesador: _procesadorController.text.trim().isNotEmpty
                    ? _procesadorController.text.trim()
                    : null,
                ram: _ramController.text.trim().isNotEmpty
                    ? _ramController.text.trim()
                    : null,
                almacenamiento: _almacenamientoController.text.trim().isNotEmpty
                    ? _almacenamientoController.text.trim()
                    : null,
                sistemaOperativo:
                    _sistemaOperativoController.text.trim().isNotEmpty
                        ? _sistemaOperativoController.text.trim()
                        : null,
                notas: _notasController.text.trim().isNotEmpty
                    ? _notasController.text.trim()
                    : null,
              ),
            );
      } else {
        // Crear nuevo equipo
        context.read<EquipoCubit>().createEquipo(
              CreateEquipoRequest(
                marca: _marcaController.text.trim(),
                modelo: _modeloController.text.trim(),
                numeroSerie: _numeroSerieController.text.trim().isNotEmpty
                    ? _numeroSerieController.text.trim()
                    : null,
                tipo: _tipo,
                estado: _estado,
                condicion: _condicion,
                ubicacion: _ubicacionController.text.trim(),
                fechaAdquisicion: _fechaAdquisicion,
                valorAdquisicion:
                    _valorAdquisicionController.text.trim().isNotEmpty
                        ? double.tryParse(_valorAdquisicionController.text)
                        : null,
                proveedor: _proveedorController.text.trim().isNotEmpty
                    ? _proveedorController.text.trim()
                    : null,
                garantiaMeses: _garantiaMesesController.text.trim().isNotEmpty
                    ? int.tryParse(_garantiaMesesController.text)
                    : null,
                procesador: _procesadorController.text.trim().isNotEmpty
                    ? _procesadorController.text.trim()
                    : null,
                ram: _ramController.text.trim().isNotEmpty
                    ? _ramController.text.trim()
                    : null,
                almacenamiento: _almacenamientoController.text.trim().isNotEmpty
                    ? _almacenamientoController.text.trim()
                    : null,
                sistemaOperativo:
                    _sistemaOperativoController.text.trim().isNotEmpty
                        ? _sistemaOperativoController.text.trim()
                        : null,
                notas: _notasController.text.trim().isNotEmpty
                    ? _notasController.text.trim()
                    : null,
              ),
            );
      }
    }
  }

  Future<void> _selectFechaAdquisicion() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaAdquisicion,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null) {
      setState(() {
        _fechaAdquisicion = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Equipo' : 'Nuevo Equipo'),
      ),
      body: BlocConsumer<EquipoCubit, EquipoState>(
        listener: (context, state) {
          if (state is EquipoCreated || state is EquipoUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isEditing
                      ? 'Equipo actualizado correctamente'
                      : 'Equipo creado correctamente',
                ),
                backgroundColor: AppTheme.successColor,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is EquipoError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is EquipoActionLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Información básica
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: AppTheme.primaryColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Información Básica',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Marca *
                  TextFormField(
                    controller: _marcaController,
                    decoration: const InputDecoration(
                      labelText: 'Marca *',
                      hintText: 'Ej: Dell, HP, Lenovo',
                      prefixIcon: Icon(Icons.branding_watermark),
                      border: OutlineInputBorder(),
                    ),
                    enabled: !isLoading,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La marca es requerida';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Modelo *
                  TextFormField(
                    controller: _modeloController,
                    decoration: const InputDecoration(
                      labelText: 'Modelo *',
                      hintText: 'Ej: OptiPlex 7090, ThinkPad T14',
                      prefixIcon: Icon(Icons.computer),
                      border: OutlineInputBorder(),
                    ),
                    enabled: !isLoading,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El modelo es requerido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Número de Serie
                  TextFormField(
                    controller: _numeroSerieController,
                    decoration: const InputDecoration(
                      labelText: 'Número de Serie',
                      hintText: 'Ej: ABC123XYZ',
                      prefixIcon: Icon(Icons.tag),
                      border: OutlineInputBorder(),
                    ),
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 24),

                  // Tipo de Equipo *
                  Text(
                    'Tipo de Equipo *',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: TipoEquipo.values.map((tipo) {
                      final isSelected = _tipo == tipo;
                      return ChoiceChip(
                        label: Text(tipo.displayName),
                        selected: isSelected,
                        onSelected: isLoading
                            ? null
                            : (selected) {
                                if (selected) {
                                  setState(() {
                                    _tipo = tipo;
                                  });
                                }
                              },
                        avatar: isSelected
                            ? const Icon(Icons.check, size: 18)
                            : null,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Estado *
                  Text(
                    'Estado *',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: EstadoEquipo.values.map((estado) {
                      final isSelected = _estado == estado;
                      return ChoiceChip(
                        label: Text(estado.displayName),
                        selected: isSelected,
                        onSelected: isLoading
                            ? null
                            : (selected) {
                                if (selected) {
                                  setState(() {
                                    _estado = estado;
                                  });
                                }
                              },
                        avatar: isSelected
                            ? const Icon(Icons.check, size: 18)
                            : null,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Condición *
                  Text(
                    'Condición *',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: CondicionEquipo.values.map((condicion) {
                      final isSelected = _condicion == condicion;
                      return ChoiceChip(
                        label: Text(condicion.displayName),
                        selected: isSelected,
                        onSelected: isLoading
                            ? null
                            : (selected) {
                                if (selected) {
                                  setState(() {
                                    _condicion = condicion;
                                  });
                                }
                              },
                        avatar: isSelected
                            ? const Icon(Icons.check, size: 18)
                            : null,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Ubicación *
                  TextFormField(
                    controller: _ubicacionController,
                    decoration: const InputDecoration(
                      labelText: 'Ubicación *',
                      hintText: 'Ej: Oficina 301, Almacén TI',
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                    enabled: !isLoading,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La ubicación es requerida';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Fecha de Adquisición *
                  InkWell(
                    onTap: isLoading ? null : _selectFechaAdquisicion,
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fecha de Adquisición *',
                        prefixIcon: Icon(Icons.event),
                        border: OutlineInputBorder(),
                      ),
                      child: Text(
                        DateFormat('dd/MM/yyyy').format(_fechaAdquisicion),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Información Técnica (Opcional)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.memory,
                                color: AppTheme.infoColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Especificaciones Técnicas (Opcional)',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Procesador
                  TextFormField(
                    controller: _procesadorController,
                    decoration: const InputDecoration(
                      labelText: 'Procesador',
                      hintText: 'Ej: Intel Core i7-11700',
                      prefixIcon: Icon(Icons.memory),
                      border: OutlineInputBorder(),
                    ),
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),

                  // RAM
                  TextFormField(
                    controller: _ramController,
                    decoration: const InputDecoration(
                      labelText: 'RAM',
                      hintText: 'Ej: 16GB DDR4',
                      prefixIcon: Icon(Icons.storage),
                      border: OutlineInputBorder(),
                    ),
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Almacenamiento
                  TextFormField(
                    controller: _almacenamientoController,
                    decoration: const InputDecoration(
                      labelText: 'Almacenamiento',
                      hintText: 'Ej: 512GB SSD',
                      prefixIcon: Icon(Icons.sd_storage),
                      border: OutlineInputBorder(),
                    ),
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Sistema Operativo
                  TextFormField(
                    controller: _sistemaOperativoController,
                    decoration: const InputDecoration(
                      labelText: 'Sistema Operativo',
                      hintText: 'Ej: Windows 11 Pro',
                      prefixIcon: Icon(Icons.computer),
                      border: OutlineInputBorder(),
                    ),
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 24),

                  // Información Comercial (Opcional)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.business,
                                color: AppTheme.successColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Información Comercial (Opcional)',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Valor de Adquisición
                  TextFormField(
                    controller: _valorAdquisicionController,
                    decoration: const InputDecoration(
                      labelText: 'Valor de Adquisición',
                      hintText: 'Ej: 1500.00',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                    ],
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Proveedor
                  TextFormField(
                    controller: _proveedorController,
                    decoration: const InputDecoration(
                      labelText: 'Proveedor',
                      hintText: 'Ej: TechStore S.A.',
                      prefixIcon: Icon(Icons.business),
                      border: OutlineInputBorder(),
                    ),
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Garantía (meses)
                  TextFormField(
                    controller: _garantiaMesesController,
                    decoration: const InputDecoration(
                      labelText: 'Garantía (meses)',
                      hintText: 'Ej: 12, 24, 36',
                      prefixIcon: Icon(Icons.verified_user),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),

                  // Notas
                  TextFormField(
                    controller: _notasController,
                    decoration: const InputDecoration(
                      labelText: 'Notas',
                      hintText: 'Información adicional...',
                      prefixIcon: Icon(Icons.notes),
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    maxLines: 4,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 32),

                  // Botones
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: isLoading
                              ? null
                              : () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleSubmit,
                          child: isLoading
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
