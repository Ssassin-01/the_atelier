import '../models/recipe.dart';
import '../models/component.dart';
import '../models/ingredient.dart';
import '../models/step.dart';

List<Recipe> getMockRecipes() {
  return [
    Recipe(
      id: 'pumpkin-dessert',
      name: 'Pumpkin Porridge Dessert',
      description:
          'A sophisticated multi-layered dessert featuring kabocha cream, mochi, and roasted rice textures.',
      mainImageUrl: 'assets/images/pumpkin_dessert.png',
      createdAt: DateTime.now(),
      tags: ['Seasonal', 'Signature'],
      components: [
        RecipeComponent(
          title: 'A. Pumpkin Cream',
          imageUrl: 'assets/images/pumpkin_cream.png',
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
            RecipeStep(
              description:
                  'Steam kabocha (170°C for 20m), scoop out flesh and puree.',
            ),
            RecipeStep(
              description: 'Heat milk and heavy cream until steam rises.',
            ),
            RecipeStep(
              description: 'Whisk egg yolks, sugar, and salt together.',
            ),
            RecipeStep(
              description:
                  'Gradually pour hot liquid into yolks and heat to 82°C.',
            ),
            RecipeStep(description: 'Add soaked gelatin and emulsify.'),
            RecipeStep(description: 'Mix with pumpkin puree and blend smooth.'),
          ],
        ),
        RecipeComponent(
          title: 'B. Mini Rice Balls',
          imageUrl: 'assets/images/mini_mochi.png',
          ingredients: [
            Ingredient(
              name: 'Dry Glutinous Rice Flour',
              amount: '50',
              unit: 'g',
            ),
            Ingredient(name: 'Hot Water', amount: '32', unit: 'g'),
            Ingredient(name: 'Sugar', amount: '4', unit: 'g'),
            Ingredient(name: 'Salt', amount: '0.5', unit: 'g'),
          ],
          steps: [
            RecipeStep(description: 'Mix flour, sugar, and salt.'),
            RecipeStep(
              description: 'Add hot water and knead to form a smooth dough.',
            ),
            RecipeStep(
              description:
                  'Divide into small 4g portions and roll into spheres.',
            ),
            RecipeStep(
              description:
                  'Boil until they float, then cook for 1 more minute.',
            ),
            RecipeStep(description: 'Immediately cool in ice water.'),
          ],
        ),
        RecipeComponent(
          title: 'C. Pumpkin Seed Tuile',
          imageUrl: 'assets/images/seed_tuile.png',
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
            RecipeStep(
              description: 'Mix in egg whites followed by rice flour.',
            ),
            RecipeStep(
              description: 'Fold in the chopped seeds. Chill for 20m.',
            ),
            RecipeStep(description: 'Bake at 180°C for 8-11m until golden.'),
          ],
        ),
        RecipeComponent(
          title: 'D. Soybean Rice Crumble',
          imageUrl: 'assets/images/soybean_crumble.png',
          ingredients: [
            Ingredient(name: 'Rice Flour', amount: '35', unit: 'g'),
            Ingredient(name: 'Soybean Powder', amount: '20', unit: 'g'),
            Ingredient(name: 'Almond Flour', amount: '15', unit: 'g'),
            Ingredient(name: 'Sugar', amount: '22', unit: 'g'),
            Ingredient(name: 'Cold Butter', amount: '32', unit: 'g'),
            Ingredient(name: 'Salt', amount: '1', unit: 'g'),
          ],
          steps: [
            RecipeStep(
              description:
                  'Sift together rice flour, soybean powder, and almond flour.',
            ),
            RecipeStep(
              description:
                  'Rub in cold cubed butter to create a coarse crumble texture.',
            ),
            RecipeStep(description: 'Freeze briefly to maintain shape.'),
            RecipeStep(
              description: 'Bake at 160°C for 12-15m, tossing halfway.',
            ),
          ],
        ),
        RecipeComponent(
          title: 'E. Rice Ice Cream',
          imageUrl: 'assets/images/rice_ice_cream.png',
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
            RecipeStep(
              description: 'Add heavy cream, dextrose, syrup and heat to 82°C.',
            ),
            RecipeStep(
              description: 'Blend with an immersion blender until smooth.',
            ),
            RecipeStep(
              description:
                  'Fold in roasted brown rice for crunch. Churn in ice cream maker.',
            ),
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
            RecipeStep(
              description:
                  'Mix flour, water, and honey. Autolyse for 45 minutes.',
            ),
            RecipeStep(description: 'Bulk ferment at 24°C for 6 hours.'),
          ],
        ),
      ],
    ),
    Recipe(
      id: '2',
      name: 'Lavender Lemon Madeleine',
      description: 'A floral and zesty tea-time favorite, glazed with organic lavender syrup.',
      mainImageUrl: 'assets/images/madeleine.png',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      tags: ['Pastry', 'Teatime'],
      components: [
        RecipeComponent(
          title: 'Madeleine Batter',
          ingredients: [
            Ingredient(name: 'Cake Flour', amount: '100', unit: 'g'),
            Ingredient(name: 'Sugar', amount: '90', unit: 'g'),
            Ingredient(name: 'Melted Butter', amount: '100', unit: 'g'),
            Ingredient(name: 'Eggs', amount: '100', unit: 'g'),
            Ingredient(name: 'Baking Powder', amount: '3', unit: 'g'),
            Ingredient(name: 'Lemon Zest', amount: '2', unit: 'g'),
          ],
          steps: [
            RecipeStep(description: 'Whisk eggs and sugar until pale.'),
            RecipeStep(description: 'Sift flour and baking powder into egg mix.'),
            RecipeStep(description: 'Fold in melted butter and lemon zest.'),
            RecipeStep(description: 'Rest the batter in the fridge for 1 hour.'),
            RecipeStep(description: 'Bake at 190°C for 11-13 minutes.'),
          ],
        ),
        RecipeComponent(
          title: 'Lavender Glaze',
          ingredients: [
            Ingredient(name: 'Powdered Sugar', amount: '80', unit: 'g'),
            Ingredient(name: 'Lavender Tea', amount: '15', unit: 'g'),
          ],
          steps: [
            RecipeStep(description: 'Whisk tea and powdered sugar until smooth.'),
            RecipeStep(description: 'Dip warm madeleines into the glaze and let set.'),
          ],
        ),
      ],
    ),
    Recipe(
      id: '3',
      name: 'Classic French Baguette',
      description: 'Traditional baguettes using poolish pre-ferment for deep aroma and crispy crust.',
      mainImageUrl: 'assets/images/baguette.png',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      tags: ['Breads', 'Artisan'],
      components: [
        RecipeComponent(
          title: 'Poolish Starter',
          ingredients: [
            Ingredient(name: 'Bread Flour', amount: '150', unit: 'g'),
            Ingredient(name: 'Water', amount: '150', unit: 'g'),
            Ingredient(name: 'Instant Yeast', amount: '0.2', unit: 'g'),
          ],
          steps: [
            RecipeStep(description: 'Mix flour, water, and yeast until smooth.'),
            RecipeStep(description: 'Ferment at room temperature for 12 hours.'),
          ],
        ),
        RecipeComponent(
          title: 'Main Dough',
          ingredients: [
            Ingredient(name: 'Bread Flour', amount: '350', unit: 'g'),
            Ingredient(name: 'Water', amount: '200', unit: 'g'),
            Ingredient(name: 'Salt', amount: '10', unit: 'g'),
            Ingredient(name: 'Instant Yeast', amount: '1', unit: 'g'),
          ],
          steps: [
            RecipeStep(description: 'Combine poolish, flour, water, and yeast. Autolyse 20m.'),
            RecipeStep(description: 'Add salt and knead until moderate gluten development.'),
            RecipeStep(description: 'Bulk ferment for 2 hours with folds at 45m and 90m.'),
            RecipeStep(description: 'Divide, shape into baguettes, and final proof for 45m.'),
            RecipeStep(description: 'Score and bake at 240°C with steam for 22-25m.'),
          ],
        ),
      ],
    ),
    Recipe(
      id: '4',
      name: 'Rosemary Olive Oil Cake',
      description: 'A moist and aromatic dessert infused with extra virgin olive oil and fresh herbs.',
      mainImageUrl: 'assets/images/cake.png',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      tags: ['Cakes', 'Desserts'],
      components: [
        RecipeComponent(
          title: 'Cake Batter',
          ingredients: [
            Ingredient(name: 'All-Purpose Flour', amount: '200', unit: 'g'),
            Ingredient(name: 'Sugar', amount: '150', unit: 'g'),
            Ingredient(name: 'Olive Oil', amount: '120', unit: 'g'),
            Ingredient(name: 'Yogurt', amount: '100', unit: 'g'),
            Ingredient(name: 'Eggs', amount: '110', unit: 'g'),
            Ingredient(name: 'Fresh Rosemary (minced)', amount: '5', unit: 'g'),
            Ingredient(name: 'Baking Powder', amount: '5', unit: 'g'),
          ],
          steps: [
            RecipeStep(description: 'Beat eggs and sugar until thickened.'),
            RecipeStep(description: 'Drizzle in extra virgin olive oil and yogurt.'),
            RecipeStep(description: 'Fold in sifted dry ingredients and minced rosemary.'),
            RecipeStep(description: 'Pour into a lined tin and bake at 175°C for 40-45m.'),
          ],
        ),
      ],
    ),
    Recipe(
      id: '5',
      name: 'Brown Butter Chocolate Cookies',
      description: 'Rich, chewy cookies with nutty brown butter and dark chocolate chunks.',
      mainImageUrl: 'assets/images/cookies.png',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      tags: ['Cookies', 'Signature'],
      components: [
        RecipeComponent(
          title: 'Cookie Dough',
          ingredients: [
            Ingredient(name: 'All-Purpose Flour', amount: '220', unit: 'g'),
            Ingredient(name: 'Brown Sugar', amount: '130', unit: 'g'),
            Ingredient(name: 'White Sugar', amount: '70', unit: 'g'),
            Ingredient(name: 'Unsalted Butter', amount: '150', unit: 'g'),
            Ingredient(name: 'Dark Chocolate (70%)', amount: '150', unit: 'g'),
            Ingredient(name: 'Egg', amount: '55', unit: 'g'),
            Ingredient(name: 'Baking Soda', amount: '3', unit: 'g'),
            Ingredient(name: 'Flaky Sea Salt', amount: '2', unit: 'g'),
          ],
          steps: [
            RecipeStep(description: 'Melt butter in a pan until browned and fragrant. Cool.'),
            RecipeStep(description: 'Whisk brown butter, sugars, and egg together.'),
            RecipeStep(description: 'Fold in flour, baking soda, and chopped dark chocolate.'),
            RecipeStep(description: 'Rest the cookie dough in the fridge for 2 hours.'),
            RecipeStep(description: 'Scoop, sprinkle with sea salt, and bake at 180°C for 10-12m.'),
          ],
        ),
      ],
    ),
  ];
}
