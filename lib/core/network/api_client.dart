import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../errors/failures.dart';

class ApiClient {
  final http.Client _client;
  String? _token;
  void Function()? onUnauthorized;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  void setToken(String? token) => _token = token;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: _headers,
        body: jsonEncode(body),
      );
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkFailure('Sin conexión. Verifique su red.');
    }
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}$endpoint'),
        headers: _headers,
      );
      return _handleResponse(response);
    } on SocketException {
      throw const NetworkFailure('Sin conexión. Verifique su red.');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ServerFailure('Error del servidor (${response.statusCode}).');
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    // NestJS puede devolver message como String o como List<String> (class-validator)
    final msg = _extractMessage(body) ?? 'Error del servidor (${response.statusCode}).';

    if (response.statusCode == 401) {
      onUnauthorized?.call();
      throw AuthFailure(msg);
    }
    throw ServerFailure(msg);
  }

  String? _extractMessage(Map<String, dynamic> body) {
    final raw = body['message'];
    if (raw == null) return null;
    if (raw is String) return raw;
    if (raw is List) return raw.join(', ');
    return raw.toString();
  }
}
