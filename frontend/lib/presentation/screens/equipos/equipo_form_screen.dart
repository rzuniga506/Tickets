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

  // Campos de inventario
  final _marcaController = TextEditingController();
  final _proveedorController = TextEditingController();
  final _skuController = TextEditingController();
  final _numeroOrdenCompraController = TextEditingController();
  final _ubicacionFisicaController = TextEditingController();
  final _procesadorController = TextEditingController();
  final _ramGBController = TextEditingController();
  final _discoDuroCapacidadGBController = TextEditingController();
  final _tipoAlmacenamientoController = TextEditingController();
  final _macAddressController = TextEditingController();
  final _direccionIPController = TextEditingController();
  final _hostnameController = TextEditingController();
  final _sistemaOperativoController = TextEditingController();
  final _versionSOController = TextEditingController();
  final _licenciaSOController = TextEditingController();

  TipoEquipo _tipo = TipoEquipo.computadora;
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

    // Campos de inventario
    _marcaController.text = equipo.marca ?? '';
    _proveedorController.text = equipo.proveedor ?? '';
    _skuController.text = equipo.sku ?? '';
    _numeroOrdenCompraController.text = equipo.numeroOrdenCompra ?? '';
    _ubicacionFisicaController.text = equipo.ubicacionFisica ?? '';
    _procesadorController.text = equipo.procesador ?? '';
    _ramGBController.text = equipo.ramGB?.toString() ?? '';
    _discoDuroCapacidadGBController.text = equipo.discoDuroCapacidadGB?.toString() ?? '';
    _tipoAlmacenamientoController.text = equipo.tipoAlmacenamiento ?? '';
    _macAddressController.text = equipo.macAddress ?? '';
    _direccionIPController.text = equipo.direccionIP ?? '';
    _hostnameController.text = equipo.hostname ?? '';
    _sistemaOperativoController.text = equipo.sistemaOperativo ?? '';
    _versionSOController.text = equipo.versionSO ?? '';
    _licenciaSOController.text = equipo.licenciaSO ?? '';

    _tipo = equipo.tipo;
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
    // Inventario
    _marcaController.dispose();
    _proveedorController.dispose();
    _skuController.dispose();
    _numeroOrdenCompraController.dispose();
    _ubicacionFisicaController.dispose();
    _procesadorController.dispose();
    _ramGBController.dispose();
    _discoDuroCapacidadGBController.dispose();
    _tipoAlmacenamientoController.dispose();
    _macAddressController.dispose();
    _direccionIPController.dispose();
    _hostnameController.dispose();
    _sistemaOperativoController.dispose();
    _versionSOController.dispose();
    _licenciaSOController.dispose();
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

      // Campos de inventario
      final ramGB = _ramGBController.text.trim().isNotEmpty
          ? int.tryParse(_ramGBController.text)
          : null;

      final discoDuroCapacidadGB = _discoDuroCapacidadGBController.text.trim().isNotEmpty
          ? int.tryParse(_discoDuroCapacidadGBController.text)
          : null;

      if (_isEditing) {
        // Actualizar equipo existente
        context.read<EquipoCubit>().updateEquipo(
              id: widget.equipo!.id,
              nombre: _nombreController.text.trim(),
              estado: _estado,
              condicion: _condicion,
              tipo: _tipo,
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
              // Campos de inventario
              marca: _marcaController.text.trim().isNotEmpty ? _marcaController.text.trim() : null,
              proveedor: _proveedorController.text.trim().isNotEmpty ? _proveedorController.text.trim() : null,
              sku: _skuController.text.trim().isNotEmpty ? _skuController.text.trim() : null,
              numeroOrdenCompra: _numeroOrdenCompraController.text.trim().isNotEmpty ? _numeroOrdenCompraController.text.trim() : null,
              ubicacionFisica: _ubicacionFisicaController.text.trim().isNotEmpty ? _ubicacionFisicaController.text.trim() : null,
              procesador: _procesadorController.text.trim().isNotEmpty ? _procesadorController.text.trim() : null,
              ramGB: ramGB,
              discoDuroCapacidadGB: discoDuroCapacidadGB,
              tipoAlmacenamiento: _tipoAlmacenamientoController.text.trim().isNotEmpty ? _tipoAlmacenamientoController.text.trim() : null,
              macAddress: _macAddressController.text.trim().isNotEmpty ? _macAddressController.text.trim() : null,
              direccionIP: _direccionIPController.text.trim().isNotEmpty ? _direccionIPController.text.trim() : null,
              hostname: _hostnameController.text.trim().isNotEmpty ? _hostnameController.text.trim() : null,
              sistemaOperativo: _sistemaOperativoController.text.trim().isNotEmpty ? _sistemaOperativoController.text.trim() : null,
              versionSO: _versionSOController.text.trim().isNotEmpty ? _versionSOController.text.trim() : null,
              licenciaSO: _licenciaSOController.text.trim().isNotEmpty ? _licenciaSOController.text.trim() : null,
            );
      } else {
        // Crear nuevo equipo
        context.read<EquipoCubit>().createEquipo(
              codigoInterno: _codigoInternoController.text.trim(),
              nombre: _nombreController.text.trim(),
              estado: _estado,
              condicion: _condicion,
              tipo: _tipo,
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
              // Campos de inventario
              marca: _marcaController.text.trim().isNotEmpty ? _marcaController.text.trim() : null,
              proveedor: _proveedorController.text.trim().isNotEmpty ? _proveedorController.text.trim() : null,
              sku: _skuController.text.trim().isNotEmpty ? _skuController.text.trim() : null,
              numeroOrdenCompra: _numeroOrdenCompraController.text.trim().isNotEmpty ? _numeroOrdenCompraController.text.trim() : null,
              ubicacionFisica: _ubicacionFisicaController.text.trim().isNotEmpty ? _ubicacionFisicaController.text.trim() : null,
              procesador: _procesadorController.text.trim().isNotEmpty ? _procesadorController.text.trim() : null,
              ramGB: ramGB,
              discoDuroCapacidadGB: discoDuroCapacidadGB,
              tipoAlmacenamiento: _tipoAlmacenamientoController.text.trim().isNotEmpty ? _tipoAlmacenamientoController.text.trim() : null,
              macAddress: _macAddressController.text.trim().isNotEmpty ? _macAddressController.text.trim() : null,
              direccionIP: _direccionIPController.text.trim().isNotEmpty ? _direccionIPController.text.trim() : null,
              hostname: _hostnameController.text.trim().isNotEmpty ? _hostnameController.text.trim() : null,
              sistemaOperativo: _sistemaOperativoController.text.trim().isNotEmpty ? _sistemaOperativoController.text.trim() : null,
              versionSO: _versionSOController.text.trim().isNotEmpty ? _versionSOController.text.trim() : null,
              licenciaSO: _licenciaSOController.text.trim().isNotEmpty ? _licenciaSOController.text.trim() : null,
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
                          const SizedBox(height: 16),

                          // Tipo de Equipo
                          DropdownButtonFormField<TipoEquipo>(
                            value: _tipo,
                            decoration: const InputDecoration(
                              labelText: 'Tipo de Equipo *',
                              prefixIcon: Icon(Icons.category),
                              border: OutlineInputBorder(),
                            ),
                            items: TipoEquipo.values.map((tipo) {
                              return DropdownMenuItem(
                                value: tipo,
                                child: Text(tipo.displayName),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _tipo = value;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Información de Inventario
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Información de Inventario',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 16),

                          // Marca
                          TextFormField(
                            controller: _marcaController,
                            decoration: const InputDecoration(
                              labelText: 'Marca',
                              hintText: 'Ej: Dell, HP, Cisco',
                              prefixIcon: Icon(Icons.business),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Proveedor
                          TextFormField(
                            controller: _proveedorController,
                            decoration: const InputDecoration(
                              labelText: 'Proveedor',
                              hintText: 'Nombre del proveedor',
                              prefixIcon: Icon(Icons.store),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // SKU
                          TextFormField(
                            controller: _skuController,
                            decoration: const InputDecoration(
                              labelText: 'SKU',
                              hintText: 'Código SKU del producto',
                              prefixIcon: Icon(Icons.inventory_2),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Número de Orden de Compra
                          TextFormField(
                            controller: _numeroOrdenCompraController,
                            decoration: const InputDecoration(
                              labelText: 'Orden de Compra',
                              hintText: 'Número de orden',
                              prefixIcon: Icon(Icons.receipt_long),
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Ubicación Física
                          TextFormField(
                            controller: _ubicacionFisicaController,
                            decoration: const InputDecoration(
                              labelText: 'Ubicación Física',
                              hintText: 'Edificio, Piso, Sala',
                              prefixIcon: Icon(Icons.location_on),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Hardware - Solo para computadoras, laptops, servidores
                  if (_tipo == TipoEquipo.computadora ||
                      _tipo == TipoEquipo.laptop ||
                      _tipo == TipoEquipo.servidor)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Especificaciones de Hardware',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 16),

                            // Procesador
                            TextFormField(
                              controller: _procesadorController,
                              decoration: const InputDecoration(
                                labelText: 'Procesador',
                                hintText: 'Ej: Intel Core i7-11370H',
                                prefixIcon: Icon(Icons.memory),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // RAM GB
                            TextFormField(
                              controller: _ramGBController,
                              decoration: const InputDecoration(
                                labelText: 'RAM (GB)',
                                hintText: 'Ej: 16',
                                prefixIcon: Icon(Icons.developer_board),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Disco Duro Capacidad
                            TextFormField(
                              controller: _discoDuroCapacidadGBController,
                              decoration: const InputDecoration(
                                labelText: 'Capacidad Disco (GB)',
                                hintText: 'Ej: 512',
                                prefixIcon: Icon(Icons.storage),
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Tipo de Almacenamiento
                            TextFormField(
                              controller: _tipoAlmacenamientoController,
                              decoration: const InputDecoration(
                                labelText: 'Tipo de Almacenamiento',
                                hintText: 'Ej: SSD NVMe, HDD',
                                prefixIcon: Icon(Icons.save),
                                border: OutlineInputBorder(),
                              ),
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
                            ),
                            const SizedBox(height: 16),

                            // Versión SO
                            TextFormField(
                              controller: _versionSOController,
                              decoration: const InputDecoration(
                                labelText: 'Versión SO',
                                hintText: 'Ej: 22H2',
                                prefixIcon: Icon(Icons.numbers),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Licencia SO
                            TextFormField(
                              controller: _licenciaSOController,
                              decoration: const InputDecoration(
                                labelText: 'Licencia SO',
                                hintText: 'Ej: XXXXX-XXXXX-XXXXX',
                                prefixIcon: Icon(Icons.key),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (_tipo == TipoEquipo.computadora ||
                      _tipo == TipoEquipo.laptop ||
                      _tipo == TipoEquipo.servidor)
                    const SizedBox(height: 16),

                  // Red - Para equipos con conectividad de red
                  if (_tipo == TipoEquipo.computadora ||
                      _tipo == TipoEquipo.laptop ||
                      _tipo == TipoEquipo.servidor ||
                      _tipo == TipoEquipo.switch_ ||
                      _tipo == TipoEquipo.router ||
                      _tipo == TipoEquipo.firewall ||
                      _tipo == TipoEquipo.telefono)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Información de Red',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 16),

                            // MAC Address
                            TextFormField(
                              controller: _macAddressController,
                              decoration: const InputDecoration(
                                labelText: 'Dirección MAC',
                                hintText: 'Ej: AA:BB:CC:DD:EE:FF',
                                prefixIcon: Icon(Icons.settings_ethernet),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value != null && value.trim().isNotEmpty) {
                                  final macRegex = RegExp(
                                    r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$',
                                  );
                                  if (!macRegex.hasMatch(value)) {
                                    return 'Formato inválido (ej: AA:BB:CC:DD:EE:FF)';
                                  }
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Dirección IP
                            TextFormField(
                              controller: _direccionIPController,
                              decoration: const InputDecoration(
                                labelText: 'Dirección IP',
                                hintText: 'Ej: 192.168.1.100',
                                prefixIcon: Icon(Icons.network_check),
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Hostname
                            TextFormField(
                              controller: _hostnameController,
                              decoration: const InputDecoration(
                                labelText: 'Hostname',
                                hintText: 'Ej: WS-IT-001',
                                prefixIcon: Icon(Icons.dns),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (_tipo == TipoEquipo.computadora ||
                      _tipo == TipoEquipo.laptop ||
                      _tipo == TipoEquipo.servidor ||
                      _tipo == TipoEquipo.switch_ ||
                      _tipo == TipoEquipo.router ||
                      _tipo == TipoEquipo.firewall ||
                      _tipo == TipoEquipo.telefono)
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
