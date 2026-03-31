import 'dart:convert';
import '../api/api_client.dart';
import '../common/constants/api_constants.dart';

class AuthRepository {
  final ApiClient _client;
  AuthRepository({ApiClient? client}) : _client = client ?? ApiClient();
  Future<String> login({required String username, required String password}) async {
    final res = await _client.post(
      ApiConstants.authLogin,
      body: jsonEncode({'username': username, 'password': password}),
      withAuth: false,
      errorBuilder: (code, _) => '登录失败($code)',
    );
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
