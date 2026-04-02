import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../../common/constants/text_constants.dart';
import '../../common/errors/app_error.dart';
import '../../router/app_router.dart';
import '../../services/auth/auth_token_provider.dart';
import '../../services/auth/auth_token_store.dart';
import '../../services/products/product_list_notifier.dart';
import '../../widgets/product_card.dart';
import '../../widgets/empty_view.dart';

class ProductListPage extends ConsumerStatefulWidget {
  const ProductListPage({super.key});
  @override
  ConsumerState<ProductListPage> createState() => _ProductListPageState();
}

class _ProductListPageState extends ConsumerState<ProductListPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(productListProvider.notifier).loadInitial());
  }
  bool _onScrollNotification(ScrollNotification n) {
    if (n.metrics.pixels >= n.metrics.maxScrollExtent - 200) {
      ref.read(productListProvider.notifier).loadMore();
    }
    return false;
  }
  @override
  Widget build(BuildContext context) {
    ref.listen<ProductListState>(productListProvider, (prev, next) {
      if (next.error != null && next.error != prev?.error) {
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
    final isEmpty = !state.isRefreshing && state.items.isEmpty && state.error == null;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SizedBox(
            height: 36,
            child: TextField(
              decoration: InputDecoration(
                hintText: TextConstants.productListTitle,
                prefixIcon: const Icon(Icons.search, size: 20),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none,
                ),
                filled: true,
              ),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(MdiIcons.calendarCheckOutline),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(MdiIcons.bellOutline),
            onPressed: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(productListProvider.notifier).refresh(),
        child: NotificationListener<ScrollNotification>(
          onNotification: _onScrollNotification,
          child: state.isRefreshing && state.items.isEmpty
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
                          icon: Icons.storefront_outlined,
                          title: '暂无商品',
                          subtitle: '稍后再来看看，或检查后端服务是否已准备好数据',
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
                      itemCount: state.items.length + ((state.isLoadingMore || state.hasMore) ? 1 : 0),
                      itemBuilder: (context, index) {
                        final extraTile = index >= state.items.length;
                        if (!extraTile) {
                          final p = state.items[index];
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
                        }
                        if (state.isLoadingMore || state.hasMore) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        return const Center(child: Text(TextConstants.noMoreItems));
                      },
                    ),
        ),
      ),
    );
  }
}
