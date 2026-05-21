import 'package:flutter/foundation.dart';
import '../../domain/usecases/create_user_usecase.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/network/api_client.dart';

enum AdminStatus { idle, loading, success, error }

class AdminProvider extends ChangeNotifier {
  final CreateUserUseCase _createUser;
  final ApiClient _apiClient;

  AdminStatus _status = AdminStatus.idle;
  String? _errorMessage;

  AdminProvider({
    required CreateUserUseCase createUser,
    required ApiClient apiClient,
  })  : _createUser = createUser,
        _apiClient = apiClient;

  AdminStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AdminStatus.loading;

  void updateAuth(AuthProvider auth) {
    _apiClient.setToken(auth.token?.accessToken);
  }

  Future<bool> createUser({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    _status = AdminStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _createUser(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
      );
      _status = AdminStatus.success;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AdminStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void reset() {
    _status = AdminStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}
