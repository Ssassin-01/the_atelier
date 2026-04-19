import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 5)
class BusinessTransaction extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final DateTime date;

  @HiveField(2)
  final String type; // 'sale' (매출) or 'expense' (지출)

  @HiveField(3)
  final double amount;

  @HiveField(4)
  final String category; // e.g. 'Ingredient Purchase', 'Product Sale', 'Rent'

  @HiveField(5)
  final String description;

  @HiveField(6)
  final String? relatedItemId; // Optional ID of PantryItem if it's an ingredient purchase

  BusinessTransaction({
    required this.id,
    required this.date,
    required this.type,
    required this.amount,
    required this.category,
    required this.description,
    this.relatedItemId,
  });

  bool get isSale => type == 'sale';
  bool get isExpense => type == 'expense';
}
