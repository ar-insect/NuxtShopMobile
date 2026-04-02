import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:http/http.dart' as http;
import '../common/constants/api_constants.dart';
import 'http_client_factory.dart' if (dart.library.html) 'http_client_factory_web.dart';
import '../common/errors/app_error.dart';

typedef TokenGetter = String? Function();

class ApiClient {
  final TokenGetter? _tokenGetter;
  final http.Client _client;
  final void Function(String method, Uri uri, Map<String, String> headers, Object? body)? _onRequest;
  final void Function(String method, Uri uri, http.Response response)? _onResponse;
  final Duration timeout;
  final int maxRetries;
  ApiClient({
    TokenGetter? tokenGetter,
    void Function(String method, Uri uri, Map<String, String> headers, Object? body)? onRequest,
    void Function(String method, Uri uri, http.Response response)? onResponse,
    Duration? timeout,
    int maxRetries = 2,
  })  : _tokenGetter = tokenGetter,
        _onRequest = onRequest,
        _onResponse = onResponse,
        timeout = timeout ?? const Duration(seconds: 10),
        maxRetries = maxRetries,
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
  Future<http.Response> _sendWithRetry(
    String method,
    Uri uri,
    Future<http.Response> Function() send, {
    bool throwOnError = true,
    String Function(int statusCode, String body)? errorBuilder,
  }) async {
    http.Response res;
    var attempt = 0;
    while (true) {
      attempt += 1;
      try {
        res = await send().timeout(timeout);
        _logResponse(method, uri, res);
        if (throwOnError && (res.statusCode < 200 || res.statusCode >= 300)) {
          if (res.statusCode == 401) {
            final msg = errorBuilder?.call(res.statusCode, res.body) ?? '未登录或登录已过期';
            throw AppError.unauthorized(msg, statusCode: res.statusCode);
          }
          final msg = errorBuilder?.call(res.statusCode, res.body) ??
              (res.statusCode >= 500
                  ? '服务器开小差了，请稍后再试'
                  : '请求出错(${res.statusCode})，请稍后重试');
          throw AppError.http(msg, statusCode: res.statusCode);
        }
        return res;
      } on TimeoutException catch (e, st) {
        if (attempt < maxRetries) {
          continue;
        }
        throw AppError.timeout('请求超时，请检查网络后重试', cause: e, stackTrace: st);
      } on AppError {
        rethrow;
      } catch (e, st) {
        if (attempt < maxRetries) {
          continue;
        }
        throw AppError.network('网络异常，请检查网络或后端服务是否已启动', cause: e, stackTrace: st);
      }
    }
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
    return _sendWithRetry(
      'GET',
      uri,
      () => _client.get(uri, headers: resolvedHeaders),
      throwOnError: throwOnError,
      errorBuilder: errorBuilder,
    );
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
    return _sendWithRetry(
      'POST',
      uri,
      () => _client.post(uri, headers: resolvedHeaders, body: body),
      throwOnError: throwOnError,
      errorBuilder: errorBuilder,
    );
  }
}
