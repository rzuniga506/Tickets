import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/models/auth/login_request.dart';
import 'auth_state.dart';

/// Cubit de autenticación
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthInitial());

  /// Verificar estado de autenticación
  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final isAuthenticated = await _authRepository.isAuthenticated();
      if (isAuthenticated) {
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          emit(Authenticated(user));
        } else {
          emit(Unauthenticated());
        }
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  /// Login
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final request = LoginRequest(email: email, password: password);
      final authResponse = await _authRepository.login(request);
      emit(Authenticated(authResponse.usuario));
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(Unauthenticated());
    }
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _authRepository.logout();
    } catch (e) {
      // Ignorar errores
    } finally {
      emit(Unauthenticated());
    }
  }

  /// Actualizar perfil
  Future<void> refreshProfile() async {
    try {
      final user = await _authRepository.getProfile();
      emit(Authenticated(user));
    } catch (e) {
      // Mantener estado actual si falla
    }
  }
}
