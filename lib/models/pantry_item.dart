import 'package:hive/hive.dart';

part 'pantry_item.g.dart';

@HiveType(typeId: 4)
class PantryItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double purchasePrice; // The price paid originally (reference price)

  @HiveField(3)
  final double targetQuantity; // The goal quantity to maintain (Alert Level)

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

  @HiveField(9)
  final double purchaseQuantity; // The quantity corresponding to the purchasePrice

  PantryItem({
    required this.id,
    required this.name,
    required this.purchasePrice,
    required this.targetQuantity,
    this.purchaseQuantity = 0,
    this.unit = 'g',
    this.currentStock = 0,
    required this.lastUpdated,
    this.imageUrl,
    this.category = 'Others',
  });

  /// Calculates the cost per single unit (e.g. per gram/ml) based on the purchase price/qty
  double get unitPrice {
    // Fallback to targetQuantity if purchaseQuantity is not set (for migration/legacy data)
    final baseQty = purchaseQuantity > 0 ? purchaseQuantity : targetQuantity;
    if (baseQty <= 0) return 0;
    return purchasePrice / baseQty;
  }

  PantryItem copyWith({
    String? id,
    String? name,
    double? purchasePrice,
    double? targetQuantity,
    double? purchaseQuantity,
    String? unit,
    double? currentStock,
    DateTime? lastUpdated,
    String? imageUrl,
    String? category,
  }) {
    return PantryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      targetQuantity: targetQuantity ?? this.targetQuantity,
      purchaseQuantity: purchaseQuantity ?? this.purchaseQuantity,
      unit: unit ?? this.unit,
      currentStock: currentStock ?? this.currentStock,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
    );
  }
}
