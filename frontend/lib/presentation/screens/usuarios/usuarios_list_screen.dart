import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/usuarios/usuario_cubit.dart';
import '../../../logic/usuarios/usuario_state.dart';
import '../../../logic/auth/auth_cubit.dart';
import '../../../logic/auth/auth_state.dart';
import '../../../data/models/user/user_model.dart';
import '../../../config/theme.dart';
import '../../../core/di/injection.dart';
import '../../../core/utils/responsive.dart';
import '../../widgets/usuario_card.dart';
import '../../widgets/loading_card.dart';
import '../../widgets/empty_state.dart';
import 'usuario_detail_screen.dart';
import 'usuario_form_screen.dart';

class UsuariosListScreen extends StatefulWidget {
  const UsuariosListScreen({super.key});

  @override
  State<UsuariosListScreen> createState() => _UsuariosListScreenState();
}

class _UsuariosListScreenState extends State<UsuariosListScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  int _currentPage = 1;
  final int _pageSize = 20;
  String? _searchTerm;
  bool? _activoFilter;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadUsuarios();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadUsuarios({bool refresh = false}) {
    if (refresh) {
      _currentPage = 1;
    }

    context.read<UsuarioCubit>().getUsuarios(
          pageNumber: _currentPage,
          pageSize: _pageSize,
          searchTerm: _searchTerm,
          activo: _activoFilter,
        );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<UsuarioCubit>().state;
      if (state is UsuariosLoaded && !state.isLoadingMore) {
        if (state.usuarios.hasMore) {
          _currentPage++;
          context.read<UsuarioCubit>().getUsuarios(
                pageNumber: _currentPage,
                pageSize: _pageSize,
                searchTerm: _searchTerm,
                activo: _activoFilter,
                loadMore: true,
              );
        }
      }
    }
  }

  Future<void> _onRefresh() async {
    _loadUsuarios(refresh: true);
    await Future.delayed(const Duration(seconds: 1));
  }

  void _onSearch(String value) {
    setState(() {
      _searchTerm = value.isEmpty ? null : value;
    });
    _loadUsuarios(refresh: true);
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Filtrar Usuarios'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: const Text('Todos'),
                  leading: Radio<bool?>(
                    value: null,
                    groupValue: _activoFilter,
                    onChanged: (value) {
                      setState(() {
                        _activoFilter = value;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Solo activos'),
                  leading: Radio<bool?>(
                    value: true,
                    groupValue: _activoFilter,
                    onChanged: (value) {
                      setState(() {
                        _activoFilter = value;
                      });
                    },
                  ),
                ),
                ListTile(
                  title: const Text('Solo inactivos'),
                  leading: Radio<bool?>(
                    value: false,
                    groupValue: _activoFilter,
                    onChanged: (value) {
                      setState(() {
                        _activoFilter = value;
                      });
                    },
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              this.setState(() {});
              _loadUsuarios(refresh: true);
            },
            child: const Text('Aplicar'),
          ),
        ],
      ),
    );
  }

  void _handleToggleActivo(UserModel usuario) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(usuario.activo ? 'Desactivar Usuario' : 'Activar Usuario'),
        content: Text(
          usuario.activo
              ? '¿Deseas desactivar a ${usuario.nombreCompleto}?'
              : '¿Deseas activar a ${usuario.nombreCompleto}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<UsuarioCubit>().toggleActivo(usuario.id, usuario.activo);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: usuario.activo
                  ? AppTheme.warningColor
                  : AppTheme.successColor,
            ),
            child: Text(usuario.activo ? 'Desactivar' : 'Activar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuarios'),
        actions: [
          IconButton(
            icon: Icon(
              _activoFilter != null
                  ? Icons.filter_list
                  : Icons.filter_list_outlined,
            ),
            onPressed: _showFilterDialog,
            tooltip: 'Filtrar',
          ),
        ],
      ),
      body: BlocConsumer<UsuarioCubit, UsuarioState>(
        listener: (context, state) {
          if (state is UsuarioActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppTheme.successColor,
              ),
            );
            // Recargar lista después de una acción exitosa
            _loadUsuarios(refresh: true);
          } else if (state is UsuarioError) {
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
              // Barra de búsqueda
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar por nombre o email...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchTerm != null
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onSearch('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    if (value.length >= 3 || value.isEmpty) {
                      _onSearch(value);
                    }
                  },
                ),
              ),

              // Banner de filtro activo
              if (_activoFilter != null)
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
                      Expanded(
                        child: Text(
                          'Mostrando solo usuarios ${_activoFilter! ? "activos" : "inactivos"}',
                          style: const TextStyle(
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
                        onPressed: () {
                          setState(() {
                            _activoFilter = null;
                          });
                          _loadUsuarios(refresh: true);
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),

              // Lista de usuarios
              Expanded(
                child: _buildContent(state),
              ),
            ],
          );
        },
      ),
      floatingActionButton: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, authState) {
          // Solo mostrar FAB si es admin
          if (authState is Authenticated &&
              authState.user.rol == RolUsuario.administrador) {
            return FloatingActionButton.extended(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => getIt<UsuarioCubit>(),
                      child: const UsuarioFormScreen(),
                    ),
                  ),
                );
                _loadUsuarios(refresh: true);
              },
              icon: const Icon(Icons.person_add),
              label: const Text('Nuevo Usuario'),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(UsuarioState state) {
    if (state is UsuarioLoading) {
      return const LoadingList(itemCount: 10);
    }

    if (state is UsuariosLoaded) {
      if (state.usuarios.items.isEmpty) {
        return EmptyState(
          icon: Icons.people_outline,
          title: _searchTerm != null
              ? 'No se encontraron usuarios'
              : 'No hay usuarios registrados',
          message: _searchTerm != null
              ? 'Intenta con otros términos de búsqueda'
              : 'Crea el primer usuario para comenzar',
        );
      }

      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // En desktop/tablet: Grid, en móvil: Lista
            if (constraints.maxWidth >= Breakpoints.tablet) {
              final columns = Breakpoints.getGridColumns(context);
              return GridView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(Breakpoints.getHorizontalPadding(context)),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: constraints.maxWidth >= Breakpoints.desktop ? 1.5 : 1.2,
                ),
                itemCount: state.usuarios.items.length +
                    (state.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.usuarios.items.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final usuario = state.usuarios.items[index];
                  return UsuarioCard(
                    usuario: usuario,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) => getIt<UsuarioCubit>(),
                            child: UsuarioDetailScreen(usuarioId: usuario.id),
                          ),
                        ),
                      );
                      _loadUsuarios(refresh: true);
                    },
                    onToggleActivo: () => _handleToggleActivo(usuario),
                  );
                },
              );
            } else {
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: state.usuarios.items.length +
                    (state.isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.usuarios.items.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final usuario = state.usuarios.items[index];
                  return UsuarioCard(
                    usuario: usuario,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) => getIt<UsuarioCubit>(),
                            child: UsuarioDetailScreen(usuarioId: usuario.id),
                          ),
                        ),
                      );
                      _loadUsuarios(refresh: true);
                    },
                    onToggleActivo: () => _handleToggleActivo(usuario),
                  );
                },
              );
            }
          },
        ),
      );
    }

    return EmptyState(
      icon: Icons.error_outline,
      title: 'Error al cargar usuarios',
      message: 'Por favor, intenta nuevamente',
      actionLabel: 'Reintentar',
      onAction: () => _loadUsuarios(refresh: true),
    );
  }
}
