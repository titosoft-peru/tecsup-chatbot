import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_response_model.dart';

abstract class AuthRemoteDatasource {
  Future<AuthResponseModel> login(String email, String password);
  Future<void> logout(String refreshToken);
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final ApiClient apiClient;
  AuthRemoteDatasourceImpl(this.apiClient);

  @override
  Future<AuthResponseModel> login(String email, String password) async {
    final data = await apiClient.post(
      ApiConstants.login,
      {'email': email, 'password': password},
    );
    return AuthResponseModel.fromJson(data);
  }

  @override
  Future<void> logout(String refreshToken) async {
    await apiClient.post(
      ApiConstants.logout,
      {'refresh_token': refreshToken},
    );
  }
}
