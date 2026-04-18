import '../models/recipe.dart';
import '../models/component.dart';
import '../models/ingredient.dart';
import '../models/step.dart';

List<Recipe> getMockRecipes() {
  return [
    Recipe(
      id: '1',
      name: 'Artisan Sourdough',
      description: 'Slow-fermented traditional bread with a crunchy crust.',
      createdAt: DateTime.now(),
      tags: ['bread', 'sourdough'],
      components: [
        RecipeComponent(
          title: 'Dough',
          ingredients: [
            Ingredient(name: 'Bread Flour', amount: '500', unit: 'g'),
            Ingredient(name: 'Water', amount: '350', unit: 'g'),
            Ingredient(name: 'Sourdough Starter', amount: '100', unit: 'g'),
            Ingredient(name: 'Salt', amount: '10', unit: 'g'),
          ],
          steps: [
            RecipeStep(description: 'Mix flour and water, autolyse for 1 hour.'),
            RecipeStep(description: 'Add starter and salt, knead until smooth.', redNote: 'Do not overmix!'),
            RecipeStep(description: 'Bulk fermentation for 4-6 hours.'),
          ],
        ),
      ],
    ),
    Recipe(
      id: '2',
      name: 'Croissant',
      description: 'Buttery, flaky French pastry.',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      tags: ['pastry', 'french'],
      components: [
        RecipeComponent(
          title: 'Dough & Lamination',
          ingredients: [
            Ingredient(name: 'Flour', amount: '500', unit: 'g'),
            Ingredient(name: 'Butter (Dry)', amount: '250', unit: 'g'),
            Ingredient(name: 'Sugar', amount: '50', unit: 'g'),
          ],
          steps: [
            RecipeStep(description: 'Make detrempe and chill overnight.'),
            RecipeStep(description: 'Laminate butter with 3 single turns.', redNote: 'Keep it cold!'),
          ],
        ),
      ],
    ),
  ];
}
