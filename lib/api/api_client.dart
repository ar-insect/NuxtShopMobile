import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;
import '../common/constants/api_constants.dart';
import 'http_client_factory.dart' if (dart.library.html) 'http_client_factory_web.dart';

typedef TokenGetter = String? Function();

class ApiClient {
  final TokenGetter? _tokenGetter;
  final http.Client _client;
  final void Function(String method, Uri uri, Map<String, String> headers, Object? body)? _onRequest;
  final void Function(String method, Uri uri, http.Response response)? _onResponse;
  ApiClient({
    TokenGetter? tokenGetter,
    void Function(String method, Uri uri, Map<String, String> headers, Object? body)? onRequest,
    void Function(String method, Uri uri, http.Response response)? onResponse,
  })  : _tokenGetter = tokenGetter,
        _onRequest = onRequest,
        _onResponse = onResponse,
        _client = createHttpClient();
  Map<String, String> _buildHeaders({Map<String, String>? headers, bool withAuth = true}) {
    final result = <String, String>{'Content-Type': 'application/json'};
    if (withAuth) {
      final token = _tokenGetter?.call();
      final effectiveToken = (token != null && token.isNotEmpty) ? token : ApiConstants.apiToken;
      if (effectiveToken.isNotEmpty) {
        result['Authorization'] = 'Bearer $effectiveToken';
        result['Cookie'] = 'auth-token=$effectiveToken';
      }
    }
    if (headers != null) {
      result.addAll(headers);
    }
    return result;
  }
  Uri _buildUri(String path, Map<String, String>? queryParameters) {
    final base = ApiConstants.baseUrl;
    final normalizedBase = base.endsWith('/') ? base.substring(0, base.length - 1) : base;
    return Uri.parse('$normalizedBase$path').replace(queryParameters: queryParameters);
  }
  void _logRequest(String method, Uri uri, Map<String, String> headers, Object? body) {
    if (kDebugMode) {
      final buffer = StringBuffer()
        ..writeln('[API] $method $uri')
        ..writeln('[API] headers=$headers');
      if (body != null) {
        buffer.writeln('[API] body=$body');
      }
      print(buffer.toString());
    }
    _onRequest?.call(method, uri, headers, body);
  }

  void _logResponse(String method, Uri uri, http.Response res) {
    if (kDebugMode) {
      print('[API] $method $uri -> ${res.statusCode}');
    }
    _onResponse?.call(method, uri, res);
  }
  Future<http.Response> get(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    bool withAuth = true,
    bool throwOnError = true,
    String Function(int statusCode, String body)? errorBuilder,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final resolvedHeaders = _buildHeaders(headers: headers, withAuth: withAuth);
    _logRequest('GET', uri, resolvedHeaders, null);
    final res = await _client.get(uri, headers: resolvedHeaders);
    _logResponse('GET', uri, res);
    if (throwOnError && (res.statusCode < 200 || res.statusCode >= 300)) {
      final message = errorBuilder?.call(res.statusCode, res.body) ?? '请求失败(${res.statusCode})';
      throw Exception(message);
    }
    return res;
  }
  Future<http.Response> post(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    Object? body,
    bool withAuth = true,
    bool throwOnError = true,
    String Function(int statusCode, String body)? errorBuilder,
  }) async {
    final uri = _buildUri(path, queryParameters);
    final resolvedHeaders = _buildHeaders(headers: headers, withAuth: withAuth);
    _logRequest('POST', uri, resolvedHeaders, body);
    final res = await _client.post(uri, headers: resolvedHeaders, body: body);
    _logResponse('POST', uri, res);
    if (throwOnError && (res.statusCode < 200 || res.statusCode >= 300)) {
      final message = errorBuilder?.call(res.statusCode, res.body) ?? '请求失败(${res.statusCode})';
      throw Exception(message);
    }
    return res;
  }
}
