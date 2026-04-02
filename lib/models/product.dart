import 'package:freezed_annotation/freezed_annotation.dart';

part 'product.freezed.dart';

@freezed
class Product with _$Product {
  const factory Product({
    required int id,
    required String name,
    required double price,
    required String imageUrl,
    @Default(false) bool isFavorite,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) {
    final idRaw = json['id'];
    final nameRaw = json['name'] ?? json['title'] ?? '';
    final priceRaw = json['price'];
    final imageRaw = json['imageUrl'] ?? json['image_url'] ?? json['image'] ?? '';
    final favRaw = json['isFavorite'] ?? json['is_favorite'] ?? json['favorite'] ?? false;
    return Product(
      id: idRaw is int ? idRaw : int.tryParse(idRaw.toString()) ?? 0,
      name: nameRaw.toString(),
      price: priceRaw is num ? priceRaw.toDouble() : double.tryParse(priceRaw?.toString() ?? '0') ?? 0,
      imageUrl: imageRaw.toString(),
      isFavorite: favRaw == true || favRaw.toString() == 'true',
    );
  }
}
