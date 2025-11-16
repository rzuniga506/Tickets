import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../data/models/notificacion/notificacion_model.dart';
import '../../config/constants.dart';
import '../../config/theme.dart';

/// Widget para mostrar una notificación en formato de tarjeta
class NotificacionCard extends StatelessWidget {
  final NotificacionModel notificacion;
  final VoidCallback onTap;
  final VoidCallback? onDismiss;

  const NotificacionCard({
    super.key,
    required this.notificacion,
    required this.onTap,
    this.onDismiss,
  });

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  String _getTimeAgo(DateTime date) {
    timeago.setLocaleMessages('es', timeago.EsMessages());
    return timeago.format(date, locale: 'es');
  }

  Color _getColorForTipo(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.ticketNuevo:
      case TipoNotificacion.ticketAsignado:
      case TipoNotificacion.ticketEnProceso:
      case TipoNotificacion.ticketActualizado:
        return AppTheme.infoColor;
      case TipoNotificacion.ticketResuelto:
      case TipoNotificacion.ticketCerrado:
      case TipoNotificacion.slaCumplido:
        return AppTheme.successColor;
      case TipoNotificacion.slaProximoVencer:
        return AppTheme.warningColor;
      case TipoNotificacion.slaIncumplido:
        return AppTheme.errorColor;
      case TipoNotificacion.equipoAsignado:
      case TipoNotificacion.equipoDesasignado:
        return AppTheme.accentColor;
      case TipoNotificacion.general:
        return AppTheme.greyDark;
    }
  }

  IconData _getIconForTipo(TipoNotificacion tipo) {
    switch (tipo) {
      case TipoNotificacion.ticketNuevo:
        return Icons.add_circle_outline;
      case TipoNotificacion.ticketAsignado:
        return Icons.assignment_ind_outlined;
      case TipoNotificacion.ticketEnProceso:
        return Icons.pending_actions_outlined;
      case TipoNotificacion.ticketActualizado:
        return Icons.update_outlined;
      case TipoNotificacion.ticketResuelto:
      case TipoNotificacion.ticketCerrado:
        return Icons.check_circle_outline;
      case TipoNotificacion.slaProximoVencer:
        return Icons.warning_amber_outlined;
      case TipoNotificacion.slaCumplido:
        return Icons.check;
      case TipoNotificacion.slaIncumplido:
        return Icons.error_outline;
      case TipoNotificacion.equipoAsignado:
      case TipoNotificacion.equipoDesasignado:
        return Icons.devices_outlined;
      case TipoNotificacion.general:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForTipo(notificacion.tipo);
    final icon = _getIconForTipo(notificacion.tipo);

    Widget cardContent = Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      elevation: notificacion.leida ? 0 : 2,
      color: notificacion.leida ? null : color.withOpacity(0.05),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icono
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),

              // Contenido
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título y badge no leída
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notificacion.titulo,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: notificacion.leida
                                      ? FontWeight.w500
                                      : FontWeight.bold,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!notificacion.leida)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Mensaje
                    Text(
                      notificacion.mensaje,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.greyDark,
                          ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Hora y referencias
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppTheme.greyDark.withOpacity(0.7),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getTimeAgo(notificacion.fechaCreacion),
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.greyDark.withOpacity(0.7),
                          ),
                        ),

                        // Referencias a ticket o equipo
                        if (notificacion.entidadId != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.confirmation_number,
                            size: 14,
                            color: AppTheme.primaryColor.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Ticket #${notificacion.entidadId}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.primaryColor.withOpacity(0.7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],

                        if (notificacion.entidadId != null) ...[
                          const SizedBox(width: 12),
                          Icon(
                            Icons.devices,
                            size: 14,
                            color: AppTheme.accentColor.withOpacity(0.7),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Equipo #${notificacion.entidadId}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppTheme.accentColor.withOpacity(0.7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    // Agregar funcionalidad de deslizar para eliminar si se proporciona onDismiss
    if (onDismiss != null) {
      return Dismissible(
        key: Key('notificacion_${notificacion.id}'),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.errorColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.delete_outline,
            color: Colors.white,
            size: 28,
          ),
        ),
        confirmDismiss: (direction) async {
          return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Eliminar Notificación'),
              content: const Text(
                '¿Estás seguro de que deseas eliminar esta notificación?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                  ),
                  child: const Text('Eliminar'),
                ),
              ],
            ),
          );
        },
        onDismissed: (direction) {
          onDismiss!();
        },
        child: cardContent,
      );
    }

    return cardContent;
  }
}
