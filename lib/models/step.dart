import 'package:hive/hive.dart';

part 'step.g.dart';

@HiveType(typeId: 3)
class RecipeStep extends HiveObject {
  @HiveField(0)
  String description;

  @HiveField(1)
  String? redNote;

  RecipeStep({
    required this.description,
    this.redNote,
  });
}
