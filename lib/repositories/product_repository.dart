import 'dart:async';
import 'dart:convert';
import '../api/api_client.dart';
import '../common/constants/api_constants.dart';
import '../models/product.dart';

class ProductRepository {
  final ApiClient _client;
  ProductRepository({String? Function()? tokenGetter, ApiClient? client}) : _client = client ?? ApiClient(tokenGetter: tokenGetter);
  Future<List<Product>> fetchProducts({required int page, required int pageSize}) async {
    final res = await _client.get(
      ApiConstants.products,
      queryParameters: {
        'page': page.toString(),
        'limit': pageSize.toString(),
      },
      errorBuilder: (code, _) => '商品列表获取失败($code)',
    );
    final data = jsonDecode(res.body);
    final itemsJson = _extractItems(data);
    if (itemsJson == null) {
      throw Exception('返回格式不正确');
    }
    return itemsJson.map<Product>((e) => Product.fromJson(e as Map<String, dynamic>)).toList(growable: false);
  }
  Future<void> setWishlist({required List<Product> favorites, Map<String, String>? headers}) async {
    final payload = favorites
        .map((p) => {
              'id': p.id,
              'title': p.name,
              'price': p.price,
              'image': p.imageUrl,
            })
        .toList(growable: false);
    await _client.post(
      ApiConstants.wishlist,
      headers: headers,
      body: jsonEncode(payload),
      errorBuilder: (code, _) => '收藏同步失败($code)',
    );
  }
  Future<Set<int>> fetchWishlistIds({Map<String, String>? headers}) async {
    final res = await _client.get(
      ApiConstants.wishlist,
      headers: headers,
      throwOnError: false,
    );
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
