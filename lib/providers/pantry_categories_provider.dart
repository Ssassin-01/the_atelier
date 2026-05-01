import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

// We'll store a Map of String (category name) to int (color value)
final pantryCategoriesProvider =
    StateNotifierProvider<PantryCategoriesNotifier, Map<String, int>>((ref) {
      return PantryCategoriesNotifier();
    });

class PantryCategoriesNotifier extends StateNotifier<Map<String, int>> {
  PantryCategoriesNotifier() : super({}) {
    _loadCategories();
  }

  Box<dynamic> get _box => Hive.box('settings');

  // Default Palette for Post-its
  static const Map<String, int> defaultCategories = {
    'All': 0xFFFAF9F6, // Paper White
    'Flour': 0xFFFFF9C4, // Pastel Yellow
    'Dairy/Eggs': 0xFFFFE0B2, // Pastel Orange
    'Sweetener': 0xFFF8BBD0, // Pastel Pink
    'Leavening': 0xFFE1F5FE, // Pastel Blue
    'Add-in': 0xFFC8E6C9, // Pastel Green
    'Others': 0xFFF3E5F5, // Pastel Purple
  };

  void _loadCategories() {
    final saved = _box.get('pantry_categories_map');
    if (saved != null && saved is Map) {
      state = Map<String, int>.from(saved);
    } else {
      state = Map<String, int>.from(defaultCategories);
    }
  }

  Future<void> addCategory(String category, int color) async {
    if (!state.containsKey(category)) {
      final newState = Map<String, int>.from(state);
      final othersColor = newState.remove('Others');

      newState[category] = color;

      if (othersColor != null) {
        newState['Others'] = othersColor;
      }

      state = newState;
      await _box.put('pantry_categories_map', state);
    }
  }

  Future<void> removeCategory(String category) async {
    if (category != 'All' && category != 'Others') {
      final newState = Map<String, int>.from(state);
      newState.remove(category);
      state = newState;
      await _box.put('pantry_categories_map', state);
    }
  }

  Future<void> renameCategory(String oldName, String newName) async {
    if (oldName == 'All' || oldName == 'Others') return;
    if (state.containsKey(oldName)) {
      final Map<String, int> newState = {};
      for (final entry in state.entries) {
        if (entry.key == oldName) {
          newState[newName] = entry.value;
        } else {
          newState[entry.key] = entry.value;
        }
      }

      state = newState;
      await _box.put('pantry_categories_map', state);
    }
  }

  Future<void> reorderCategories(int oldIndex, int newIndex) async {
    final keys = state.keys.toList();
    final item = keys.removeAt(oldIndex);
    keys.insert(newIndex, item);

    final Map<String, int> newState = {};
    for (final key in keys) {
      newState[key] = state[key]!;
    }

    state = newState;
    await _box.put('pantry_categories_map', state);
  }

  Future<void> updateColor(String category, int color) async {
    if (state.containsKey(category)) {
      final newState = Map<String, int>.from(state);
      newState[category] = color;
      state = newState;
      await _box.put('pantry_categories_map', state);
    }
  }
}
