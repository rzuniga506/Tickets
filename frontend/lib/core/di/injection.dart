import 'package:get_it/get_it.dart';
import '../../core/api/api_client.dart';
import '../../core/storage/secure_storage.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/ticket_service.dart';
import '../../data/services/equipo_service.dart';
import '../../data/services/notificacion_service.dart';
import '../../data/services/usuario_service.dart';
import '../../data/services/dashboard_service.dart';
import '../../data/services/comentario_service.dart';
import '../../data/services/adjunto_service.dart';
import '../../data/services/categoria_service.dart';
import '../../data/services/historial_estado_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/ticket_repository.dart';
import '../../data/repositories/equipo_repository.dart';
import '../../data/repositories/notificacion_repository.dart';
import '../../data/repositories/usuario_repository.dart';
import '../../data/repositories/dashboard_repository.dart';
import '../../data/repositories/comentario_repository.dart';
import '../../data/repositories/adjunto_repository.dart';
import '../../data/repositories/categoria_repository.dart';
import '../../data/repositories/historial_estado_repository.dart';
import '../../logic/auth/auth_cubit.dart';
import '../../logic/tickets/ticket_cubit.dart';
import '../../logic/equipos/equipo_cubit.dart';
import '../../logic/notificaciones/notificacion_cubit.dart';
import '../../logic/dashboard/dashboard_cubit.dart';
import '../../logic/usuarios/usuario_cubit.dart';
import '../../logic/comentarios/comentario_cubit.dart';
import '../../logic/adjuntos/adjunto_cubit.dart';
import '../../logic/categorias/categoria_cubit.dart';
import '../../logic/historial_estados/historial_estado_cubit.dart';

final getIt = GetIt.instance;

/// Configurar dependency injection
Future<void> setupDependencies() async {
  // Storage
  getIt.registerLazySingleton(() => SecureStorage());

  // API Client
  getIt.registerLazySingleton(() => ApiClient(getIt()));

  // Services
  getIt.registerLazySingleton(() => AuthService(getIt()));
  getIt.registerLazySingleton(() => TicketService(getIt()));
  getIt.registerLazySingleton(() => EquipoService(getIt()));
  getIt.registerLazySingleton(() => NotificacionService(getIt()));
  getIt.registerLazySingleton(() => UsuarioService(getIt()));
  getIt.registerLazySingleton(() => DashboardService(getIt()));
  getIt.registerLazySingleton(() => ComentarioService(getIt()));
  getIt.registerLazySingleton(() => AdjuntoService(getIt()));
  getIt.registerLazySingleton(() => CategoriaService(getIt()));
  getIt.registerLazySingleton(() => HistorialEstadoService(getIt()));

  // Repositories
  getIt.registerLazySingleton(() => AuthRepository(getIt(), getIt()));
  getIt.registerLazySingleton(() => TicketRepository(getIt()));
  getIt.registerLazySingleton(() => EquipoRepository(getIt()));
  getIt.registerLazySingleton(() => NotificacionRepository(getIt()));
  getIt.registerLazySingleton(() => UsuarioRepository(getIt()));
  getIt.registerLazySingleton(() => DashboardRepository(getIt()));
  getIt.registerLazySingleton(() => ComentarioRepository(getIt()));
  getIt.registerLazySingleton(() => AdjuntoRepository(getIt()));
  getIt.registerLazySingleton(() => CategoriaRepository(getIt()));
  getIt.registerLazySingleton(() => HistorialEstadoRepository(getIt()));

  // Cubits
  getIt.registerFactory(() => AuthCubit(getIt()));
  getIt.registerFactory(() => TicketCubit(getIt()));
  getIt.registerFactory(() => EquipoCubit(getIt()));
  getIt.registerFactory(() => NotificacionCubit(getIt()));
  getIt.registerFactory(() => DashboardCubit(getIt()));
  getIt.registerFactory(() => UsuarioCubit(getIt()));
  getIt.registerFactory(() => ComentarioCubit(getIt()));
  getIt.registerFactory(() => AdjuntoCubit(getIt()));
  getIt.registerFactory(() => CategoriaCubit(getIt()));
  getIt.registerFactory(() => HistorialEstadoCubit(getIt()));
}
