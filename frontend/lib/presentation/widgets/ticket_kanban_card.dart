import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/ticket/ticket_model.dart';
import '../../config/theme.dart';
import 'status_chip.dart';
import 'priority_badge.dart';

/// Widget compacto para mostrar un ticket en vista Kanban
class TicketKanbanCard extends StatelessWidget {
  final TicketModel ticket;
  final VoidCallback onTap;

  const TicketKanbanCard({
    super.key,
    required this.ticket,
    required this.onTap,
  });

  String _formatDateShort(DateTime date) {
    return DateFormat('dd/MM').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: Número y prioridad
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '#${ticket.id}',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                  ),
                  PriorityBadge(prioridad: ticket.prioridad, compact: true),
                ],
              ),
              const SizedBox(height: 8),

              // Asunto
              Text(
                ticket.asunto,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Estado
              StatusChip(estado: ticket.estado, compact: true),
              const SizedBox(height: 8),

              // Usuario y fecha
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 14, color: AppTheme.greyDark),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      ticket.solicitanteNombre,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppTheme.greyDark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Técnico asignado
              if (ticket.tecnicoAsignadoNombre != null)
                Row(
                  children: [
                    const Icon(Icons.engineering_outlined, size: 14, color: AppTheme.primaryColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        ticket.tecnicoAsignadoNombre!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

              // Fecha
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 12, color: AppTheme.greyDark),
                  const SizedBox(width: 4),
                  Text(
                    _formatDateShort(ticket.fechaCreacion),
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppTheme.greyDark,
                    ),
                  ),
                ],
              ),

              // Indicador SLA
              if (ticket.slaVencido || ticket.slaProximoVencer)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: ticket.slaVencido
                          ? AppTheme.errorColor.withOpacity(0.1)
                          : AppTheme.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          ticket.slaVencido ? Icons.error : Icons.warning,
                          size: 10,
                          color: ticket.slaVencido
                              ? AppTheme.errorColor
                              : AppTheme.warningColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          ticket.slaVencido ? 'SLA Vencido' : 'SLA Próximo',
                          style: TextStyle(
                            fontSize: 9,
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
}
