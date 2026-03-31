import 'package:flutter/material.dart';
import '../models/product.dart';
import '../common/constants/theme_constants.dart';
import '../common/utils/price_formatter.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onFavoriteTap;
  const ProductCard({super.key, required this.product, required this.onFavoriteTap});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(ThemeSizes.cardMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 4 / 3,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(ThemeSizes.cardRadius), topRight: Radius.circular(ThemeSizes.cardRadius)),
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                right: 4,
                top: 4,
                child: IconButton(
                  style: IconButton.styleFrom(backgroundColor: Colors.white70),
                  icon: Icon(product.isFavorite ? Icons.favorite : Icons.favorite_border, color: product.isFavorite ? ThemeColors.price : null),
                  onPressed: onFavoriteTap,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                Text(formatPrice(product.price), style: const TextStyle(fontSize: 15, color: ThemeColors.price)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(ThemeSizes.cardMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Container(color: ThemeColors.skeleton),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 16, width: 120, color: ThemeColors.skeleton),
                const SizedBox(height: 8),
                Container(height: 14, width: 80, color: ThemeColors.skeleton),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
