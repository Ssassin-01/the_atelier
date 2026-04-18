import 'package:hive/hive.dart';
import 'ingredient.dart';
import 'step.dart';

part 'component.g.dart';

@HiveType(typeId: 1)
class RecipeComponent extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  List<Ingredient> ingredients;

  @HiveField(2)
  List<RecipeStep> steps;

  RecipeComponent({
    required this.title,
    required this.ingredients,
    required this.steps,
  });
}
