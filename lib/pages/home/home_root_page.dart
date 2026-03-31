import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/constants/text_constants.dart';
import '../../router/app_router.dart';
import '../../services/auth/auth_token_provider.dart';
import 'favorites_page.dart';
import 'product_list_page.dart';

class HomeRootPage extends ConsumerStatefulWidget {
  const HomeRootPage({super.key});
  @override
  ConsumerState<HomeRootPage> createState() => _HomeRootPageState();
}

class _HomeRootPageState extends ConsumerState<HomeRootPage> {
  int _index = 0;
  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const ProductListPage(),
      const FavoritesPage(),
      const _PlaceholderPage(title: TextConstants.cartTitle),
      const _PlaceholderPage(title: TextConstants.profileTitle),
    ];
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        type: BottomNavigationBarType.fixed,
        onTap: (value) {
          if (value == 1) {
            final token = ref.read(authTokenProvider);
            if (token == null || token.isEmpty) {
              AppRouter.goLogin(context);
              return;
            }
          }
          if (value == _index) return;
          setState(() => _index = value);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: TextConstants.productListTitle),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: TextConstants.favoritesTitle),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: TextConstants.cartTitle),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: TextConstants.profileTitle),
        ],
      ),
    );
  }
}

class _PlaceholderPage extends StatelessWidget {
  final String title;
  const _PlaceholderPage({required this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text(title)),
    );
  }
}
