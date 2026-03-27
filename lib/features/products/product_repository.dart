import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http/browser_client.dart' as http_browser;
import 'product_model.dart';

class ProductRepository {
  final String? Function()? _tokenGetter;
  static const String baseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:4000');
  static const String apiToken = String.fromEnvironment('API_TOKEN', defaultValue: '');
  final http.Client _client = kIsWeb ? (http_browser.BrowserClient()..withCredentials = true) : http.Client();
  ProductRepository({String? Function()? tokenGetter}) : _tokenGetter = tokenGetter;
  Map<String, String> _defaultHeaders() {
    final h = <String, String>{'Content-Type': 'application/json'};
    final token = _tokenGetter?.call();
    final effectiveToken = (token != null && token.isNotEmpty) ? token : apiToken;
    if (effectiveToken.isNotEmpty) {
      h['Authorization'] = 'Bearer $effectiveToken';
      h['Cookie'] = 'auth-token=$effectiveToken';
    }
    return h;
  }
  Future<List<Product>> fetchProducts({required int page, required int pageSize}) async {
    final uri = Uri.parse('$baseUrl/api/products').replace(queryParameters: {
      'page': page.toString(),
      'limit': pageSize.toString(),
    });
    final res = await _client.get(uri, headers: _defaultHeaders());
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('商品列表获取失败(${res.statusCode})');
    }
    final data = jsonDecode(res.body);
    final itemsJson = _extractItems(data);
    if (itemsJson == null) {
      throw Exception('返回格式不正确');
    }
    return itemsJson.map<Product>((e) => Product.fromJson(e as Map<String, dynamic>)).toList(growable: false);
  }
  Future<void> setWishlist({required List<Product> favorites, Map<String, String>? headers}) async {
    final uri = Uri.parse('$baseUrl/api/wishlist');
    final payload = favorites
        .map((p) => {
              'id': p.id,
              'title': p.name,
              'price': p.price,
              'image': p.imageUrl,
            })
        .toList(growable: false);
    final res = await _client.post(
      uri,
      headers: {..._defaultHeaders(), ...?headers},
      body: jsonEncode(payload),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('收藏同步失败(${res.statusCode})');
    }
  }
  Future<Set<int>> fetchWishlistIds({Map<String, String>? headers}) async {
    final uri = Uri.parse('$baseUrl/api/wishlist');
    final res = await _client.get(uri, headers: {..._defaultHeaders(), ...?headers});
    if (res.statusCode < 200 || res.statusCode >= 300) {
      return <int>{};
    }
    final data = jsonDecode(res.body);
    final itemsJson = _extractItems(data);
    if (itemsJson == null) {
      return <int>{};
    }
    final ids = <int>{};
    for (final e in itemsJson) {
      if (e is Map<String, dynamic>) {
        final idRaw = e['id'] ?? e['_id'];
        final id = idRaw is int ? idRaw : int.tryParse(idRaw?.toString() ?? '');
        if (id != null) ids.add(id);
      }
    }
    return ids;
  }



  List<dynamic>? _extractItems(dynamic data) {
    if (data is List) return data;
    if (data is Map) {
      final keys = ['items', 'data', 'products', 'list', 'results', 'rows'];
      for (final k in keys) {
        final v = data[k];
        if (v is List) return v;
        if (v is Map) {
          for (final kk in keys) {
            final vv = v[kk];
            if (vv is List) return vv;
          }
        }
      }
    }
    return null;
  }
}
