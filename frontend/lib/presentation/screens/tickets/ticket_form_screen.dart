import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../../logic/tickets/ticket_cubit.dart';
import '../../../logic/tickets/ticket_state.dart';
import '../../../data/models/ticket/ticket_model.dart';
import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../widgets/priority_badge.dart';
import '../../../core/utils/responsive.dart';

class TicketFormScreen extends StatefulWidget {
  final TicketModel? ticket; // Para edición (opcional)

  const TicketFormScreen({
    super.key,
    this.ticket,
  });

  @override
  State<TicketFormScreen> createState() => _TicketFormScreenState();
}

class _TicketFormScreenState extends State<TicketFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();

  PrioridadTicket _prioridad = PrioridadTicket.media;
  TipoSoporte _tipoSoporte = TipoSoporte.soporteTecnico;
  List<PlatformFile> _archivosAdjuntos = [];

  bool get _isEditing => widget.ticket != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _tituloController.text = widget.ticket!.asunto;
      _descripcionController.text = widget.ticket!.descripcion;
      _prioridad = widget.ticket!.prioridad;
      _tipoSoporte = widget.ticket!.tipoSoporte;
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      if (_isEditing) {
        // Actualizar ticket existente
        context.read<TicketCubit>().updateTicket(
              id: widget.ticket!.id,
              asunto: _tituloController.text.trim(),
              descripcion: _descripcionController.text.trim(),
              prioridad: _prioridad,
              tipoSoporte: _tipoSoporte,
              equipoId: null, // TODO: Agregar selector de equipo si es necesario
            );
      } else {
        // Crear nuevo ticket
        // TODO: Enviar archivos adjuntos al backend cuando se implemente la API
        context.read<TicketCubit>().createTicket(
              asunto: _tituloController.text.trim(),
              descripcion: _descripcionController.text.trim(),
              prioridad: _prioridad,
              tipoSoporte: _tipoSoporte,
              equipoId: null, // TODO: Agregar selector de equipo si es necesario
            );
      }
    }
  }

  Future<void> _seleccionarArchivos() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'jpg', 'jpeg', 'png', 'txt'],
        withData: true, // Necesario para obtener los bytes
      );

      if (result != null) {
        // Validar tamaño (máximo 10MB por archivo)
        const maxSize = 10 * 1024 * 1024; // 10MB
        final archivosValidos = result.files.where((file) {
          if (file.size > maxSize) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${file.name} excede el tamaño máximo de 10MB'),
                backgroundColor: AppTheme.warningColor,
              ),
            );
            return false;
          }
          return true;
        }).toList();

        // Validar cantidad total (máximo 5 archivos)
        if (_archivosAdjuntos.length + archivosValidos.length > 5) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Máximo 5 archivos permitidos'),
              backgroundColor: AppTheme.warningColor,
            ),
          );
          return;
        }

        setState(() {
          _archivosAdjuntos.addAll(archivosValidos);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar archivos: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  void _eliminarArchivo(int index) {
    setState(() {
      _archivosAdjuntos.removeAt(index);
    });
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  IconData _getFileIcon(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Ticket' : 'Nuevo Ticket'),
      ),
      body: BlocConsumer<TicketCubit, TicketState>(
        listener: (context, state) {
          if (state is TicketCreated || state is TicketUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _isEditing
                      ? 'Ticket actualizado correctamente'
                      : 'Ticket creado correctamente',
                ),
                backgroundColor: AppTheme.successColor,
              ),
            );
            Navigator.pop(context, true);
          } else if (state is TicketError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is TicketActionLoading;

          return SingleChildScrollView(
            padding: EdgeInsets.all(Breakpoints.getHorizontalPadding(context)),
            child: CenteredContent(
              maxWidth: 600,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  // Información
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
                                color: AppTheme.infoColor,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Información del Ticket',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Complete todos los campos para crear un ticket de soporte.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.greyDark,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Título
                  TextFormField(
                    controller: _tituloController,
                    decoration: const InputDecoration(
                      labelText: 'Título *',
                      hintText: 'Resumen breve del problema',
                      prefixIcon: Icon(Icons.title),
                      border: OutlineInputBorder(),
                    ),
                    enabled: !isLoading,
                    maxLength: 200,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'El título es requerido';
                      }
                      if (value.trim().length < 10) {
                        return 'El título debe tener al menos 10 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Descripción
                  TextFormField(
                    controller: _descripcionController,
                    decoration: const InputDecoration(
                      labelText: 'Descripción *',
                      hintText: 'Describe el problema en detalle',
                      prefixIcon: Icon(Icons.description),
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                    enabled: !isLoading,
                    maxLines: 5,
                    maxLength: 1000,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'La descripción es requerida';
                      }
                      if (value.trim().length < 20) {
                        return 'La descripción debe tener al menos 20 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Tipo de Soporte
                  DropdownButtonFormField<TipoSoporte>(
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Soporte *',
                      hintText: 'Seleccione el tipo de soporte',
                      prefixIcon: Icon(Icons.support_agent),
                      border: OutlineInputBorder(),
                    ),
                    value: _tipoSoporte,
                    items: TipoSoporte.values.map((tipo) {
                      return DropdownMenuItem(
                        value: tipo,
                        child: Text(tipo.displayName),
                      );
                    }).toList(),
                    onChanged: isLoading
                        ? null
                        : (value) {
                            if (value != null) {
                              setState(() {
                                _tipoSoporte = value;
                              });
                            }
                          },
                    validator: (value) {
                      if (value == null) {
                        return 'El tipo de soporte es requerido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Prioridad
                  Text(
                    'Prioridad *',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: PrioridadTicket.values.map((prioridad) {
                      final isSelected = _prioridad == prioridad;
                      return RadioListTile<PrioridadTicket>(
                        title: Row(
                          children: [
                            PriorityBadge(prioridad: prioridad, compact: true),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _getDescripcionPrioridad(prioridad),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                        value: prioridad,
                        groupValue: _prioridad,
                        onChanged: isLoading
                            ? null
                            : (value) {
                                if (value != null) {
                                  setState(() {
                                    _prioridad = value;
                                  });
                                }
                              },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // Archivos Adjuntos
                  Text(
                    'Archivos Adjuntos (Opcional)',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Máximo 5 archivos, 10MB cada uno. Formatos: PDF, DOC, XLS, JPG, PNG, TXT',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.greyDark,
                        ),
                  ),
                  const SizedBox(height: 12),

                  // Botón para adjuntar archivos
                  OutlinedButton.icon(
                    onPressed: isLoading ? null : _seleccionarArchivos,
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Adjuntar Archivos'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                    ),
                  ),

                  // Lista de archivos adjuntos
                  if (_archivosAdjuntos.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.greyLight),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _archivosAdjuntos.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final archivo = _archivosAdjuntos[index];
                          return ListTile(
                            leading: Icon(
                              _getFileIcon(archivo.extension),
                              color: AppTheme.primaryColor,
                            ),
                            title: Text(
                              archivo.name,
                              style: const TextStyle(fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              _formatFileSize(archivo.size),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.greyDark,
                                  ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: AppTheme.errorColor,
                              onPressed: isLoading ? null : () => _eliminarArchivo(index),
                              tooltip: 'Eliminar archivo',
                            ),
                          );
                        },
                      ),
                    ),
                  ],
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
                  const SizedBox(height: 16),

                  // Nota informativa
                  Card(
                    color: AppTheme.infoColor.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info,
                            color: AppTheme.infoColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Su ticket será revisado y asignado a un técnico lo antes posible.',
                              style:
                                  Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppTheme.infoColor,
                                      ),
                            ),
                          ),
                        ],
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

  String _getDescripcionPrioridad(PrioridadTicket prioridad) {
    switch (prioridad) {
      case PrioridadTicket.baja:
        return 'Problema menor, sin impacto en operaciones';
      case PrioridadTicket.media:
        return 'Problema moderado, impacto limitado';
      case PrioridadTicket.alta:
        return 'Problema importante, requiere atención pronta';
      case PrioridadTicket.critica:
        return 'Problema crítico, impide operaciones normales';
    }
  }
}
