import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';

abstract class AdminRemoteDatasource {
  Future<void> createUser({
    required String fullName,
    required String email,
    required String password,
    required String role,
  });
}

class AdminRemoteDatasourceImpl implements AdminRemoteDatasource {
  final ApiClient apiClient;
  AdminRemoteDatasourceImpl(this.apiClient);

  @override
  Future<void> createUser({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    await apiClient.post(ApiConstants.register, {
      'fullName': fullName,
      'email': email,
      'password': password,
      'role': role,
    });
  }
}
