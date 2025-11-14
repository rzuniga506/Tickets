import 'package:get_it/get_it.dart';
import '../../core/api/api_client.dart';
import '../../core/storage/secure_storage.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/ticket_service.dart';
import '../../data/services/equipo_service.dart';
import '../../data/services/notificacion_service.dart';
import '../../data/services/usuario_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/ticket_repository.dart';
import '../../data/repositories/equipo_repository.dart';
import '../../data/repositories/notificacion_repository.dart';
import '../../data/repositories/usuario_repository.dart';
import '../../logic/auth/auth_cubit.dart';
import '../../logic/tickets/ticket_cubit.dart';
import '../../logic/equipos/equipo_cubit.dart';
import '../../logic/notificaciones/notificacion_cubit.dart';

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

  // Repositories
  getIt.registerLazySingleton(() => AuthRepository(getIt(), getIt()));
  getIt.registerLazySingleton(() => TicketRepository(getIt()));
  getIt.registerLazySingleton(() => EquipoRepository(getIt()));
  getIt.registerLazySingleton(() => NotificacionRepository(getIt()));
  getIt.registerLazySingleton(() => UsuarioRepository(getIt()));

  // Cubits
  getIt.registerFactory(() => AuthCubit(getIt()));
  getIt.registerFactory(() => TicketCubit(getIt()));
  getIt.registerFactory(() => EquipoCubit(getIt()));
  getIt.registerFactory(() => NotificacionCubit(getIt()));
}
