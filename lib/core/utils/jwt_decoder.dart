import 'dart:convert';

class JwtDecoder {
  static Map<String, dynamic> decode(String token) {
    final parts = token.split('.');
    var payload = parts[1];
    // Restaurar padding base64url
    switch (payload.length % 4) {
      case 2:
        payload += '==';
      case 3:
        payload += '=';
    }
    return jsonDecode(utf8.decode(base64Url.decode(payload)))
        as Map<String, dynamic>;
  }

  static List<String> getRoles(String token) {
    try {
      final raw = decode(token)['roles'];
      if (raw is List) return raw.cast<String>();
    } catch (_) {}
    return [];
  }
}
