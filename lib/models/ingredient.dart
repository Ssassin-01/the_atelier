import 'package:hive/hive.dart';

part 'ingredient.g.dart';

@HiveType(typeId: 2)
class Ingredient extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String amount;

  @HiveField(2)
  String unit;

  @HiveField(3, defaultValue: false)
  bool isFlour;

  Ingredient({
    required this.name,
    required this.amount,
    required this.unit,
    this.isFlour = false,
  });
}
