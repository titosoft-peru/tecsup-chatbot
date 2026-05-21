import '../repositories/admin_repository.dart';

class CreateUserUseCase {
  final AdminRepository repository;
  CreateUserUseCase(this.repository);

  Future<void> call({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) {
    return repository.createUser(
      fullName: fullName,
      email: email,
      password: password,
      role: role,
    );
  }
}
