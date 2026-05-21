import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDatasource remoteDatasource;
  AdminRepositoryImpl(this.remoteDatasource);

  @override
  Future<void> createUser({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) {
    return remoteDatasource.createUser(
      fullName: fullName,
      email: email,
      password: password,
      role: role,
    );
  }
}
