abstract class AdminRepository {
  Future<void> createUser({
    required String fullName,
    required String email,
    required String password,
    required String role,
  });
}
