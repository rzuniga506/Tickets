import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/notificaciones/notificacion_cubit.dart';
import '../../../logic/notificaciones/notificacion_state.dart';
import '../../../logic/tickets/ticket_cubit.dart';
import '../../../logic/equipos/equipo_cubit.dart';
import '../../../config/theme.dart';
import '../../../core/di/injection.dart';
import '../../widgets/notificacion_card.dart';
import '../../widgets/loading_card.dart';
import '../../widgets/empty_state.dart';
import '../tickets/ticket_detail_screen.dart';
import '../equipos/equipo_detail_screen.dart';

class NotificacionesListScreen extends StatefulWidget {
  const NotificacionesListScreen({super.key});

  @override
  State<NotificacionesListScreen> createState() =>
      _NotificacionesListScreenState();
}

class _NotificacionesListScreenState extends State<NotificacionesListScreen> {
  final _scrollController = ScrollController();
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _soloNoLeidas = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadNotificaciones();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadNotificaciones({bool refresh = false}) {
    if (refresh) {
      _currentPage = 1;
    }

    context.read<NotificacionCubit>().getNotificaciones(
          pageNumber: _currentPage,
          pageSize: _pageSize,
          soloNoLeidas: _soloNoLeidas,
        );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<NotificacionCubit>().state;
      if (state is NotificacionesLoaded && !state.isLoadingMore) {
        if (state.notificaciones.hasMore) {
          _currentPage++;
          context.read<NotificacionCubit>().getNotificaciones(
                pageNumber: _currentPage,
                pageSize: _pageSize,
                soloNoLeidas: _soloNoLeidas,
                loadMore: true,
              );
        }
      }
    }
  }

  Future<void> _onRefresh() async {
    _loadNotificaciones(refresh: true);
    await Future.delayed(const Duration(seconds: 1));
  }

  void _toggleFiltro() {
    setState(() {
      _soloNoLeidas = !_soloNoLeidas;
    });
    _loadNotificaciones(refresh: true);
  }

  void _marcarTodasLeidas() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Marcar Todas como Leídas'),
        content: const Text(
          '¿Deseas marcar todas las notificaciones como leídas?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<NotificacionCubit>().marcarTodasLeidas();
            },
            child: const Text('Marcar Todas'),
          ),
        ],
      ),
    );
  }

  void _handleNotificacionTap(dynamic notificacion) async {
    // Marcar como leída si no lo está
    if (!notificacion.leida) {
      context.read<NotificacionCubit>().marcarLeida(notificacion.id);
    }

    // Navegar según el tipo de notificación
    if (notificacion.ticketId != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => getIt<TicketCubit>(),
            child: TicketDetailScreen(ticketId: notificacion.ticketId!),
          ),
        ),
      );
    } else if (notificacion.equipoId != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BlocProvider(
            create: (context) => getIt<EquipoCubit>(),
            child: EquipoDetailScreen(equipoId: notificacion.equipoId!),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificaciones'),
        actions: [
          // Filtro solo no leídas
          IconButton(
            icon: Icon(
              _soloNoLeidas
                  ? Icons.filter_list
                  : Icons.filter_list_outlined,
            ),
            onPressed: _toggleFiltro,
            tooltip: _soloNoLeidas
                ? 'Mostrar todas'
                : 'Solo no leídas',
          ),

          // Marcar todas como leídas
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: _marcarTodasLeidas,
            tooltip: 'Marcar todas como leídas',
          ),
        ],
      ),
      body: BlocConsumer<NotificacionCubit, NotificacionState>(
        listener: (context, state) {
          if (state is NotificacionActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.successColor,
              ),
            );
          } else if (state is NotificacionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
        },
        builder: (context, state) {
          return Column(
            children: [
              // Banner de filtro activo
              if (_soloNoLeidas)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  color: AppTheme.infoColor.withOpacity(0.1),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.filter_list,
                        size: 18,
                        color: AppTheme.infoColor,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Mostrando solo notificaciones no leídas',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppTheme.infoColor,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                          color: AppTheme.infoColor,
                        ),
                        onPressed: _toggleFiltro,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

              // Contador de no leídas
              if (state is NotificacionesLoaded && state.conteoNoLeidas > 0)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  color: AppTheme.primaryColor.withOpacity(0.05),
                  child: Text(
                    '${state.conteoNoLeidas} notificación${state.conteoNoLeidas > 1 ? "es" : ""} sin leer',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              // Lista de notificaciones
              Expanded(
                child: _buildContent(state),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(NotificacionState state) {
    if (state is NotificacionLoading) {
      return const LoadingList(itemCount: 8);
    }

    if (state is NotificacionesLoaded) {
      if (state.notificaciones.items.isEmpty) {
        return EmptyState(
          icon: Icons.notifications_none_outlined,
          title: _soloNoLeidas
              ? 'No hay notificaciones sin leer'
              : 'No hay notificaciones',
          message: _soloNoLeidas
              ? 'Todas tus notificaciones están al día'
              : 'Cuando recibas notificaciones, aparecerán aquí',
        );
      }

      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: state.notificaciones.items.length +
              (state.isLoadingMore ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == state.notificaciones.items.length) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            final notificacion = state.notificaciones.items[index];
            return NotificacionCard(
              notificacion: notificacion,
              onTap: () => _handleNotificacionTap(notificacion),
              onDismiss: () {
                context
                    .read<NotificacionCubit>()
                    .deleteNotificacion(notificacion.id);
              },
            );
          },
        ),
      );
    }

    return EmptyState(
      icon: Icons.error_outline,
      title: 'Error al cargar notificaciones',
      message: 'Por favor, intenta nuevamente',
      actionLabel: 'Reintentar',
      onAction: () => _loadNotificaciones(refresh: true),
    );
  }
}
