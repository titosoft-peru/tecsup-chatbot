class ApiConstants {
  static const String baseUrl = 'http://192.168.1.38:8000/api/v1';

  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String register = '/auth/register';
  static const String process = '/process';
  static String result(String requestId) => '/result/$requestId';

  static const Duration pollInterval = Duration(seconds: 2);
  static const Duration pollTimeout = Duration(seconds: 120);
}
