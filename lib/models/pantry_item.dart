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
  final double targetQuantity; // The goal quantity to maintain (Standard Base)

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
    required this.targetQuantity,
    this.unit = 'g',
    this.currentStock = 0,
    required this.lastUpdated,
    this.imageUrl,
    this.category = 'Others',
  });

  /// Calculates the cost per single unit (e.g. per gram/ml) based on the target price/qty
  double get unitPrice {
    if (targetQuantity <= 0) return 0;
    return purchasePrice / targetQuantity;
  }

  PantryItem copyWith({
    String? id,
    String? name,
    double? purchasePrice,
    double? targetQuantity,
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
      unit: unit ?? this.unit,
      currentStock: currentStock ?? this.currentStock,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
    );
  }
}
