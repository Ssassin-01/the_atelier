import '../models/recipe.dart';
import '../models/component.dart';
import '../models/ingredient.dart';
import '../models/step.dart';

List<Recipe> getMockRecipes() {
  return [
    Recipe(
      id: 'pumpkin-dessert',
      name: 'Pumpkin Porridge Dessert',
      description: 'A sophisticated multi-layered dessert featuring kabocha cream, mochi, and roasted rice textures.',
      mainImageUrl: 'assets/images/pumpkin_dessert.png',
      createdAt: DateTime.now(),
      tags: ['Seasonal', 'Signature'],
      components: [
        RecipeComponent(
          title: 'A. Pumpkin Cream',
          ingredients: [
            Ingredient(name: 'Frozen Kabocha', amount: '300', unit: 'g'),
            Ingredient(name: 'Milk', amount: '90', unit: 'g'),
            Ingredient(name: 'Heavy Cream', amount: '60', unit: 'g'),
            Ingredient(name: 'Egg Yolks', amount: '22', unit: 'g'),
            Ingredient(name: 'Sugar', amount: '15', unit: 'g'),
            Ingredient(name: 'Salt', amount: '1', unit: 'g'),
            Ingredient(name: 'Cinnamon', amount: '0.3', unit: 'g'),
            Ingredient(name: 'Sheet Gelatin', amount: '2', unit: 'g'),
          ],
          steps: [
            RecipeStep(description: 'Steam kabocha (170°C for 20m), scoop out flesh and puree.'),
            RecipeStep(description: 'Heat milk and heavy cream until steam rises.'),
            RecipeStep(description: 'Whisk egg yolks, sugar, and salt together.'),
            RecipeStep(description: 'Gradually pour hot liquid into yolks and heat to 82°C.'),
            RecipeStep(description: 'Add soaked gelatin and emulsify.'),
            RecipeStep(description: 'Mix with pumpkin puree and blend smooth.'),
          ],
        ),
        RecipeComponent(
          title: 'B. Mini Rice Balls',
          ingredients: [
            Ingredient(name: 'Dry Glutinous Rice Flour', amount: '50g', unit: ''),
            Ingredient(name: 'Hot Water', amount: '32', unit: 'g'),
            Ingredient(name: 'Sugar', amount: '4', unit: 'g'),
            Ingredient(name: 'Salt', amount: '0.5', unit: 'g'),
          ],
          steps: [
            RecipeStep(description: 'Mix flour, sugar, and salt.'),
            RecipeStep(description: 'Add hot water and knead to form a smooth dough.'),
            RecipeStep(description: 'Divide into small 4g portions and roll into spheres.'),
            RecipeStep(description: 'Boil until they float, then cook for 1 more minute.'),
            RecipeStep(description: 'Immediately cool in ice water.'),
          ],
        ),
        RecipeComponent(
          title: 'C. Pumpkin Seed Tuile',
          ingredients: [
            Ingredient(name: 'Pumpkin Seeds', amount: '50', unit: 'g'),
            Ingredient(name: 'Butter', amount: '35', unit: 'g'),
            Ingredient(name: 'Icing Sugar', amount: '35', unit: 'g'),
            Ingredient(name: 'Rice Flour (Cake)', amount: '15', unit: 'g'),
            Ingredient(name: 'Egg White', amount: '30', unit: 'g'),
            Ingredient(name: 'Salt', amount: '1', unit: 'pinch'),
          ],
          steps: [
            RecipeStep(description: 'Finely chop the pumpkin seeds.'),
            RecipeStep(description: 'Cream softened butter with icing sugar.'),
            RecipeStep(description: 'Mix in egg whites followed by rice flour.'),
            RecipeStep(description: 'Fold in the chopped seeds. Chill for 20m.'),
            RecipeStep(description: 'Bake at 180°C for 8-11m until golden.'),
          ],
        ),
        RecipeComponent(
          title: 'D. Soybean Rice Crumble',
          ingredients: [
            Ingredient(name: 'Rice Flour', amount: '35', unit: 'g'),
            Ingredient(name: 'Soybean Powder', amount: '20', unit: 'g'),
            Ingredient(name: 'Almond Flour', amount: '15', unit: 'g'),
            Ingredient(name: 'Sugar', amount: '22', unit: 'g'),
            Ingredient(name: 'Cold Butter', amount: '32', unit: 'g'),
            Ingredient(name: 'Salt', amount: '1', unit: 'g'),
          ],
          steps: [
            RecipeStep(description: 'Sift together rice flour, soybean powder, and almond flour.'),
            RecipeStep(description: 'Rub in cold cubed butter to create a coarse crumble texture.'),
            RecipeStep(description: 'Freeze briefly to maintain shape.'),
            RecipeStep(description: 'Bake at 160°C for 12-15m, tossing halfway.'),
          ],
        ),
        RecipeComponent(
          title: 'E. Rice Ice Cream',
          ingredients: [
            Ingredient(name: 'Cooked Glutinous Rice', amount: '50', unit: 'g'),
            Ingredient(name: 'Milk', amount: '350', unit: 'g'),
            Ingredient(name: 'Sugar', amount: '40', unit: 'g'),
            Ingredient(name: 'Heavy Cream', amount: '84', unit: 'g'),
            Ingredient(name: 'Dextrose', amount: '25', unit: 'g'),
            Ingredient(name: 'Salt', amount: '0.5', unit: 'g'),
            Ingredient(name: 'Glucose Syrup', amount: '20', unit: 'g'),
            Ingredient(name: 'Roasted Brown Rice', amount: '7', unit: 'g'),
          ],
          steps: [
            RecipeStep(description: 'Simmer rice and milk in a pot to 50°C.'),
            RecipeStep(description: 'Add heavy cream, dextrose, syrup and heat to 82°C.'),
            RecipeStep(description: 'Blend with an immersion blender until smooth.'),
            RecipeStep(description: 'Fold in roasted brown rice for crunch. Churn in ice cream maker.'),
          ],
        ),
      ],
    ),
    Recipe(
      id: '1',
      name: 'Spelt & Honey Sourdough',
      description: 'A rustic sourdough with toasted spelt and floral honey.',
      mainImageUrl: 'assets/images/sourdough.png',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      tags: ['Sourdough', 'Artisan'],
      components: [
        RecipeComponent(
          title: 'Main Dough',
          ingredients: [
            Ingredient(name: 'Spelt Flour', amount: '200', unit: 'g'),
            Ingredient(name: 'Bread Flour', amount: '300', unit: 'g'),
            Ingredient(name: 'Water', amount: '380', unit: 'g'),
            Ingredient(name: 'Honey', amount: '20', unit: 'g'),
          ],
          steps: [
            RecipeStep(description: 'Mix flour, water, and honey. Autolyse for 45 minutes.'),
            RecipeStep(description: 'Bulk ferment at 24°C for 6 hours.'),
          ],
        ),
      ],
    ),
  ];
}
