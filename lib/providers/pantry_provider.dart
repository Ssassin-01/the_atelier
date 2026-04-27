import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/pantry_item.dart';

final pantryProvider = StateNotifierProvider<PantryNotifier, List<PantryItem>>((ref) {
  return PantryNotifier();
});

class PantryNotifier extends StateNotifier<List<PantryItem>> {
  PantryNotifier() : super([]) {
    _loadItems();
  }

  Box<PantryItem> get _box => Hive.box<PantryItem>('pantry');

  void _loadItems() {
    state = _box.values.toList();
  }

  Future<void> addItem(PantryItem item) async {
    await _box.put(item.id, item);
    _loadItems();
  }

  Future<void> updateItem(PantryItem item) async {
    await _box.put(item.id, item);
    _loadItems();
  }

  Future<void> deleteItem(String id) async {
    await _box.delete(id);
    _loadItems();
  }

  /// Finds a pantry item by name (case-insensitive)
  PantryItem? findByName(String name) {
    try {
      return _box.values.firstWhere(
        (item) => item.name.toLowerCase() == name.toLowerCase()
      );
    } catch (_) {
      return null;
    }
  }

  /// Deducts stock based on recipe ingredients
  Future<void> deductStockByRecipe(dynamic recipe) async {
    // We use dynamic to avoid circular dependency if needed, 
    // or just assume recipe structure.
    final ingredients = recipe.ingredients as List;
    for (var ing in ingredients) {
      final name = ing.name as String;
      final amount = (ing.amount as num).toDouble();
      final item = findByName(name);
      
      if (item != null) {
        final newStock = (item.currentStock - amount).clamp(0.0, double.infinity);
        await updateItem(item.copyWith(currentStock: newStock, lastUpdated: DateTime.now()));
      }
    }
  }

  /// Update all items in a category when it's renamed or deleted
  Future<void> bulkUpdateCategory(String oldCategory, String? newCategory) async {
    for (var item in _box.values) {
      if (item.category == oldCategory) {
        await _box.put(item.id, item.copyWith(category: newCategory ?? 'Others'));
      }
    }
    _loadItems();
  }
}
