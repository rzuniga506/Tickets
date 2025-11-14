import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/comentario/comentario_ticket_model.dart';
import '../../config/theme.dart';

class ComentarioCard extends StatelessWidget {
  final ComentarioTicketModel comentario;
  final int currentUserId;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const ComentarioCard({
    super.key,
    required this.comentario,
    required this.currentUserId,
    this.onEdit,
    this.onDelete,
  });

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Justo ahora';
    } else if (difference.inMinutes < 60) {
      return 'Hace ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Hace ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} d';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    }
  }

  bool get _canEdit => comentario.usuarioId == currentUserId && comentario.puedeEditar;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: comentario.esSistema ? 0 : 1,
      color: comentario.esSistema
          ? AppTheme.greyLight.withOpacity(0.3)
          : comentario.esInterno
              ? AppTheme.warningColor.withOpacity(0.05)
              : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: comentario.esSistema
                      ? AppTheme.greyDark
                      : AppTheme.primaryColor,
                  child: Text(
                    comentario.esSistema
                        ? 'S'
                        : comentario.usuarioNombre.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            comentario.esSistema
                                ? 'Sistema'
                                : comentario.usuarioNombre,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (comentario.esInterno) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.warningColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'INTERNO',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      Text(
                        _formatDate(comentario.fechaCreacion),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.greyDark,
                        ),
                      ),
                      if (comentario.fueEditado)
                        const Text(
                          'Editado',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppTheme.greyDark,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
                if (_canEdit)
                  PopupMenuButton<String>(
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
            const SizedBox(height: 8),

            // Contenido
            Text(
              comentario.contenido,
              style: TextStyle(
                fontSize: 13,
                color: comentario.esSistema
                    ? AppTheme.greyDark
                    : Colors.black87,
                fontStyle: comentario.esSistema
                    ? FontStyle.italic
                    : FontStyle.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
