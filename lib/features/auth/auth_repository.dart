import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthRepository {
  static const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:4000');
  Future<String> login({required String username, required String password}) async {
    final uri = Uri.parse('$baseUrl/api/auth/login');
    final res = await http.post(uri, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'username': username, 'password': password}));
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('登录失败(${res.statusCode})');
    }
    final data = _tryDecode(res.body);
    if (data is Map && data['token'] is String) {
      return data['token'] as String;
    }
    if (data is Map && data['access_token'] is String) {
      return data['access_token'] as String;
    }
    if (data is Map && data['data'] is Map && (data['data'] as Map)['token'] is String) {
      return (data['data'] as Map)['token'] as String;
    }
    final cookieHeader = res.headers['set-cookie'];
    final tokenFromCookie = _extractAuthToken(cookieHeader);
    if (tokenFromCookie != null && tokenFromCookie.isNotEmpty) {
      return tokenFromCookie;
    }
    throw Exception('登录返回缺少token');
  }
  dynamic _tryDecode(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }
  String? _extractAuthToken(String? setCookie) {
    if (setCookie == null) return null;
    final idx = setCookie.indexOf('auth-token=');
    if (idx == -1) return null;
    final start = idx + 'auth-token='.length;
    final end = setCookie.indexOf(';', start);
    return end == -1 ? setCookie.substring(start) : setCookie.substring(start, end);
  }
}
