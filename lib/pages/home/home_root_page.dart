import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../common/constants/text_constants.dart';
import '../../widgets/app_bottom_nav.dart';
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
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _index,
        onIndexChanged: (value) => setState(() => _index = value),
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
