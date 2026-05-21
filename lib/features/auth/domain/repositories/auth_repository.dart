import '../entities/auth_token.dart';

abstract class AuthRepository {
  Future<AuthToken> login(String email, String password);
  Future<void> logout(String refreshToken);
  Future<AuthToken?> getSavedToken();
  Future<void> saveToken(AuthToken token);
  Future<void> clearToken();
}
