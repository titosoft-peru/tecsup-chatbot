import 'package:flutter/foundation.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final AuthRepository _repository;

  AuthStatus _status = AuthStatus.initial;
  AuthToken? _token;
  String? _errorMessage;

  AuthProvider({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required AuthRepository repository,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _repository = repository;

  AuthStatus get status => _status;
  AuthToken? get token => _token;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.loading;

  Future<void> checkSavedSession() async {
    final saved = await _repository.getSavedToken();
    if (saved != null) {
      _token = saved;
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _token = await _loginUseCase(email, password);
      _status = AuthStatus.authenticated;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }
    notifyListeners();
  }

  Future<void> logout() async {
    if (_token == null) return;
    try {
      await _logoutUseCase(_token!.refreshToken);
    } catch (_) {
      // Forzamos logout local aunque falle el servidor
    } finally {
      await _clearSession();
    }
  }

  // Limpia la sesión localmente sin llamar al servidor.
  // Usar cuando el token ya es inválido (expirado, revocado).
  Future<void> forceLogout() async {
    if (_token == null) return;
    await _clearSession();
  }

  Future<void> _clearSession() async {
    _token = null;
    _status = AuthStatus.unauthenticated;
    await _repository.clearToken();
    notifyListeners();
  }
}
