import 'package:equatable/equatable.dart';

enum AppRole { admin, gerente, vendedor, unknown }

AppRole roleFromString(String s) => switch (s) {
      'admin' => AppRole.admin,
      'gerente' => AppRole.gerente,
      'vendedor' => AppRole.vendedor,
      _ => AppRole.unknown,
    };

class AuthToken extends Equatable {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final List<String> roles;

  const AuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.roles,
  });

  AppRole get primaryRole =>
      roles.isNotEmpty ? roleFromString(roles.first) : AppRole.unknown;

  bool get isAdmin => roles.contains('admin');
  bool get isGerente => roles.contains('gerente');
  bool get isVendedor => roles.contains('vendedor');

  @override
  List<Object> get props => [accessToken, refreshToken, expiresIn, roles];
}
