import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../logic/tickets/ticket_cubit.dart';
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
import '../tickets/ticket_form_screen.dart';
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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late final DashboardCubit _dashboardCubit;

  @override
  void initState() {
    super.initState();
    _dashboardCubit = getIt<DashboardCubit>();

    // Cargar contador de notificaciones y estadísticas al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificacionCubit>().getConteoNoLeidas();
      _dashboardCubit.loadEstadisticas();
    });
  }

  @override
  void dispose() {
    _dashboardCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state is Authenticated ? state.user : null;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Tickets TI'),
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
                  // TODO: Navegar a perfil
                },
              ),
            ],
          ),
          body: IndexedStack(
            index: _currentIndex,
            children: [
              BlocProvider.value(
                value: _dashboardCubit,
                child: _buildDashboard(user),
              ),
              BlocProvider(
                create: (context) => getIt<TicketCubit>(),
                child: const TicketsListScreen(mode: TicketListMode.myTickets),
              ),
              BlocProvider(
                create: (context) => getIt<EquipoCubit>(),
                child: const EquiposListScreen(mode: EquipoListMode.myEquipos),
              ),
              BlocProvider.value(
                value: context.read<AuthCubit>(),
                child: const ProfileScreen(),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Inicio',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.confirmation_number_outlined),
                activeIcon: Icon(Icons.confirmation_number),
                label: 'Tickets',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.devices_outlined),
                activeIcon: Icon(Icons.devices),
                label: 'Equipos',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
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

                // Mostrar loading o stats
                if (state is DashboardLoading) ...[
                  const LoadingList(itemCount: 4),
                ] else if (state is DashboardLoaded || state is DashboardRefreshing) ...[
                  _buildStatsCards(state is DashboardLoaded
                      ? state.stats
                      : (state as DashboardRefreshing).previousStats),
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
                  _buildStatsCards(null),
                ],

                const SizedBox(height: 24),

                // Acciones rápidas
                Text(
                  'Acciones Rápidas',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                BlocBuilder<AuthCubit, AuthState>(
                  builder: (context, authState) {
                    final isAdmin = authState is Authenticated &&
                        authState.user.rol == RolUsuario.administrador;

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = Breakpoints.getQuickActionColumns(context);

                        return GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: columns,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: (!constraints.maxWidth.isFinite || constraints.maxWidth <= 0)
                              ? 1.0
                              : (constraints.maxWidth >= Breakpoints.desktop ? 1.3 : 1.1),
                          children: [
                        _buildQuickActionCard(
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
                          },
                        ),
                        _buildQuickActionCard(
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
                        _buildQuickActionCard(
                          title: 'Mis Equipos',
                          icon: Icons.devices,
                          color: AppTheme.infoColor,
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                  create: (context) => getIt<EquipoCubit>(),
                                  child: const EquiposListScreen(mode: EquipoListMode.myEquipos),
                                ),
                              ),
                            );
                          },
                        ),
                        if (isAdmin) ...[
                          _buildQuickActionCard(
                            title: 'Inventario',
                            icon: Icons.inventory_2,
                            color: const Color(0xFF06B6D4),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider(
                                    create: (context) => getIt<EquipoCubit>(),
                                    child: const EquiposListScreen(mode: EquipoListMode.all),
                                  ),
                                ),
                              );
                            },
                          ),
                          _buildQuickActionCard(
                            title: 'Usuarios',
                            icon: Icons.people,
                            color: const Color(0xFFEF4444),
                            onTap: () async {
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
                            },
                          ),
                          _buildQuickActionCard(
                            title: 'Departamentos',
                            icon: Icons.business,
                            color: const Color(0xFF8B5CF6),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider(
                                    create: (context) => getIt<DepartamentoCubit>(),
                                    child: const DepartamentosListScreen(),
                                  ),
                                ),
                              );
                            },
                          ),
                          _buildQuickActionCard(
                            title: 'Categorías',
                            icon: Icons.category,
                            color: const Color(0xFF10B981),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider(
                                    create: (context) => getIt<CategoriaCubit>(),
                                    child: const CategoriasListScreen(),
                                  ),
                                ),
                              );
                            },
                          ),
                          _buildQuickActionCard(
                            title: 'Roles',
                            icon: Icons.admin_panel_settings,
                            color: const Color(0xFFF59E0B),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider(
                                    create: (context) => getIt<RolCubit>(),
                                    child: const RolesListScreen(),
                                  ),
                                ),
                              );
                            },
                          ),
                          _buildQuickActionCard(
                            title: 'Permisos',
                            icon: Icons.security,
                            color: const Color(0xFF14B8A6),
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BlocProvider(
                                    create: (context) => getIt<PermisoCubit>(),
                                    child: const PermisosViewScreen(),
                                  ),
                                ),
                              );
                            },
                          ),
                        ] else
                          _buildQuickActionCard(
                            title: 'Soporte',
                            icon: Icons.help_outline,
                            color: AppTheme.successColor,
                            onTap: () {
                              // TODO: Navegar a ayuda
                            },
                          ),
                      ],
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsCards(dynamic stats) {
    final misTickets = stats?.misTickets ?? 0;
    final pendientes = stats?.ticketsPendientes ?? 0;
    final resueltos = stats?.ticketsResueltos ?? 0;
    final misEquipos = stats?.misEquipos ?? 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        // En desktop: 4 columnas horizontales
        // En tablet: 2x2 grid
        // En móvil: 2x2 grid
        if (constraints.maxWidth >= Breakpoints.desktop) {
          return Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Mis Tickets',
                  value: '$misTickets',
                  icon: Icons.confirmation_number,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Pendientes',
                  value: '$pendientes',
                  icon: Icons.pending_actions,
                  color: AppTheme.warningColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Resueltos',
                  value: '$resueltos',
                  icon: Icons.check_circle,
                  color: AppTheme.successColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Mis Equipos',
                  value: '$misEquipos',
                  icon: Icons.devices,
                  color: AppTheme.infoColor,
                ),
              ),
            ],
          );
        } else {
          // Tablet y móvil: 2x2 grid
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Mis Tickets',
                      value: '$misTickets',
                      icon: Icons.confirmation_number,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Pendientes',
                      value: '$pendientes',
                      icon: Icons.pending_actions,
                      color: AppTheme.warningColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      title: 'Resueltos',
                      value: '$resueltos',
                      icon: Icons.check_circle,
                      color: AppTheme.successColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      title: 'Mis Equipos',
                      value: '$misEquipos',
                      icon: Icons.devices,
                      color: AppTheme.infoColor,
                    ),
                  ),
                ],
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
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
}
