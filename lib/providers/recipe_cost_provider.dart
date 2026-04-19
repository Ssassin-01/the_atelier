import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/recipe.dart';
import '../models/pantry_item.dart';
import 'pantry_provider.dart';

class RecipeCostData {
  final double totalCost;
  final Map<String, double> ingredientCosts;
  final bool hasMissingItems;

  RecipeCostData({
    required this.totalCost,
    required this.ingredientCosts,
    this.hasMissingItems = false,
  });

  double get suggestedPrice => totalCost * 3.0; // Standard 3x markup
  double get estimatedProfit => suggestedPrice - totalCost;
}

final recipeCostProvider = Provider.family<RecipeCostData, Recipe>((ref, recipe) {
  final pantryItems = ref.watch(pantryProvider);
  
  double totalCost = 0;
  Map<String, double> ingredientCosts = {};
  bool hasMissingItems = false;

  for (var component in recipe.components) {
    for (var ingredient in component.ingredients) {
      // Find matching pantry item by name (case insensitive)
      final pantryItem = pantryItems.cast<PantryItem?>().firstWhere(
        (item) => item?.name.toLowerCase() == ingredient.name.toLowerCase(),
        orElse: () => null,
      );

      if (pantryItem != null) {
        final amount = double.tryParse(ingredient.amount) ?? 0;
        final cost = amount * pantryItem.unitPrice;
        ingredientCosts[ingredient.name] = (ingredientCosts[ingredient.name] ?? 0) + cost;
        totalCost += cost;
      } else {
        hasMissingItems = true;
        ingredientCosts[ingredient.name] = 0;
      }
    }
  }

  return RecipeCostData(
    totalCost: totalCost,
    ingredientCosts: ingredientCosts,
    hasMissingItems: hasMissingItems,
  );
});
