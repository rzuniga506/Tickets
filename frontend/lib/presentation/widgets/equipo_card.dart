import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/equipo_model.dart';
import '../../config/theme.dart';
import 'equipment_status_chip.dart';
import 'condition_badge.dart';
import 'tipo_equipo_badge.dart';

/// Widget para mostrar un equipo en formato de tarjeta
class EquipoCard extends StatelessWidget {
  final EquipoModel equipo;
  final VoidCallback onTap;

  const EquipoCard({
    super.key,
    required this.equipo,
    required this.onTap,
  });

  String _formatDate(DateTime date) {
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
              // Header: Tipo y Condición
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TipoEquipoBadge(tipo: equipo.tipo, compact: true),
                  ConditionBadge(condicion: equipo.condicion, compact: true),
                ],
              ),
              const SizedBox(height: 12),

              // Nombre/Marca y Modelo
              Text(
                equipo.marca,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                equipo.modelo,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),

              // Número de serie
              if (equipo.numeroSerie != null) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.tag,
                      size: 14,
                      color: AppTheme.greyDark,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'S/N: ${equipo.numeroSerie}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.greyDark,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Estado y ubicación
              Row(
                children: [
                  EquipmentStatusChip(estado: equipo.estado, compact: true),
                  const SizedBox(width: 8),
                  if (equipo.ubicacion.isNotEmpty)
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.greyLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.location_on, size: 14, color: AppTheme.greyDark),
                            const SizedBox(width: 4),
                            Flexible(
                              child: Text(
                                equipo.ubicacion,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.greyDark,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Usuario asignado o disponibilidad
              if (equipo.usuarioAsignado != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.person,
                        size: 16,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Asignado a: ${equipo.usuarioAsignado!.nombreCompleto}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        size: 16,
                        color: AppTheme.successColor,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Disponible para asignación',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.successColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              // Fecha de adquisición
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.event, size: 12, color: AppTheme.greyDark),
                  const SizedBox(width: 4),
                  Text(
                    'Adquirido: ${_formatDate(equipo.fechaAdquisicion)}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.greyDark,
                    ),
                  ),
                ],
              ),

              // Indicador de QR si existe
              if (equipo.codigoQR != null && equipo.codigoQR!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.qr_code,
                        size: 14,
                        color: AppTheme.primaryColor.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'QR: ${equipo.codigoQR!.substring(0, equipo.codigoQR!.length > 12 ? 12 : equipo.codigoQR!.length)}...',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.primaryColor.withOpacity(0.7),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
