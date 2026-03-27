class Product {
  final int id;
  final String name;
  final double price;
  final String imageUrl;
  final bool isFavorite;
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });
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
  Product copyWith({
    int? id,
    String? name,
    double? price,
    String? imageUrl,
    bool? isFavorite,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}
