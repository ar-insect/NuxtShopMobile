import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import '../common/constants/text_constants.dart';
import '../router/app_router.dart';
import '../services/auth/auth_token_provider.dart';

class AppBottomNavigationBar extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;
  const AppBottomNavigationBar({super.key, required this.currentIndex, required this.onIndexChanged});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = [
      _NavItemData(icon: MdiIcons.storefrontOutline, label: TextConstants.productListTitle),
      _NavItemData(icon: MdiIcons.heartMultipleOutline, label: TextConstants.favoritesTitle),
      _NavItemData(icon: MdiIcons.cartHeart, label: TextConstants.cartTitle),
      _NavItemData(icon: MdiIcons.accountCogOutline, label: TextConstants.profileTitle),
    ];
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(top: BorderSide(color: colorScheme.outlineVariant, width: 0.5)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final item = items[index];
            final selected = index == currentIndex;
            return _NavItem(
              data: item,
              selected: selected,
              onTap: () {
                if (index == 1) {
                  final token = ref.read(authTokenProvider);
                  if (token == null || token.isEmpty) {
                    AppRouter.goLogin(context);
                    return;
                  }
                }
                if (index == currentIndex) return;
                onIndexChanged(index);
              },
            );
          }),
        ),
      ),
    );
  }
}

class _NavItemData {
  final IconData icon;
  final String label;
  const _NavItemData({required this.icon, required this.label});
}

class _NavItem extends StatelessWidget {
  final _NavItemData data;
  final bool selected;
  final VoidCallback onTap;
  const _NavItem({required this.data, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = selected ? colorScheme.primary : colorScheme.onSurfaceVariant;
    final textColor = selected ? colorScheme.primary : colorScheme.onSurfaceVariant;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(data.icon, size: 22, color: iconColor),
              const SizedBox(height: 2),
              Text(
                data.label,
                style: TextStyle(fontSize: 11, color: textColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
