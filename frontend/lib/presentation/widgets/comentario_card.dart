import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/comentario/comentario_ticket_model.dart';
import '../../config/theme.dart';

/// Widget para mostrar un comentario individual
class ComentarioCard extends StatelessWidget {
  final ComentarioTicketModel comentario;
  final int? currentUserId;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ComentarioCard({
    super.key,
    required this.comentario,
    this.currentUserId,
    this.onEdit,
    this.onDelete,
  });

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'ahora';
    }
  }

  bool get _canEdit =>
      currentUserId != null &&
      currentUserId == comentario.usuarioId &&
      !comentario.esSistema;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: comentario.esSistema ? 0 : 1,
      color: comentario.esSistema
          ? AppTheme.infoColor.withOpacity(0.05)
          : null,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 16,
                  backgroundColor: comentario.esSistema
                      ? AppTheme.infoColor
                      : AppTheme.primaryColor,
                  child: Icon(
                    comentario.esSistema ? Icons.smart_toy : Icons.person,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),

                // Usuario y fecha
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            comentario.usuarioNombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                          if (comentario.esSistema) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.infoColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'SISTEMA',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.infoColor,
                                ),
                              ),
                            ),
                          ],
                          if (comentario.esInterno) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.warningColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'INTERNO',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.warningColor,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            _formatTimeAgo(comentario.fechaCreacion),
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.greyDark,
                            ),
                          ),
                          if (comentario.fechaModificacion != null) ...[
                            const Text(' • ', style: TextStyle(fontSize: 11)),
                            const Text(
                              'editado',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppTheme.greyDark,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Acciones
                if (_canEdit)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, size: 18),
                    onSelected: (value) {
                      if (value == 'edit' && onEdit != null) {
                        onEdit!();
                      } else if (value == 'delete' && onDelete != null) {
                        onDelete!();
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 18),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 18, color: AppTheme.errorColor),
                            SizedBox(width: 8),
                            Text('Eliminar', style: TextStyle(color: AppTheme.errorColor)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Contenido
            _buildContenido(context),

            // Menciones
            if (comentario.menciones.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: comentario.menciones.map((mencion) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.alternate_email,
                          size: 12,
                          color: AppTheme.primaryColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          mencion.usuarioMencionadoNombre,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContenido(BuildContext context) {
    // Procesar menciones en el contenido
    final textoConMenciones = _highlightMentions(comentario.contenido);
    
    return Text(
      textoConMenciones,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontSize: 13,
            height: 1.5,
          ),
    );
  }

  String _highlightMentions(String texto) {
    // Por ahora retornamos el texto plano
    // En una implementación más avanzada, se podría usar RichText
    return texto;
  }
}
