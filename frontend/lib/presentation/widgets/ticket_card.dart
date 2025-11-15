import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/ticket/ticket_model.dart';
import '../../config/theme.dart';
import 'status_chip.dart';
import 'priority_badge.dart';

/// Widget para mostrar un ticket en formato de tarjeta
class TicketCard extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback onTap;

  const TicketCard({
    super.key,
    required this.ticket,
    required this.onTap,
  });

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  String _formatDateShort(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Número de ticket y prioridad
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Ticket #${ticket.id}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                  ),
                  PriorityBadge(prioridad: ticket.prioridad, compact: true),
                ],
              ),
              const SizedBox(height: 12),

              // Título
              Text(
                ticket.titulo,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Descripción
              Text(
                ticket.descripcion,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.greyDark,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Estado y categoría
              Row(
                children: [
                  StatusChip(estado: ticket.estado, compact: true),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.greyLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.category, size: 14, color: AppTheme.greyDark),
                        const SizedBox(width: 4),
                        Text(
                          ticket.categoria.displayName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.greyDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Footer: Usuario, técnico y fecha
              Row(
                children: [
                  // Usuario que creó el ticket
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline, size: 16, color: AppTheme.greyDark),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            ticket.usuario.nombreCompleto,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.greyDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Técnico asignado (si existe)
                  if (ticket.tecnico != null)
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.engineering_outlined, size: 16, color: AppTheme.primaryColor),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              ticket.tecnico!.nombreCompleto,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.primaryColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Fecha de creación
              Row(
                children: [
                  const Icon(Icons.access_time, size: 14, color: AppTheme.greyDark),
                  const SizedBox(width: 4),
                  Text(
                    'Creado: ${_formatDateShort(ticket.fechaCreacion)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.greyDark,
                    ),
                  ),
                ],
              ),

              // SLA si está por vencer o vencido
              if (ticket.slaVencido || _isSlaNearExpiry(ticket))
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: ticket.slaVencido
                          ? AppTheme.errorColor.withOpacity(0.1)
                          : AppTheme.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: ticket.slaVencido
                            ? AppTheme.errorColor
                            : AppTheme.warningColor,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          ticket.slaVencido ? Icons.error : Icons.warning,
                          size: 14,
                          color: ticket.slaVencido
                              ? AppTheme.errorColor
                              : AppTheme.warningColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ticket.slaVencido ? 'SLA Vencido' : 'SLA Próximo a Vencer',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: ticket.slaVencido
                                ? AppTheme.errorColor
                                : AppTheme.warningColor,
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
  }

  bool _isSlaNearExpiry(TicketModel ticket) {
    if (ticket.fechaLimite == null || ticket.slaVencido) return false;

    final now = DateTime.now();
    final difference = ticket.fechaLimite!.difference(now);

    // Considerar "próximo a vencer" si faltan menos de 24 horas
    return difference.inHours < 24 && difference.inHours > 0;
  }
}
