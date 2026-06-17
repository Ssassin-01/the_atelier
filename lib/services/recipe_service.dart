import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/recipe.dart';

import 'mock_data.dart';

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

    for (var recipe in getMockRecipes()) {
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
