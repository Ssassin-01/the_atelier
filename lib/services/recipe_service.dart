import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/recipe.dart';

final recipeServiceProvider = Provider((ref) => RecipeService());

class RecipeService {
  final Box<Recipe> _recipeBox = Hive.box<Recipe>('recipes');

  List<Recipe> getAllRecipes() {
    return _recipeBox.values.toList();
  }

  Future<void> addRecipe(Recipe recipe) async {
    await _recipeBox.put(recipe.id, recipe);
  }

  Future<void> updateRecipe(Recipe recipe) async {
    await _recipeBox.put(recipe.id, recipe);
  }

  Future<void> deleteRecipe(String id) async {
    await _recipeBox.delete(id);
  }

  Future<void> seedInitialData() async {
    if (_recipeBox.isNotEmpty) return;

    final mockRecipes = [
      Recipe(
        id: '1',
        name: 'Classic Butter Croissant',
        description: '72시간 발효한 고소한 풍미의 프랑스 정통 크로와상입니다. 바삭한 결이 살아있습니다.',
        sellingPrice: 4500,
        createdAt: DateTime.now(),
        components: [],
        tags: ['Classic', 'Butter'],
      ),
      Recipe(
        id: '2',
        name: 'Wild Yeast Sourdough',
        description: '천연 발효종으로 깊은 맛을 낸 아티장 사워도우입니다. 겉은 바삭하고 속은 쫄깃합니다.',
        sellingPrice: 6500,
        createdAt: DateTime.now(),
        components: [],
        tags: ['Vegan', 'Natural'],
      ),
      Recipe(
        id: '3',
        name: 'Valrhona Pain au Chocolat',
        description: '발로나 초콜릿이 듬뿍 들어간 달콤하고 바삭한 페이스트리입니다.',
        sellingPrice: 5000,
        createdAt: DateTime.now(),
        components: [],
        tags: ['Chocolate', 'Sweet'],
      ),
      Recipe(
        id: '4',
        name: 'Earl Grey Milk Tea Macaron',
        description: '얼그레이 향이 은은하게 퍼지는 쫀득한 꼬끄와 필링의 마카롱입니다.',
        sellingPrice: 3200,
        createdAt: DateTime.now(),
        components: [],
        tags: ['Tea', 'Dessert'],
      ),
      Recipe(
        id: '5',
        name: 'Vanilla Bean Canelé',
        description: '바닐라 빈의 진한 풍미가 느껴지는 겉바속촉 보르도 스타일 까눌레입니다.',
        sellingPrice: 3800,
        createdAt: DateTime.now(),
        components: [],
        tags: ['French', 'Vanilla'],
      ),
      Recipe(
        id: '6',
        name: 'Strawberry Cream Cake',
        description: '산지 직송 신선한 딸기를 듬뿍 넣은 부드러운 생크림 케이크입니다.',
        sellingPrice: 8500,
        createdAt: DateTime.now(),
        components: [],
        tags: ['Fruit', 'Cake'],
      ),
      Recipe(
        id: '7',
        name: 'Matcha Green Tea Tart',
        description: '말차의 쌉싸름한 맛과 고소한 타르트지가 조화로운 맛을 냅니다.',
        sellingPrice: 7200,
        createdAt: DateTime.now(),
        components: [],
        tags: ['Matcha', 'Tart'],
      ),
      Recipe(
        id: '8',
        name: 'Blueberry Almond Scone',
        description: '신선한 블루베리가 톡톡 터지는 고소한 아몬드 풍미의 스콘입니다.',
        sellingPrice: 4200,
        createdAt: DateTime.now(),
        components: [],
        tags: ['Nutty', 'Scone'],
      ),
      Recipe(
        id: '9',
        name: 'Fig & Walnut Bread',
        description: '무화과의 달콤함과 호두의 식감이 매력적인 영양 가득 건강빵입니다.',
        sellingPrice: 5800,
        createdAt: DateTime.now(),
        components: [],
        tags: ['Healthy', 'Nutty'],
      ),
      Recipe(
        id: '10',
        name: 'Espresso Financier',
        description: '진한 에스프레소 향이 가미된 고소한 헤이즐넛 버터 풍미의 휘낭시에입니다.',
        sellingPrice: 2800,
        createdAt: DateTime.now(),
        components: [],
        tags: ['Coffee', 'Small'],
      ),
    ];

    for (var recipe in mockRecipes) {
      await _recipeBox.put(recipe.id, recipe);
    }
  }
}

final recipeListProvider = StateNotifierProvider<RecipeNotifier, List<Recipe>>((
  ref,
) {
  return RecipeNotifier(ref.read(recipeServiceProvider));
});

class RecipeNotifier extends StateNotifier<List<Recipe>> {
  final RecipeService _service;

  RecipeNotifier(this._service) : super([]) {
    _loadRecipes();
  }

  void _loadRecipes() async {
    final recipes = _service.getAllRecipes();
    if (recipes.isEmpty) {
      await _service.seedInitialData();
      state = _service.getAllRecipes();
    } else {
      state = recipes;
    }
  }

  Future<void> addRecipe(Recipe recipe) async {
    await _service.addRecipe(recipe);
    _loadRecipes();
  }

  Future<void> updateRecipe(Recipe recipe) async {
    await _service.updateRecipe(recipe);
    _loadRecipes();
  }

  Future<void> removeRecipe(String id) async {
    await _service.deleteRecipe(id);
    _loadRecipes();
  }

  Future<void> seedSamples() async {
    await _service.seedInitialData();
    state = _service.getAllRecipes();
  }
}
