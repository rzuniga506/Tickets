import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/tickets/ticket_cubit.dart';
import '../../../logic/tickets/ticket_state.dart';
import '../../../data/models/ticket_model.dart';
import '../../../config/constants.dart';
import '../../../config/theme.dart';
import '../../widgets/priority_badge.dart';

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

  CategoriaTicket _categoria = CategoriaTicket.hardware;
  PrioridadTicket _prioridad = PrioridadTicket.media;

  bool get _isEditing => widget.ticket != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _tituloController.text = widget.ticket!.titulo;
      _descripcionController.text = widget.ticket!.descripcion;
      _categoria = widget.ticket!.categoria;
      _prioridad = widget.ticket!.prioridad;
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
              widget.ticket!.id,
              UpdateTicketRequest(
                titulo: _tituloController.text.trim(),
                descripcion: _descripcionController.text.trim(),
                categoria: _categoria,
                prioridad: _prioridad,
              ),
            );
      } else {
        // Crear nuevo ticket
        context.read<TicketCubit>().createTicket(
              CreateTicketRequest(
                titulo: _tituloController.text.trim(),
                descripcion: _descripcionController.text.trim(),
                categoria: _categoria,
                prioridad: _prioridad,
              ),
            );
      }
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
            padding: const EdgeInsets.all(16),
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

                  // Categoría
                  Text(
                    'Categoría *',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: CategoriaTicket.values.map((categoria) {
                      final isSelected = _categoria == categoria;
                      return ChoiceChip(
                        label: Text(categoria.displayName),
                        selected: isSelected,
                        onSelected: isLoading
                            ? null
                            : (selected) {
                                if (selected) {
                                  setState(() {
                                    _categoria = categoria;
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
