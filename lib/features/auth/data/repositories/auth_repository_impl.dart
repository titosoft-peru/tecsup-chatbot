import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/auth_token.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_response_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;
  final SharedPreferences prefs;

  static const String _tokenKey = 'auth_token';

  AuthRepositoryImpl({
    required this.remoteDatasource,
    required this.prefs,
  });

  @override
  Future<AuthToken> login(String email, String password) async {
    final model = await remoteDatasource.login(email, password);
    await saveToken(model);
    return model;
  }

  @override
  Future<void> logout(String refreshToken) async {
    await remoteDatasource.logout(refreshToken);
    await clearToken();
  }

  @override
  Future<AuthToken?> getSavedToken() async {
    final raw = prefs.getString(_tokenKey);
    if (raw == null) return null;
    final map = Map<String, dynamic>.from(jsonDecode(raw) as Map);
    // fromJson re-decodifica los roles directamente del JWT
    return AuthResponseModel.fromJson(map);
  }

  @override
  Future<void> saveToken(AuthToken token) async {
    final model = AuthResponseModel(
      accessToken: token.accessToken,
      refreshToken: token.refreshToken,
      expiresIn: token.expiresIn,
      roles: token.roles,
    );
    await prefs.setString(_tokenKey, jsonEncode(model.toJson()));
  }

  @override
  Future<void> clearToken() async {
    await prefs.remove(_tokenKey);
  }
}
