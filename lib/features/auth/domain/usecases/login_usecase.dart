import '../entities/auth_token.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  Future<AuthToken> call(String email, String password) {
    return repository.login(email, password);
  }
}
