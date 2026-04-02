import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/constants/text_constants.dart';
import '../../common/errors/app_error.dart';
import '../../router/app_router.dart';
import '../../services/auth/auth_token_provider.dart';
import '../../services/auth/auth_token_store.dart';
import '../../services/products/product_list_notifier.dart';
import '../../widgets/product_card.dart';
import '../../widgets/empty_view.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<ProductListState>(productListProvider, (previous, next) {
      if (next.error != null && next.error != previous?.error) {
        final error = next.error!;
        if (error.type == AppErrorType.unauthorized) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('登录已过期，请重新登录')));
          AuthTokenStore.clear();
          ref.read(authTokenProvider.notifier).state = null;
          AppRouter.goLogin(context, fromLogout: true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message)));
        }
      }
    });
    final state = ref.watch(productListProvider);
    final favorites = state.items.where((p) => p.isFavorite).toList(growable: false);
    final isEmpty = favorites.isEmpty && !state.isRefreshing && state.error == null;
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
            : isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      EmptyView(
                        icon: Icons.favorite_border,
                        title: '还没有收藏',
                        subtitle: '去首页逛逛，看看有没有喜欢的商品',
                      ),
                    ],
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
