import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'product_model.dart';
import 'product_repository.dart';
import '../auth/auth_token_provider.dart';

class ProductListState {
  final List<Product> items;
  final bool isRefreshing;
  final bool isLoadingMore;
  final bool hasMore;
  final String? error;
  const ProductListState({
    this.items = const [],
    this.isRefreshing = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });
  ProductListState copyWith({
    List<Product>? items,
    bool? isRefreshing,
    bool? isLoadingMore,
    bool? hasMore,
    String? error,
  }) {
    return ProductListState(
      items: items ?? this.items,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: error,
    );
  }
}

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(tokenGetter: () => ref.read(authTokenProvider));
});

final productListProvider = StateNotifierProvider<ProductListNotifier, ProductListState>((ref) {
  final repo = ref.read(productRepositoryProvider);
  return ProductListNotifier(repo);
});

class ProductListNotifier extends StateNotifier<ProductListState> {
  final ProductRepository _repo;
  int _page = 1;
  final int _pageSize = 16;
  ProductListNotifier(this._repo) : super(const ProductListState());
  Future<void> loadInitial() async {
    if (state.items.isNotEmpty) return;
    await refresh();
  }
  Future<void> refresh() async {
    state = state.copyWith(isRefreshing: true, error: null);
    _page = 1;
    try {
      final list = await _repo.fetchProducts(page: _page, pageSize: _pageSize);
      final favIds = await _repo.fetchWishlistIds();
      final merged = list
          .map((p) => favIds.contains(p.id) ? p.copyWith(isFavorite: true) : p)
          .toList(growable: false);
      state = ProductListState(
        items: merged,
        isRefreshing: false,
        isLoadingMore: false,
        hasMore: merged.length == _pageSize,
      );
    } catch (e) {
      state = state.copyWith(isRefreshing: false, error: e.toString());
    }
  }
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true, error: null);
    try {
      _page += 1;
      final list = await _repo.fetchProducts(page: _page, pageSize: _pageSize);
      final favIds = await _repo.fetchWishlistIds();
      final patched = list
          .map((p) => favIds.contains(p.id) ? p.copyWith(isFavorite: true) : p)
          .toList(growable: false);
      final combined = [...state.items, ...patched];
      state = state.copyWith(
        items: combined,
        isLoadingMore: false,
        hasMore: patched.length == _pageSize,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e.toString());
    }
  }
  Future<void> toggleFavorite(int id) async {
    final index = state.items.indexWhere((p) => p.id == id);
    if (index == -1) return;
    final previousList = state.items;
    final target = previousList[index];
    final nextFav = !target.isFavorite;
    final optimistic = [...previousList];
    optimistic[index] = target.copyWith(isFavorite: nextFav);
    state = state.copyWith(items: optimistic, error: null);
    try {
      final favorites = optimistic.where((p) => p.isFavorite).toList(growable: false);
      await _repo.setWishlist(favorites: favorites);
    } catch (e) {
      state = state.copyWith(items: previousList, error: e.toString());
      final prevFavorites = previousList.where((p) => p.isFavorite).toList(growable: false);
      try {
        await _repo.setWishlist(favorites: prevFavorites);
      } catch (_) {}
    }
  }
}
