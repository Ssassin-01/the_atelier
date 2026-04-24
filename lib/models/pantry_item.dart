import 'package:hive/hive.dart';

part 'pantry_item.g.dart';

@HiveType(typeId: 4)
class PantryItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double purchasePrice; // The price paid for the bulk amount

  @HiveField(3)
  final double purchaseQuantity; // The amount bought (e.g. 20000 for 20kg)

  @HiveField(4)
  final String unit; // kg, g, ml, etc.

  @HiveField(5)
  final double currentStock;

  @HiveField(6)
  final DateTime lastUpdated;

  @HiveField(7)
  final String? imageUrl;

  @HiveField(8)
  final String category;

  PantryItem({
    required this.id,
    required this.name,
    required this.purchasePrice,
    required this.purchaseQuantity,
    this.unit = 'g',
    this.currentStock = 0,
    required this.lastUpdated,
    this.imageUrl,
    this.category = 'Others',
  });

  /// Calculates the cost per single unit (e.g. per gram/ml)
  double get unitPrice {
    if (purchaseQuantity <= 0) return 0;
    return purchasePrice / purchaseQuantity;
  }

  PantryItem copyWith({
    String? name,
    double? purchasePrice,
    double? purchaseQuantity,
    String? unit,
    double? currentStock,
    DateTime? lastUpdated,
    String? imageUrl,
    String? category,
  }) {
    return PantryItem(
      id: id,
      name: name ?? this.name,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      purchaseQuantity: purchaseQuantity ?? this.purchaseQuantity,
      unit: unit ?? this.unit,
      currentStock: currentStock ?? this.currentStock,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
    );
  }
}
