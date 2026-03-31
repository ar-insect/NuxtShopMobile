import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/constants/text_constants.dart';
import '../../router/app_router.dart';
import '../../services/auth/auth_token_provider.dart';
import '../../services/products/product_list_notifier.dart';
import '../../widgets/product_card.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<ProductListState>(productListProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });
    final state = ref.watch(productListProvider);
    final favorites = state.items.where((p) => p.isFavorite).toList(growable: false);
    return Scaffold(
      appBar: AppBar(title: const Text(TextConstants.favoritesTitle)),
      body: RefreshIndicator(
        onRefresh: () => ref.read(productListProvider.notifier).refresh(),
        child: favorites.isEmpty && state.isRefreshing
            ? GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  childAspectRatio: 0.78,
                ),
                itemCount: 6,
                itemBuilder: (context, index) => const SkeletonCard(),
              )
            : GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  childAspectRatio: 0.78,
                ),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final p = favorites[index];
                  return ProductCard(
                    product: p,
                    onFavoriteTap: () {
                      final token = ref.read(authTokenProvider);
                      if (token == null || token.isEmpty) {
                        AppRouter.goLogin(context);
                        return;
                      }
                      ref.read(productListProvider.notifier).toggleFavorite(p.id);
                    },
                  );
                },
              ),
      ),
    );
  }
}
