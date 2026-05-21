import '../../../../core/utils/jwt_decoder.dart';
import '../../domain/entities/auth_token.dart';

class AuthResponseModel extends AuthToken {
  const AuthResponseModel({
    required super.accessToken,
    required super.refreshToken,
    required super.expiresIn,
    required super.roles,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final accessToken = json['access_token'] as String;
    return AuthResponseModel(
      accessToken: accessToken,
      refreshToken: json['refresh_token'] as String,
      expiresIn: json['expires_in'] as int,
      roles: JwtDecoder.getRoles(accessToken),
    );
  }

  Map<String, dynamic> toJson() => {
        'access_token': accessToken,
        'refresh_token': refreshToken,
        'expires_in': expiresIn,
        'roles': roles,
      };
}
