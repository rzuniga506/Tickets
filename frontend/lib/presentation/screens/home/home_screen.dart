import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../logic/tickets/ticket_cubit.dart';
import '../../../logic/equipos/equipo_cubit.dart';
import '../../../config/theme.dart';
import '../../../core/di/injection.dart';
import '../tickets/tickets_list_screen.dart';
import '../tickets/ticket_form_screen.dart';
import '../equipos/equipos_list_screen.dart';
import '../equipos/equipo_form_screen.dart';
import '../equipos/qr_scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        final user = state is Authenticated ? state.user : null;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Tickets TI'),
            actions: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  // TODO: Navegar a notificaciones
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
              _buildDashboard(user),
              BlocProvider(
                create: (context) => getIt<TicketCubit>(),
                child: const TicketsListScreen(mode: TicketListMode.myTickets),
              ),
              BlocProvider(
                create: (context) => getIt<EquipoCubit>(),
                child: const EquiposListScreen(mode: EquipoListMode.myEquipos),
              ),
              _buildPerfilPlaceholder(user),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bienvenida
          Text(
            'Bienvenido, ${user?.nombreCompleto ?? "Usuario"}',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 24),

          // Tarjetas de resumen
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Mis Tickets',
                  value: '0',
                  icon: Icons.confirmation_number,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Pendientes',
                  value: '0',
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
                  value: '0',
                  icon: Icons.check_circle,
                  color: AppTheme.successColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                  title: 'Mis Equipos',
                  value: '0',
                  icon: Icons.devices,
                  color: AppTheme.infoColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Acciones rápidas
          Text(
            'Acciones Rápidas',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
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
              _buildQuickActionCard(
                title: 'Soporte',
                icon: Icons.help_outline,
                color: AppTheme.successColor,
                onTap: () {
                  // TODO: Navegar a ayuda
                },
              ),
            ],
          ),
        ],
      ),
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

  Widget _buildPerfilPlaceholder(dynamic user) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person, size: 64, color: AppTheme.greyDark),
          const SizedBox(height: 16),
          Text('Perfil de ${user?.nombreCompleto ?? "Usuario"}'),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.read<AuthCubit>().logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar Sesión'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
          ),
        ],
      ),
    );
  }
}
