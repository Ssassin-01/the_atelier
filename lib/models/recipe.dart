import 'package:hive/hive.dart';
import 'component.dart';

part 'recipe.g.dart';

@HiveType(typeId: 0)
class Recipe extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String? description;

  @HiveField(3)
  String? mainImageUrl; // Store local path or URL

  @HiveField(4)
  String? sketchImageUrl; // Store local path to PNG

  @HiveField(5)
  List<RecipeComponent> components;

  @HiveField(6)
  List<String> tags;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  double? sellingPrice;

  @HiveField(9)
  double? targetYield;

  Recipe({
    required this.id,
    required this.name,
    this.description,
    this.mainImageUrl,
    this.sketchImageUrl,
    required this.components,
    this.tags = const [],
    required this.createdAt,
    this.sellingPrice,
    this.targetYield,
  });
}
