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
import '../../../config/theme.dart';
import '../../../core/di/injection.dart';
import '../../../core/utils/responsive.dart';
import '../tickets/tickets_list_screen.dart';
import '../tickets/ticket_form_screen.dart';
import '../equipos/equipos_list_screen.dart';
import '../equipos/equipo_form_screen.dart';
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
  late final DashboardCubit _dashboardCubit;
  String _currentPage = 'Dashboard';

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

  void _navigateToPage(String page) {
    setState(() {
      _currentPage = page;
    });
    Navigator.pop(context); // Cerrar el drawer
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state is Authenticated ? state.user : null;
        final isAdmin = state is Authenticated &&
            state.user.rol == RolUsuario.administrador;

        return Scaffold(
          appBar: AppBar(
            title: Text(_currentPage),
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
            ],
          ),
          drawer: _buildDrawer(user, isAdmin),
          body: _buildCurrentPage(user),
        );
      },
    );
  }

  Widget _buildDrawer(dynamic user, bool isAdmin) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.accentColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            accountName: Text(
              user?.nombreCompleto ?? 'Usuario',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(user?.email ?? ''),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                (user?.nombreCompleto ?? 'U')[0].toUpperCase(),
                style: const TextStyle(
                  fontSize: 32,
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Navegación Principal
          _buildDrawerHeader('NAVEGACIÓN'),
          _buildDrawerItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
            isSelected: _currentPage == 'Dashboard',
            onTap: () => _navigateToPage('Dashboard'),
          ),
          _buildDrawerItem(
            icon: Icons.confirmation_number,
            title: 'Mis Tickets',
            isSelected: _currentPage == 'Mis Tickets',
            onTap: () => _navigateToPage('Mis Tickets'),
          ),
          _buildDrawerItem(
            icon: Icons.devices,
            title: 'Mis Equipos',
            isSelected: _currentPage == 'Mis Equipos',
            onTap: () => _navigateToPage('Mis Equipos'),
          ),
          _buildDrawerItem(
            icon: Icons.person,
            title: 'Perfil',
            isSelected: _currentPage == 'Perfil',
            onTap: () => _navigateToPage('Perfil'),
          ),

          const Divider(),

          // Acciones Rápidas
          _buildDrawerHeader('ACCIONES'),
          _buildDrawerItem(
            icon: Icons.add_circle,
            title: 'Nuevo Ticket',
            onTap: () async {
              Navigator.pop(context);
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
          _buildDrawerItem(
            icon: Icons.qr_code_scanner,
            title: 'Escanear QR',
            onTap: () async {
              Navigator.pop(context);
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

          // Módulos Administrativos
          if (isAdmin) ...[
            const Divider(),
            _buildDrawerHeader('ADMINISTRACIÓN'),
            _buildDrawerItem(
              icon: Icons.people,
              title: 'Usuarios',
              onTap: () async {
                Navigator.pop(context);
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
            _buildDrawerItem(
              icon: Icons.business,
              title: 'Departamentos',
              onTap: () async {
                Navigator.pop(context);
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
            _buildDrawerItem(
              icon: Icons.category,
              title: 'Categorías',
              onTap: () async {
                Navigator.pop(context);
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
            _buildDrawerItem(
              icon: Icons.admin_panel_settings,
              title: 'Roles',
              onTap: () async {
                Navigator.pop(context);
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
            _buildDrawerItem(
              icon: Icons.security,
              title: 'Permisos',
              onTap: () async {
                Navigator.pop(context);
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
          ],

          const Divider(),

          _buildDrawerItem(
            icon: Icons.logout,
            title: 'Cerrar Sesión',
            iconColor: AppTheme.errorColor,
            onTap: () {
              context.read<AuthCubit>().logout();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isSelected = false,
    Color? iconColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? AppTheme.primaryColor
            : (iconColor ?? Colors.grey[700]),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppTheme.primaryColor : null,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppTheme.primaryColor.withOpacity(0.1),
      onTap: onTap,
    );
  }

  Widget _buildCurrentPage(dynamic user) {
    switch (_currentPage) {
      case 'Dashboard':
        return BlocProvider.value(
          value: _dashboardCubit,
          child: _buildDashboard(user),
        );
      case 'Mis Tickets':
        return BlocProvider(
          create: (context) => getIt<TicketCubit>(),
          child: const TicketsListScreen(mode: TicketListMode.myTickets),
        );
      case 'Mis Equipos':
        return BlocProvider(
          create: (context) => getIt<EquipoCubit>(),
          child: const EquiposListScreen(mode: EquipoListMode.myEquipos),
        );
      case 'Perfil':
        return BlocProvider.value(
          value: context.read<AuthCubit>(),
          child: const ProfileScreen(),
        );
      default:
        return BlocProvider.value(
          value: _dashboardCubit,
          child: _buildDashboard(user),
        );
    }
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

}
