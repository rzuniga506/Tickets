import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../logic/equipos/equipo_cubit.dart';
import '../../../logic/equipos/equipo_state.dart';
import '../../../data/models/equipo/equipo_model.dart';
import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../../core/utils/responsive.dart';

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

  // Campos requeridos
  final _codigoInternoController = TextEditingController();
  final _nombreController = TextEditingController();

  // Campos opcionales
  final _numeroSerieController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _modeloController = TextEditingController();
  final _costoAdquisicionController = TextEditingController();
  final _vidaUtilMesesController = TextEditingController();
  final _valorResidualController = TextEditingController();
  final _observacionesController = TextEditingController();

  EstadoEquipo _estado = EstadoEquipo.disponible;
  CondicionEquipo _condicion = CondicionEquipo.nuevo;
  DateTime? _fechaAdquisicion;
  DateTime? _fechaInicioGarantia;
  DateTime? _fechaFinGarantia;

  bool get _isEditing => widget.equipo != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _initializeFromEquipo(widget.equipo!);
    }
  }

  void _initializeFromEquipo(EquipoModel equipo) {
    _codigoInternoController.text = equipo.codigoInterno;
    _nombreController.text = equipo.nombre;
    _numeroSerieController.text = equipo.numeroSerie ?? '';
    _descripcionController.text = equipo.descripcion ?? '';
    _modeloController.text = equipo.modelo ?? '';
    _costoAdquisicionController.text = equipo.costoAdquisicion?.toString() ?? '';
    _vidaUtilMesesController.text = equipo.vidaUtilMeses.toString();
    _valorResidualController.text = equipo.valorResidual?.toString() ?? '';
    _observacionesController.text = equipo.observaciones ?? '';

    _estado = equipo.estado;
    _condicion = equipo.condicion;
    _fechaAdquisicion = equipo.fechaAdquisicion;
    _fechaInicioGarantia = equipo.fechaInicioGarantia;
    _fechaFinGarantia = equipo.fechaFinGarantia;
  }

  @override
  void dispose() {
    _codigoInternoController.dispose();
    _nombreController.dispose();
    _numeroSerieController.dispose();
    _descripcionController.dispose();
    _modeloController.dispose();
    _costoAdquisicionController.dispose();
    _vidaUtilMesesController.dispose();
    _valorResidualController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      final costoAdquisicion = _costoAdquisicionController.text.trim().isNotEmpty
          ? double.tryParse(_costoAdquisicionController.text)
          : null;

      final vidaUtilMeses = _vidaUtilMesesController.text.trim().isNotEmpty
          ? int.tryParse(_vidaUtilMesesController.text) ?? 36
          : 36;

      final valorResidual = _valorResidualController.text.trim().isNotEmpty
          ? double.tryParse(_valorResidualController.text)
          : null;

      if (_isEditing) {
        // Actualizar equipo existente
        context.read<EquipoCubit>().updateEquipo(
              id: widget.equipo!.id,
              nombre: _nombreController.text.trim(),
              estado: _estado,
              condicion: _condicion,
              numeroSerie: _numeroSerieController.text.trim().isNotEmpty
                  ? _numeroSerieController.text.trim()
                  : null,
              descripcion: _descripcionController.text.trim().isNotEmpty
                  ? _descripcionController.text.trim()
                  : null,
              modelo: _modeloController.text.trim().isNotEmpty
                  ? _modeloController.text.trim()
                  : null,
              costoAdquisicion: costoAdquisicion,
              fechaAdquisicion: _fechaAdquisicion,
              vidaUtilMeses: vidaUtilMeses,
              valorResidual: valorResidual,
              fechaInicioGarantia: _fechaInicioGarantia,
              fechaFinGarantia: _fechaFinGarantia,
              observaciones: _observacionesController.text.trim().isNotEmpty
                  ? _observacionesController.text.trim()
                  : null,
            );
      } else {
        // Crear nuevo equipo
        context.read<EquipoCubit>().createEquipo(
              codigoInterno: _codigoInternoController.text.trim(),
              nombre: _nombreController.text.trim(),
              estado: _estado,
              condicion: _condicion,
              numeroSerie: _numeroSerieController.text.trim().isNotEmpty
                  ? _numeroSerieController.text.trim()
                  : null,
              descripcion: _descripcionController.text.trim().isNotEmpty
                  ? _descripcionController.text.trim()
                  : null,
              modelo: _modeloController.text.trim().isNotEmpty
                  ? _modeloController.text.trim()
                  : null,
              costoAdquisicion: costoAdquisicion,
              fechaAdquisicion: _fechaAdquisicion,
              vidaUtilMeses: vidaUtilMeses,
              valorResidual: valorResidual,
              fechaInicioGarantia: _fechaInicioGarantia,
              fechaFinGarantia: _fechaFinGarantia,
              observaciones: _observacionesController.text.trim().isNotEmpty
                  ? _observacionesController.text.trim()
                  : null,
            );
      }
    }
  }

  Future<void> _selectDate(BuildContext context, DateTime? initialDate,
      Function(DateTime) onDateSelected) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'),
    );

    if (picked != null) {
      setState(() {
        onDateSelected(picked);
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
            padding: EdgeInsets.all(Breakpoints.getHorizontalPadding(context)),
            child: CenteredContent(
              maxWidth: 600,
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
                          Text(
                            'Información Básica',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),

                          // Código Interno (REQUERIDO)
                          TextFormField(
                            controller: _codigoInternoController,
                            decoration: const InputDecoration(
                              labelText: 'Código Interno *',
                              hintText: 'Ej: EQ-001',
                              prefixIcon: Icon(Icons.qr_code),
                              border: OutlineInputBorder(),
                            ),
                            enabled: !_isEditing, // No se puede cambiar al editar
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El código interno es requerido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Nombre (REQUERIDO)
                          TextFormField(
                            controller: _nombreController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre *',
                              hintText: 'Ej: Laptop Dell Latitude 5420',
                              prefixIcon: Icon(Icons.devices),
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'El nombre es requerido';
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
                              hintText: 'Ej: ABC123456789',
                              prefixIcon: Icon(Icons.tag),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Modelo
                          TextFormField(
                            controller: _modeloController,
                            decoration: const InputDecoration(
                              labelText: 'Modelo',
                              hintText: 'Ej: Latitude 5420',
                              prefixIcon: Icon(Icons.info_outline),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Descripción
                          TextFormField(
                            controller: _descripcionController,
                            decoration: const InputDecoration(
                              labelText: 'Descripción',
                              hintText: 'Descripción del equipo',
                              prefixIcon: Icon(Icons.description),
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Estado y Condición
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Estado y Condición',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),

                          // Estado
                          DropdownButtonFormField<EstadoEquipo>(
                            value: _estado,
                            decoration: const InputDecoration(
                              labelText: 'Estado *',
                              prefixIcon: Icon(Icons.signal_cellular_alt),
                              border: OutlineInputBorder(),
                            ),
                            items: EstadoEquipo.values.map((estado) {
                              return DropdownMenuItem(
                                value: estado,
                                child: Text(estado.displayName),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _estado = value;
                                });
                              }
                            },
                          ),
                          const SizedBox(height: 16),

                          // Condición
                          DropdownButtonFormField<CondicionEquipo>(
                            value: _condicion,
                            decoration: const InputDecoration(
                              labelText: 'Condición *',
                              prefixIcon: Icon(Icons.star_outline),
                              border: OutlineInputBorder(),
                            ),
                            items: CondicionEquipo.values.map((condicion) {
                              return DropdownMenuItem(
                                value: condicion,
                                child: Text(condicion.displayName),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _condicion = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Información Financiera
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información Financiera',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),

                          // Costo de Adquisición
                          TextFormField(
                            controller: _costoAdquisicionController,
                            decoration: const InputDecoration(
                              labelText: 'Costo de Adquisición',
                              hintText: '0.00',
                              prefixIcon: Icon(Icons.attach_money),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Fecha de Adquisición
                          InkWell(
                            onTap: () => _selectDate(
                              context,
                              _fechaAdquisicion,
                              (date) => _fechaAdquisicion = date,
                            ),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Fecha de Adquisición',
                                prefixIcon: Icon(Icons.calendar_today),
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                _fechaAdquisicion != null
                                    ? DateFormat('dd/MM/yyyy')
                                        .format(_fechaAdquisicion!)
                                    : 'Seleccionar fecha',
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Vida Útil en Meses
                          TextFormField(
                            controller: _vidaUtilMesesController,
                            decoration: const InputDecoration(
                              labelText: 'Vida Útil (meses)',
                              hintText: '36',
                              prefixIcon: Icon(Icons.timelapse),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Valor Residual
                          TextFormField(
                            controller: _valorResidualController,
                            decoration: const InputDecoration(
                              labelText: 'Valor Residual',
                              hintText: '0.00',
                              prefixIcon: Icon(Icons.savings),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Garantía
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información de Garantía',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),

                          // Fecha Inicio Garantía
                          InkWell(
                            onTap: () => _selectDate(
                              context,
                              _fechaInicioGarantia,
                              (date) => _fechaInicioGarantia = date,
                            ),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Inicio de Garantía',
                                prefixIcon: Icon(Icons.event),
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                _fechaInicioGarantia != null
                                    ? DateFormat('dd/MM/yyyy')
                                        .format(_fechaInicioGarantia!)
                                    : 'Seleccionar fecha',
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Fecha Fin Garantía
                          InkWell(
                            onTap: () => _selectDate(
                              context,
                              _fechaFinGarantia,
                              (date) => _fechaFinGarantia = date,
                            ),
                            child: InputDecorator(
                              decoration: const InputDecoration(
                                labelText: 'Fin de Garantía',
                                prefixIcon: Icon(Icons.event_busy),
                                border: OutlineInputBorder(),
                              ),
                              child: Text(
                                _fechaFinGarantia != null
                                    ? DateFormat('dd/MM/yyyy')
                                        .format(_fechaFinGarantia!)
                                    : 'Seleccionar fecha',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Observaciones
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Observaciones',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            controller: _observacionesController,
                            decoration: const InputDecoration(
                              labelText: 'Observaciones',
                              hintText: 'Notas adicionales...',
                              prefixIcon: Icon(Icons.note),
                              border: OutlineInputBorder(),
                            ),
                            maxLines: 4,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Botón de envío
                  ElevatedButton(
                    onPressed: isLoading ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            _isEditing ? 'Actualizar Equipo' : 'Crear Equipo',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          );
        },
      ),
    );
  }
}
