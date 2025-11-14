import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../data/models/comentario/comentario_ticket_model.dart';

class ComentarioForm extends StatefulWidget {
  final int ticketId;
  final ComentarioTicketModel? comentarioToEdit;
  final Function(String contenido, bool esInterno) onSubmit;
  final VoidCallback? onCancel;
  final bool canMarkInternal;

  const ComentarioForm({
    super.key,
    required this.ticketId,
    this.comentarioToEdit,
    required this.onSubmit,
    this.onCancel,
    this.canMarkInternal = false,
  });

  @override
  State<ComentarioForm> createState() => _ComentarioFormState();
}

class _ComentarioFormState extends State<ComentarioForm> {
  final _formKey = GlobalKey<FormState>();
  final _contenidoController = TextEditingController();
  bool _esInterno = false;

  @override
  void initState() {
    super.initState();
    if (widget.comentarioToEdit != null) {
      _contenidoController.text = widget.comentarioToEdit!.contenido;
      _esInterno = widget.comentarioToEdit!.esInterno;
    }
  }

  @override
  void dispose() {
    _contenidoController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit(_contenidoController.text.trim(), _esInterno);
      if (widget.comentarioToEdit == null) {
        // Si es creación, limpiar el formulario
        _contenidoController.clear();
        setState(() {
          _esInterno = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.comentarioToEdit != null;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isEditing)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Editar Comentario',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (widget.onCancel != null)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: widget.onCancel,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                  ],
                ),
              if (isEditing) const SizedBox(height: 12),

              // Campo de texto
              TextFormField(
                controller: _contenidoController,
                decoration: const InputDecoration(
                  hintText: 'Escribe un comentario...',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'El comentario no puede estar vacío';
                  }
                  if (value.trim().length > 5000) {
                    return 'El comentario no puede exceder 5000 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Opciones
              Row(
                children: [
                  if (widget.canMarkInternal)
                    Expanded(
                      child: CheckboxListTile(
                        title: const Text(
                          'Comentario interno',
                          style: TextStyle(fontSize: 13),
                        ),
                        subtitle: const Text(
                          'Solo visible para técnicos',
                          style: TextStyle(fontSize: 11),
                        ),
                        value: _esInterno,
                        onChanged: (value) {
                          setState(() {
                            _esInterno = value ?? false;
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _handleSubmit,
                    icon: Icon(isEditing ? Icons.save : Icons.send),
                    label: Text(isEditing ? 'Guardar' : 'Enviar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
