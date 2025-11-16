import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../logic/tickets/ticket_cubit.dart';
import '../../../logic/tickets/ticket_state.dart';
import '../../../data/models/ticket/ticket_model.dart';
import '../../../logic/equipos/equipo_cubit.dart';
import '../../../logic/notificaciones/notificacion_cubit.dart';
import '../../../logic/notificaciones/notificacion_state.dart';
import '../../../logic/dashboard/dashboard_cubit.dart';
import '../../../logic/dashboard/dashboard_state.dart';
import '../../../data/models/user/user_model.dart';
import '../../../config/theme.dart';
import '../../../core/di/injection.dart';
import '../../../core/utils/responsive.dart';
import '../tickets/tickets_list_screen.dart';
import '../tickets/tickets_kanban_screen.dart';
import '../tickets/tickets_kanban_estado_screen.dart';
import '../tickets/ticket_form_screen.dart';
import '../tickets/ticket_detail_screen.dart';
import '../equipos/equipos_list_screen.dart';
import '../equipos/qr_scanner_screen.dart';
import '../notificaciones/notificaciones_list_screen.dart';
import '../usuarios/usuarios_list_screen.dart';
import '../departamentos/departamentos_list_screen.dart';
import '../categorias/categorias_list_screen.dart';
import '../roles/roles_list_screen.dart';
import '../permisos/permisos_view_screen.dart';
import '../../widgets/notification_badge.dart';
import '../../widgets/loading_card.dart';
import '../../../logic/usuarios/usuario_cubit.dart';
import '../../../logic/departamentos/departamento_cubit.dart';
import '../../../logic/categorias/categoria_cubit.dart';
import '../../../logic/roles/rol_cubit.dart';
import '../../../logic/permisos/permiso_cubit.dart';
import '../usuarios/profile_screen.dart';
import '../../widgets/side_navigation_panel.dart';
import '../../widgets/dashboard_metric_card.dart';
import '../../widgets/mini_kanban_widget.dart';
import '../../widgets/activity_timeline_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final DashboardCubit _dashboardCubit;
  late final TicketCubit _ticketCubit;
  bool _isPanelCollapsed = false;
  Timer? _notificationRefreshTimer;
  int _previousNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    _dashboardCubit = getIt<DashboardCubit>();
    _ticketCubit = getIt<TicketCubit>();

    // Cargar contador de notificaciones, estadísticas y mis tickets al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificacionCubit>().getConteoNoLeidas();
      _dashboardCubit.loadEstadisticas();
      // Cargar mis tickets recientes (últimos 50 para mostrar en kanban y actividad)
      _ticketCubit.getTickets(pageSize: 50);
    });

    // Configurar auto-refresh de notificaciones cada 30 segundos
    _notificationRefreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) {
        if (mounted) {
          context.read<NotificacionCubit>().getConteoNoLeidas();
        }
      },
    );
  }

  void _togglePanel() {
    setState(() {
      _isPanelCollapsed = !_isPanelCollapsed;
    });
  }

  void _showNewNotificationsSnackBar(int newCount) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.notifications_active, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                newCount == 1
                    ? 'Tienes 1 notificación nueva'
                    : 'Tienes $newCount notificaciones nuevas',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryColor,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Ver',
          textColor: Colors.white,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider.value(
                  value: context.read<NotificacionCubit>(),
                  child: const NotificacionesListScreen(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notificationRefreshTimer?.cancel();
    _dashboardCubit.close();
    _ticketCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state is Authenticated ? state.user : null;

        return BlocListener<NotificacionCubit, NotificacionState>(
          listener: (context, notifState) {
            int currentCount = 0;
            if (notifState is NotificacionesLoaded) {
              currentCount = notifState.conteoNoLeidas;
            } else if (notifState is ConteoNoLeidasLoaded) {
              currentCount = notifState.conteo;
            }

            // Mostrar SnackBar solo si hay nuevas notificaciones (aumento en el contador)
            if (currentCount > _previousNotificationCount && _previousNotificationCount > 0) {
              final newNotifications = currentCount - _previousNotificationCount;
              _showNewNotificationsSnackBar(newNotifications);
            }

            // Actualizar contador anterior
            if (currentCount > 0 || _previousNotificationCount > 0) {
              _previousNotificationCount = currentCount;
            }
          },
          child: Scaffold(
            appBar: AppBar(
            title: const Text('Tickets TI'),
            leading: IconButton(
              icon: Icon(_isPanelCollapsed ? Icons.menu : Icons.menu_open),
              tooltip: _isPanelCollapsed ? 'Mostrar menú' : 'Ocultar menú',
              onPressed: _togglePanel,
            ),
            actions: [
              BlocBuilder<NotificacionCubit, NotificacionState>(
                builder: (context, notifState) {
                  int conteo = 0;
                  if (notifState is NotificacionesLoaded) {
                    conteo = notifState.conteoNoLeidas;
                  } else if (notifState is ConteoNoLeidasLoaded) {
                    conteo = notifState.conteo;
                  }

                  return IconButton(
                    icon: NotificationBadge(
                      count: conteo,
                      child: const Icon(Icons.notifications_outlined),
                    ),
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider.value(
                            value: context.read<NotificacionCubit>(),
                            child: const NotificacionesListScreen(),
                          ),
                        ),
                      );
                      // Actualizar contador al regresar
                      if (mounted) {
                        context.read<NotificacionCubit>().actualizarContador();
                      }
                    },
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.account_circle_outlined),
                onPressed: () {
                  _handleNavigation(context, 'profile');
                },
              ),
            ],
          ),
          body: Row(
            children: [
              // Side Navigation Panel - IZQUIERDA
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: _isPanelCollapsed ? 0 : 280,
                child: _isPanelCollapsed
                    ? null
                    : SideNavigationPanel(
                        onNavigate: (route) => _handleNavigation(context, route),
                      ),
              ),

              // Main Content - Dashboard
              Expanded(
                child: MultiBlocProvider(
                  providers: [
                    BlocProvider.value(value: _dashboardCubit),
                    BlocProvider.value(value: _ticketCubit),
                  ],
                  child: _buildDashboard(user),
                ),
              ),
            ],
          ),
          ),
        );
      },
    );
  }

  Widget _buildDashboard(dynamic user) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        return RefreshIndicator(
          onRefresh: () async {
            await _dashboardCubit.refresh();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(Breakpoints.getHorizontalPadding(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bienvenida
                Text(
                  'Bienvenido, ${user?.nombreCompleto ?? "Usuario"}',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),

                // Mostrar loading o stats con nuevo diseño
                if (state is DashboardLoading) ...[
                  const LoadingList(itemCount: 4),
                ] else if (state is DashboardLoaded || state is DashboardRefreshing) ...[
                  _buildNewDashboardContent(
                    stats: state is DashboardLoaded
                        ? state.stats
                        : (state as DashboardRefreshing).previousStats,
                    user: user,
                  ),
                ] else if (state is DashboardError) ...[
                  Center(
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: AppTheme.errorColor),
                        const SizedBox(height: 16),
                        Text('Error al cargar estadísticas',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8),
                        Text(state.message,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => _dashboardCubit.loadEstadisticas(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Estado inicial - mostrar valores por defecto
                  _buildNewDashboardContent(stats: null, user: user),
                ],

                const SizedBox(height: 24),

                // Acciones rápidas (reducidas a 3)
                Text(
                  'Acciones Rápidas',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                // Solo 3 acciones rápidas más importantes
                Row(
                  children: [
                    Expanded(
                      child: _buildQuickActionCard(
                        title: 'Nuevo Ticket',
                        icon: Icons.add_circle_outline,
                        color: AppTheme.primaryColor,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider(
                                create: (context) => getIt<TicketCubit>(),
                                child: const TicketFormScreen(),
                              ),
                            ),
                          );
                          _dashboardCubit.refresh();
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildQuickActionCard(
                        title: 'Escanear QR',
                        icon: Icons.qr_code_scanner,
                        color: AppTheme.accentColor,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlocProvider(
                                create: (context) => getIt<EquipoCubit>(),
                                child: const QRScannerScreen(),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: BlocBuilder<AuthCubit, AuthState>(
                        builder: (context, authState) {
                          final isAdmin = authState is Authenticated &&
                              authState.user.rol == RolUsuario.administrador;

                          return _buildQuickActionCard(
                            title: isAdmin ? 'Inventario' : 'Mis Equipos',
                            icon: isAdmin ? Icons.inventory_2 : Icons.devices,
                            color: AppTheme.infoColor,
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider(
                                    create: (context) => getIt<EquipoCubit>(),
                                    child: EquiposListScreen(
                                        mode: isAdmin
                                            ? EquipoListMode.all
                                            : EquipoListMode.myEquipos),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNewDashboardContent({
    required dynamic stats,
    required dynamic user,
  }) {
    final misTickets = stats?.misTickets ?? 0;
    final ticketsAltaPrioridad = stats?.ticketsAltaPrioridad ?? 0;
    final ticketsPendientes = stats?.ticketsPendientes ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Metric Cards Row
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= Breakpoints.desktop) {
              return Row(
                children: [
                  Expanded(
                    child: DashboardMetricCard(
                      title: 'Mis Tickets',
                      value: '$misTickets',
                      icon: Icons.confirmation_number,
                      color: AppTheme.primaryColor,
                      onTap: () => _handleNavigation(context, 'my-tickets'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DashboardMetricCard(
                      title: 'Alta Prioridad',
                      value: '$ticketsAltaPrioridad',
                      icon: Icons.priority_high,
                      color: AppTheme.errorColor,
                      subtitle: 'Requieren atención',
                      onTap: () => _handleNavigation(context, 'all-tickets'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DashboardMetricCard(
                      title: 'Pendientes',
                      value: '$ticketsPendientes',
                      icon: Icons.pending_actions,
                      color: AppTheme.warningColor,
                      subtitle: 'Sin asignar',
                      onTap: () => _handleNavigation(context, 'all-tickets'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DashboardMetricCard(
                      title: 'SLA Cumplimiento',
                      value: '${((stats?.ticketsResueltos ?? 0) > 0 ? ((stats?.ticketsResueltos ?? 0) * 100 / (stats?.totalTickets ?? 1)).toStringAsFixed(0) : 0)}%',
                      icon: Icons.timer,
                      color: AppTheme.successColor,
                      subtitle: 'Este mes',
                    ),
                  ),
                ],
              );
            } else {
              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DashboardMetricCard(
                          title: 'Mis Tickets',
                          value: '$misTickets',
                          icon: Icons.confirmation_number,
                          color: AppTheme.primaryColor,
                          onTap: () => _handleNavigation(context, 'my-tickets'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DashboardMetricCard(
                          title: 'Alta Prioridad',
                          value: '$ticketsAltaPrioridad',
                          icon: Icons.priority_high,
                          color: AppTheme.errorColor,
                          onTap: () => _handleNavigation(context, 'all-tickets'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DashboardMetricCard(
                          title: 'Pendientes',
                          value: '$ticketsPendientes',
                          icon: Icons.pending_actions,
                          color: AppTheme.warningColor,
                          onTap: () => _handleNavigation(context, 'all-tickets'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: DashboardMetricCard(
                          title: 'SLA %',
                          value: '${((stats?.ticketsResueltos ?? 0) > 0 ? ((stats?.ticketsResueltos ?? 0) * 100 / (stats?.totalTickets ?? 1)).toStringAsFixed(0) : 0)}%',
                          icon: Icons.timer,
                          color: AppTheme.successColor,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }
          },
        ),
        const SizedBox(height: 24),

        // Mini Kanban Widget
        BlocBuilder<TicketCubit, TicketState>(
          builder: (context, ticketState) {
            List<TicketModel> tickets = [];
            if (ticketState is TicketsLoaded) {
              tickets = ticketState.tickets.items;
            }

            return MiniKanbanWidget(
              tickets: tickets,
              onTicketTap: (ticketId) async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => getIt<TicketCubit>(),
                      child: TicketDetailScreen(ticketId: ticketId),
                    ),
                  ),
                );
                // Refresh after viewing detail
                if (mounted) {
                  _ticketCubit.getTickets(pageSize: 50);
                  _dashboardCubit.refresh();
                }
              },
            );
          },
        ),
        const SizedBox(height: 24),

        // Activity Timeline Widget
        BlocBuilder<TicketCubit, TicketState>(
          builder: (context, ticketState) {
            List<ActivityEvent> events = [];
            if (ticketState is TicketsLoaded) {
              // Create events from recent tickets (max 5)
              events = ticketState.tickets.items
                  .take(5)
                  .map((ticket) => ActivityEvent.fromTicket(ticket))
                  .toList();
            }

            return ActivityTimelineWidget(
              events: events,
              onEventTap: (ticketId) async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => getIt<TicketCubit>(),
                      child: TicketDetailScreen(ticketId: ticketId),
                    ),
                  ),
                );
                // Refresh after viewing detail
                if (mounted) {
                  _ticketCubit.getTickets(pageSize: 50);
                  _dashboardCubit.refresh();
                }
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 48),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Maneja la navegación desde el panel lateral
  Future<void> _handleNavigation(BuildContext context, String route) async {
    switch (route) {
      case 'my-tickets':
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => getIt<TicketCubit>(),
              child: const TicketsListScreen(mode: TicketListMode.myTickets),
            ),
          ),
        );
        break;

      case 'all-tickets':
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => getIt<TicketCubit>(),
              child: const TicketsListScreen(mode: TicketListMode.all),
            ),
          ),
        );
        break;

      case 'kanban-estado':
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => getIt<TicketCubit>(),
              child: const TicketsKanbanEstadoScreen(),
            ),
          ),
        );
        break;

      case 'kanban-tipo':
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => getIt<TicketCubit>(),
              child: const TicketsKanbanScreen(),
            ),
          ),
        );
        break;

      case 'new-ticket':
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => getIt<TicketCubit>(),
              child: const TicketFormScreen(),
            ),
          ),
        );
        _dashboardCubit.refresh();
        break;

      case 'my-equipos':
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => getIt<EquipoCubit>(),
              child: const EquiposListScreen(mode: EquipoListMode.myEquipos),
            ),
          ),
        );
        break;

      case 'inventario':
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => getIt<EquipoCubit>(),
              child: const EquiposListScreen(mode: EquipoListMode.all),
            ),
          ),
        );
        break;

      case 'qr-scanner':
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => getIt<EquipoCubit>(),
              child: const QRScannerScreen(),
            ),
          ),
        );
        break;

      case 'usuarios':
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => getIt<UsuarioCubit>(),
              child: const UsuariosListScreen(),
            ),
          ),
        );
        _dashboardCubit.refresh();
        break;

      case 'departamentos':
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => getIt<DepartamentoCubit>(),
              child: const DepartamentosListScreen(),
            ),
          ),
        );
        break;

      case 'categorias':
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => getIt<CategoriaCubit>(),
              child: const CategoriasListScreen(),
            ),
          ),
        );
        break;

      case 'roles':
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => getIt<RolCubit>(),
              child: const RolesListScreen(),
            ),
          ),
        );
        break;

      case 'permisos':
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider(
              create: (context) => getIt<PermisoCubit>(),
              child: const PermisosViewScreen(),
            ),
          ),
        );
        break;

      case 'profile':
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BlocProvider.value(
              value: context.read<AuthCubit>(),
              child: const ProfileScreen(),
            ),
          ),
        );
        break;
    }
  }
}
